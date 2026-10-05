

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/common/skeleton_loader.dart';
import 'package:gobuddy_customer_app/models/add_ons_model.dart';
import 'package:gobuddy_customer_app/models/coupon_model.dart';
import 'package:gobuddy_customer_app/models/user_overview_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/uploader.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'package:gobuddy_customer_app/data/prefernces.dart';
import 'package:gobuddy_customer_app/pages/subscription/subscription_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../utils/my_colors.dart';

class ServiceOrderSummaryScreen extends StatefulWidget {
  const ServiceOrderSummaryScreen({super.key});

  @override
  State<ServiceOrderSummaryScreen> createState() =>
      _ServiceOrderSummaryScreenState();
}

class _ServiceOrderSummaryScreenState
    extends State<ServiceOrderSummaryScreen> {
  // ─── Controllers ────────────────────────────────────────────────────────────
  final TextEditingController _couponController = TextEditingController();

  // ─── UI state ────────────────────────────────────────────────────────────────
  bool _termsAccepted = false;
  bool _isInit = false;
  bool _isUploading = false;

  // ─── Route args ──────────────────────────────────────────────────────────────
  String? providerName;
  String? providerId;
  String? date;
  String? time;
  String? catId;
  String? userId;
  String? mainCategoryId;

  // ─── Services & addons ───────────────────────────────────────────────────────
  List<dynamic> getServices = [];
  List<int> serviceIds = [];
  GetAddons? pushAddons;
  List<Map<String, dynamic>> selectedAddOns = [];

  // ─── Media ───────────────────────────────────────────────────────────────────
  List<XFile> _selectedFiles = [];

  // ─── User ────────────────────────────────────────────────────────────────────
  GetUserDetailsModel? pushintoUserOverviewModel;
  CustomerDetails? customerDetails;

  // ─── Pricing ─────────────────────────────────────────────────────────────────
  static const double _platformFee = 200.0;
  static const double _gstRate = 0.08; // 8%

  double _baseServicePrice = 0.0; // original provider price
  double _discountPrice = 0.0;

  // Discount sources — mutually exclusive
  GetCouponModel? _appliedCoupon;
  bool _gbCoinsApplied = false;
  double _userCoins = 50.0;

  // ─── Computed pricing ────────────────────────────────────────────────────────

  double get _addonsTotal {
    return selectedAddOns.fold(0.0, (sum, addon) {
      final price = double.tryParse(addon['price'].toString().replaceAll(',', '')) ?? 0.0;
      final qty = (addon['quantity'] as int?) ?? 1;
      return sum + (price * qty);
    });
  }

  double get _couponDiscount {
    if (_appliedCoupon == null) return 0.0;
    if (_appliedCoupon!.amount != null && _appliedCoupon!.amount! > 0) {
      return _appliedCoupon!.amount!.toDouble();
    }
    final parsedStr = double.tryParse(_appliedCoupon!.couponAmount?.replaceAll(',', '') ?? '');
    if (parsedStr != null && parsedStr > 0) return parsedStr;
    return 0.0;
  }

  double get _activeDiscount {
    if (_gbCoinsApplied) return _userCoins;
    if (_appliedCoupon != null) return _couponDiscount;
    return 0.0;
  }

  /// Dynamically computes total service amount based on each service's unit price and current quantity
  double get _servicesTotal {
    if (getServices.isEmpty) return _baseServicePrice;
    double sum = 0.0;
    for (var s in getServices) {
      if (s is Map<String, dynamic>) {
        final double? storedUnit = s['unit_price'] as double?;
        final double fallbackUnit =
            double.tryParse(s['service_price']?.toString().replaceAll(',', '') ?? '') ?? 0.0;
        final double unit = (storedUnit != null && storedUnit > 0)
            ? storedUnit
            : (fallbackUnit > 0
                ? fallbackUnit
                : (_baseServicePrice /
                    (getServices.isNotEmpty ? getServices.length : 1)));
        final int qty = (s['quantity'] is int)
            ? s['quantity'] as int
            : (int.tryParse(s['quantity']?.toString() ?? '1') ?? 1);
        sum += unit * (qty > 0 ? qty : 1);
      }
    }
    return sum > 0 ? sum : _baseServicePrice;
  }

  /// Dynamic discount price based on current quantities
  double get _effectiveDiscountPrice {
    double sum = 0.0;
    bool hasUnitDiscount = false;
    for (var s in getServices) {
      if (s is Map<String, dynamic> && s['unit_discount'] != null) {
        hasUnitDiscount = true;
        final d = (s['unit_discount'] as num).toDouble();
        final int qty = (s['quantity'] is int)
            ? s['quantity'] as int
            : (int.tryParse(s['quantity']?.toString() ?? '1') ?? 1);
        sum += d * (qty > 0 ? qty : 1);
      }
    }
    if (hasUnitDiscount) return sum;
    return _discountPrice;
  }

  /// Subtotal = dynamic services total + addons
  double get _subtotal => _servicesTotal + _addonsTotal;

  /// GST applied on subtotal after provider discount
  double get _taxableAmount => (_subtotal - _effectiveDiscountPrice).clamp(0, double.infinity);

  double get _gstAmount => double.parse((_taxableAmount * _gstRate).toStringAsFixed(2));

  // Subscription status
  bool _isSubscribed = false;
  String? _subscriptionPlanName;

  double get _effectivePlatformFee => _isSubscribed ? 0.0 : _platformFee;

  /// Off-hour convenience fee (bookings before 8:00 AM or at/after 8:00 PM)
  bool get _isOffHour {
    if (time == null || time!.isEmpty) return false;
    try {
      final cleanTime = time!.trim().toUpperCase();
      DateTime parsedTime;
      if (cleanTime.contains('AM') || cleanTime.contains('PM')) {
        parsedTime = DateFormat('hh:mm a').parse(cleanTime);
      } else {
        parsedTime = DateFormat('HH:mm').parse(cleanTime);
      }
      final hour = parsedTime.hour;
      return hour < 8 || hour >= 20;
    } catch (_) {
      return false;
    }
  }

  static const double _offHourFeeRate = 100.0;
  double get _offHourFee => _isOffHour ? _offHourFeeRate : 0.0;

  /// Gross total before active customer discount (promo / GB coins)
  double get _grossTotal => _taxableAmount + _gstAmount + _effectivePlatformFee + _offHourFee;

  /// Active discount capped at gross total
  double get _cappedActiveDiscount => _activeDiscount.clamp(0.0, _grossTotal);

  /// Final total payable amount
  double get _totalAmount =>
      double.parse((_grossTotal - _cappedActiveDiscount).clamp(0.0, double.infinity).toStringAsFixed(2));

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) return;
    _isInit = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Map<String, dynamic>) return;

    providerName = args['provider_name'] as String?;
    providerId = args['provider_id'] as String?;
    date = args['date'] as String?;
    time = args['time'] as String?;
    userId = args['user_id'] as String?;
    mainCategoryId = args['main_category_id'] as String?;

    final dynamic originalPriceDynamic = args['provider_total_orignal_price'];
    final dynamic discountPriceDynamic = args['provider_discount_price'];

    _baseServicePrice = _toDouble(originalPriceDynamic);
    _discountPrice = _toDouble(discountPriceDynamic);

    final subCategory = args['sub_category'];
    if (subCategory is List<dynamic>) {
      setState(() {
        getServices = subCategory;

        // Calculate initial total quantity across all services
        int totalQty = 0;
        for (var service in getServices) {
          if (service is Map<String, dynamic>) {
            final q = service['quantity'];
            int qty = 1;
            if (q is int) {
              qty = q;
            } else if (q is String) {
              qty = int.tryParse(q) ?? 1;
            }
            totalQty += (qty > 0 ? qty : 1);
          }
        }
        if (totalQty <= 0) totalQty = 1;

        // Set unit_price and unit_discount on each service item so quantity changes scale properly
        for (var service in getServices) {
          if (service is Map<String, dynamic>) {
            final q = service['quantity'];
            int qty = 1;
            if (q is int) {
              qty = q;
            } else if (q is String) {
              qty = int.tryParse(q) ?? 1;
            }
            service['quantity'] = qty > 0 ? qty : 1;

            if (service['unit_price'] == null) {
              final double? sp =
                  double.tryParse(service['service_price']?.toString().replaceAll(',', '') ?? '');
              if (sp != null && sp > 0) {
                service['unit_price'] = sp;
              } else {
                service['unit_price'] = _baseServicePrice / totalQty;
              }
            }
            if (service['unit_discount'] == null && _discountPrice > 0) {
              service['unit_discount'] = _discountPrice / totalQty;
            }
          }
        }

        serviceIds = getServices.map<int>((service) {
          if (service is Map<String, dynamic>) {
            final id = service['id'];
            catId = service['id'].toString();
            if (id is int) return id;
            if (id is String) return int.tryParse(id) ?? 0;
          }
          return 0;
        }).where((id) => id != 0).toList();
      });

      _getAddOns();
      _getUserDetailsforAddress();
      _checkUserSubscription();
    } else {
      _checkUserSubscription();
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic>? _parseResponse(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String) {
      try {
        return json.decode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  String _fmt(double v) => v.toStringAsFixed(2);

  // ─── API calls ───────────────────────────────────────────────────────────────

  Future<void> _checkUserSubscription() async {
    if (userId == null || userId!.isEmpty) {
      userId = await Preferences.getUserID();
    }
    final effectiveUserId = userId ?? '';
    if (effectiveUserId.isEmpty) return;
    try {
      final raw = await Repository.NewPostApiService(
        EndPoints.getMySubscriptionPlans,
        {'user_id': effectiveUserId},
      );
      final res = _parseResponse(raw);
      if (res != null &&
          (res['status'] == 'valid' || res['status'] == true || res['status'] == 'success') &&
          res['data'] != null &&
          (res['data'] as List).isNotEmpty) {
        final plans = res['data'] as List;
        final firstPlan = plans.first;
        if (mounted) {
          setState(() {
            _isSubscribed = true;
            _subscriptionPlanName = firstPlan is Map ? firstPlan['plan_name']?.toString() : 'Active Plan';
          });
        }
      }
    } catch (e) {
      debugPrint('checkUserSubscription error: $e');
    }
  }

  Future<void> _getAddOns() async {
    if (!await UtilClass.checkInternet()) return;
    try {
      final raw = await Repository.NewPostApiService(
        EndPoints.getAddonsApi,
        {'provider_id': providerId ?? '', 'category_id': mainCategoryId ?? ''},
      );
      final res = _parseResponse(raw);
      if (res?['status'] == 'valid') {
        setState(() => pushAddons = GetAddons.fromJson(res!));
      }
    } catch (e) {
      debugPrint('getAddOns error: $e');
    }
  }

  Future<void> _getUserDetailsforAddress() async {
    if (!await UtilClass.checkInternet()) return;
    try {
      final raw = await Repository.NewPostApiService(
        EndPoints.getUserDetailsbyUserId,
        {'id': userId ?? ''},
      );
      final res = _parseResponse(raw);
      if (res?['status'] == 'valid') {
        final model = GetUserDetailsModel.fromJson(res!);
        setState(() {
          customerDetails = model.customerDetails;
          final dynamic custDetails = res['customer_details'] ?? res['data'];
          dynamic coinsVal;
          if (custDetails is Map) {
            coinsVal = custDetails['gb_coins'] ?? custDetails['coins'];
          }
          coinsVal ??= res['gb_coins'] ?? res['coins'];
          if (coinsVal != null) {
            final parsedCoins = double.tryParse(coinsVal.toString());
            if (parsedCoins != null && parsedCoins > 0) {
              _userCoins = parsedCoins;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('getUserDetails error: $e');
    }
  }

  Future<void> _handleApplyCoupon() async {
    if (_gbCoinsApplied) {
      _showInfoSnackbar(
          "Remove GB Coins first before applying a coupon.");
      return;
    }

    final code = _couponController.text.trim();
    if (code.isEmpty) {
      UtilClass.showAlertDialog(
          context: context, message: "Please enter a coupon code");
      return;
    }
    if (!await UtilClass.checkInternet()) {
      UtilClass.showAlertDialog(
          context: context, message: "No Internet Connection");
      return;
    }

    if (userId == null || userId!.isEmpty) {
      userId = await Preferences.getUserID();
    }
    final effectiveUserId = (userId != null && userId!.isNotEmpty) ? userId! : '1';

    try {
      final raw = await Repository.postApiService(
        EndPoints.verifyCouponcode,
        {
          'user_id': effectiveUserId,
          'coupon': code,
          'coupon_code': code,
        },
      );
      final res = _parseResponse(raw);
      debugPrint("Verify coupon response: $res");

      final isStatusValid = res?['status'] == 'valid' ||
          res?['status'] == 'success' ||
          res?['status'] == true ||
          res?['status'] == '1';

      if (isStatusValid && res != null) {
        // Extract coupon data either at root or inside 'data' / 'coupon'
        final Map<String, dynamic> cData = res['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(res['data'] as Map)
            : res['coupon'] is Map<String, dynamic>
                ? Map<String, dynamic>.from(res['coupon'] as Map)
                : res;

        final rawAmt = cData['coupon_amount'] ??
            cData['amount'] ??
            cData['discount'] ??
            cData['discount_amount'];

        double discountVal = 0.0;
        if (rawAmt != null) {
          discountVal = double.tryParse(rawAmt.toString().replaceAll(',', '')) ?? 0.0;
        }

        // Percentage check
        final discountType = (cData['discount_type'] ?? cData['type'])?.toString().toLowerCase();
        if (discountType == 'percentage' || discountType == '%' || cData['is_percentage'] == true) {
          if (discountVal > 0) {
            discountVal = (_servicesTotal * discountVal / 100);
          }
        }

        if (discountVal <= 0) {
          discountVal = 50.0; // fallback standard discount if valid status
        }

        final couponModel = GetCouponModel(
          status: 'valid',
          message: res['message']?.toString() ?? 'Coupon Applied Successfully!',
          couponId: (cData['coupon_id'] ?? cData['id'])?.toString() ?? '105',
          couponName: (cData['coupon_name'] ?? cData['coupon_code'] ?? code).toString(),
          couponAmount: discountVal.toStringAsFixed(2),
          amount: discountVal.round(),
        );

        setState(() => _appliedCoupon = couponModel);
        _showCouponDialog(
            message: "Coupon Applied Successfully!", isSuccess: true);
      } else {
        final errMsg = res?['message']?.toString() ?? "Invalid coupon";
        _showCouponDialog(
            message: errMsg, isSuccess: false);
      }
    } catch (e) {
      debugPrint("Error applying coupon: $e");
      UtilClass.showAlertDialog(
          context: context, message: "Something went wrong, please try again");
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponController.clear();
    });
  }

  void _toggleGbCoins() {
    if (_appliedCoupon != null) {
      _showInfoSnackbar("Remove the coupon first before using GB Coins.");
      return;
    }
    if (_userCoins <= 0) {
      _showInfoSnackbar("You do not have enough GB Coins.");
      return;
    }
    setState(() => _gbCoinsApplied = !_gbCoinsApplied);
  }

  Future<void> _imageUpload() async {
    if (!await UtilClass.checkInternet()) {
      UtilClass.showAlertDialog(
          context: context, message: "No Internet Connection!");
      return;
    }
    if (_selectedFiles.isEmpty) {
      UtilClass.showAlertDialog(
          context: context, message: "No files selected to upload.");
      return;
    }
    setState(() => _isUploading = true);
    try {
      final files = await Future.wait(_selectedFiles.map(
          (f) => MultipartFile.fromFile(f.path, filename: f.name)));
      await Repository.NewPostApiService(EndPoints.uploadProviderImages, {
        'provider_id': providerId ?? '',
        'images': files,
        'service_id': serviceIds,
      });
      UtilClass.showAlertDialog(
          context: context, message: "Images uploaded successfully!");
    } catch (e) {
      UtilClass.showAlertDialog(
          context: context, message: "Failed to upload images.");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // ─── Add-ons popup ────────────────────────────────────────────────────────────

  void _openAddOnsPopup() {
    if (pushAddons == null || pushAddons!.addons.isEmpty) {
      return;
    }

    final List<Map<String, dynamic>> tempAddOns =
        pushAddons!.addons.map((addon) => {
              'id': addon.addonId,
              'name': addon.addonService,
              'price': addon.amount,
              'quantity': 0,
            }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
          final hasSelection =
              tempAddOns.any((a) => (a['quantity'] as int) > 0);
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.6,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 12),
                const Text("Add-Ons",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: tempAddOns.length,
                    itemBuilder: (_, i) {
                      final addon = tempAddOns[i];
                      final qty = addon['quantity'] as int;
                      return ListTile(
                        title: Text(addon['name'].toString()),
                        subtitle: Text("₹ ${addon['price']}"),
                        trailing: qty == 0
                            ? OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  side: const BorderSide(color: Colors.green),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () =>
                                    setModal(() => addon['quantity'] = 1),
                                child: const Text("Add"),
                              )
                            : _miniQtySelector(
                                qty,
                                onDecrement: () => setModal(() {
                                  addon['quantity'] =
                                      (addon['quantity'] as int) - 1;
                                }),
                                onIncrement: () => setModal(() {
                                  addon['quantity'] =
                                      (addon['quantity'] as int) + 1;
                                }),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: hasSelection
                      ? () {
                          setState(() {
                            selectedAddOns = tempAddOns
                                .where((a) => (a['quantity'] as int) > 0)
                                .toList();
                          });
                          Navigator.pop(ctx);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    disabledBackgroundColor: Colors.grey[300],
                    fixedSize: const Size(250, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("OK",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Coupon dialog ────────────────────────────────────────────────────────────

  void _showCouponDialog({required String message, required bool isSuccess}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          width: 220,
          padding: const EdgeInsets.symmetric(vertical: 25),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0.5, end: 1.0),
                curve: Curves.easeOutBack,
                builder: (_, v, __) => Transform.scale(
                  scale: v,
                  child: Icon(
                      isSuccess ? Icons.check_circle : Icons.cancel,
                      color: isSuccess ? Colors.green : Colors.red,
                      size: 70),
                ),
              ),
              const SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: MyColors.appThemeLight)),
            ],
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.canPop(context)) Navigator.pop(context);
    });
  }

  void _showInfoSnackbar(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ─── Date helper ─────────────────────────────────────────────────────────────

  String? get _shortDate {
    if (date == null) return null;
    try {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(date!));
    } catch (_) {
      return date;
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderReviewSection(),
            if (selectedAddOns.isNotEmpty) _buildSelectedAddOns(),
            _buildServiceProviderSection(w),
            _buildAddServiceSection(w),
            _buildPhotoUploadSection(w),
            _buildSubscriptionPlan(w),
            _buildAddressSection(w),
            _buildOffersSection(w),
            _buildPaymentSummary(w),
            _buildTermsAndConditions(w),
            _buildPayButton(w),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Summary',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      );

  // ─── Order review ─────────────────────────────────────────────────────────────

  Widget _buildOrderReviewSection() {
    if (getServices.isEmpty) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(height: 16, width: 160),
            SizedBox(height: 20),
            SkeletonLoader(height: 14, width: double.infinity),
            SizedBox(height: 12),
            SkeletonLoader(height: 14, width: 220),
            SizedBox(height: 20),
            SkeletonLoader(height: 14, width: double.infinity),
            SizedBox(height: 12),
            SkeletonLoader(height: 14, width: 200),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Review Your Order',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 16),
          ...getServices.map((item) {
            final name = item['title'] ?? 'Unknown';
            final type = item['type'] ?? '';
            final quantity = item['quantity'] ?? 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$name${type.isNotEmpty ? " ($type)" : ""}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹ ${_fmt(((item['unit_price'] as double?) ?? (_baseServicePrice / (getServices.isNotEmpty ? getServices.length : 1))) * (item['quantity'] ?? 1))}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D32)),
                          ),
                        ],
                      ),
                    ),
                    _quantitySelector(
                      quantity,
                      onDecrement: () {
                        if ((item['quantity'] ?? 1) > 1) {
                          setState(() => item['quantity'] =
                              (item['quantity'] ?? 1) - 1);
                        }
                      },
                      onIncrement: () => setState(
                          () => item['quantity'] = (item['quantity'] ?? 1) + 1),
                    ),
                  ],
                ),
                if (pushAddons != null && pushAddons!.addons.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _openAddOnsPopup,
                    child: const Row(
                      children: [
                        Text("Add-Ons",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange,
                                decoration: TextDecoration.underline)),
                        Icon(Icons.chevron_right, size: 20, color: Colors.orange),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── Selected add-ons ─────────────────────────────────────────────────────────

  Widget _buildSelectedAddOns() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add-Ons",
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...selectedAddOns.map((addon) {
            final price =
                double.tryParse(addon['price'].toString().replaceAll(',', '')) ?? 0.0;
            final qty = (addon['quantity'] as int?) ?? 1;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(addon['name'].toString(),
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87)),
                  ),
                  Text("₹ ${_fmt(price * qty)}",
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black54)),
                  const SizedBox(width: 12),
                  _quantitySelector(
                    qty,
                    onDecrement: () => setState(() {
                      addon['quantity'] = qty - 1;
                      if (addon['quantity'] == 0) selectedAddOns.remove(addon);
                    }),
                    onIncrement: () =>
                        setState(() => addon['quantity'] = qty + 1),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text("Addons Total: ₹ ${_fmt(_addonsTotal)}",
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32))),
          ),
        ],
      ),
    );
  }

  // ─── Quantity selector ────────────────────────────────────────────────────────

  Widget _quantitySelector(int qty,
      {required VoidCallback onDecrement,
      required VoidCallback onIncrement}) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2E7D32)),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove,
                size: 14, color: Color(0xFF2E7D32)),
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(minWidth: 24, minHeight: 20),
          ),
          Text('$qty',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600)),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add,
                size: 14, color: Color(0xFF2E7D32)),
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(minWidth: 24, minHeight: 20),
          ),
        ],
      ),
    );
  }

  Widget _miniQtySelector(int qty,
      {required VoidCallback onDecrement,
      required VoidCallback onIncrement}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF2E7D32)),
          borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove),
              iconSize: 18),
          Text('$qty'),
          IconButton(
              onPressed: onIncrement,
              icon: const Icon(Icons.add),
              iconSize: 18),
        ],
      ),
    );
  }

  // ─── Service provider ─────────────────────────────────────────────────────────

  Widget _buildServiceProviderSection(double w) {
    if (providerName == null || providerName!.isEmpty) {
      return Container(
        width: w,
        color: Colors.white,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  SkeletonLoader(height: 12, width: 120),
                  SizedBox(height: 8),
                  SkeletonLoader(height: 14, width: 180),
                ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              SkeletonLoader(height: 12, width: 80),
              SizedBox(height: 6),
              SkeletonLoader(height: 12, width: 60),
            ]),
          ],
        ),
      );
    }

    return Container(
      width: w,
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Service Provider:',
                    style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(providerName ?? "",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
               IconButton(
  onPressed: () {
    Navigator.pop(context);
  },
  icon: const Icon(
    Icons.edit,
    color: Color(0xFF2E7D32),
  ),
),
                  const SizedBox(width: 4),
                  Text(_shortDate ?? "",
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 2),
              Text(time ?? "",
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Add service ─────────────────────────────────────────────────────────────

  Widget _buildAddServiceSection(double w) {
    return Container(
      width: w,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2E7D32),
            side: const BorderSide(color: Color(0xFF2E7D32)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            bool poppedToCart = false;
            Navigator.popUntil(context, (route) {
              if (route.settings.name == Config.addServicesToCartRouteName) {
                poppedToCart = true;
                return true;
              }
              if (route.isFirst) {
                return true;
              }
              return false;
            });
            if (!poppedToCart) {
              Navigator.pushNamed(context, Config.selectServiceTypeRouteName);
            }
          },
          child: const Text('Add Another Service',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  // ─── Photo upload ─────────────────────────────────────────────────────────────

  Widget _buildPhotoUploadSection(double w) {
    return Container(
      width: w,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              'Upload photos and/or videos for the service you need',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          MediaPickerSection(
            onMediaSelected: (files) =>
                setState(() => _selectedFiles = files),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isUploading
                ? null
                : () async {
                    if (_selectedFiles.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Please select a file first.")));
                      return;
                    }
                    await _imageUpload();
                  },
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text("Upload"),
          ),
        ],
      ),
    );
  }

  // ─── Subscription plan ───────────────────────────────────────────────────────

  Widget _buildSubscriptionPlan(double w) {
    return Container(
      width: w,
      margin: const EdgeInsets.only(top: 8),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: _isSubscribed ? const Color(0xFFE8F5E9) : Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isSubscribed ? Colors.green.shade300 : Colors.orange.shade200,
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _isSubscribed
                      ? '✓ Subscription Active • Platform fee waived'
                      : 'Save on this booking',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isSubscribed ? Colors.green.shade800 : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Image.asset('assets/images/gift-card.png',
                    width: 40, height: 40, fit: BoxFit.contain),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _subscriptionPlanName ?? "GoBuddy Plus Membership",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _isSubscribed ? 'Platform Fee Waived' : '₹0 Platform Fee',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isSubscribed ? Colors.green.shade700 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '₹${_platformFee.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    if (_isSubscribed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Active subscription '${_subscriptionPlanName ?? "GoBuddy Plus"}' is already applied! Platform fee is ₹0."),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
                      // Navigate to subscription screen to purchase a real subscription
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MySubscriptionScreen(
                            userData: {'user_id': userId ?? ''},
                          ),
                        ),
                      ).then((_) => _checkUserSubscription());
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isSubscribed ? Colors.green.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _isSubscribed ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Text(
                      _isSubscribed ? 'Applied' : 'Subscribe',
                      style: TextStyle(
                        color: _isSubscribed ? Colors.green : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                  50,
                  (_) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                          color: _isSubscribed ? Colors.green.shade300 : Colors.orange.shade300,
                          shape: BoxShape.circle))),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MySubscriptionScreen(
                      userData: {'user_id': userId},
                    ),
                  ),
                );
              },
              child: const Text('View More Plans',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Address ─────────────────────────────────────────────────────────────────

  Widget _buildAddressSection(double w) {
    return Container(
      width: w,
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Address',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on,
                  color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(customerDetails?.name ?? "",
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4)),
                          child: const Text("Order Address",
                              style: TextStyle(
                                  fontSize: 10, color: Colors.black54)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(customerDetails?.phoneNumber ?? "",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(customerDetails?.location ?? "",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.edit,
                  color: Color(0xFF2E7D32), size: 16),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Offers ───────────────────────────────────────────────────────────────────

  Widget _buildOffersSection(double w) {
    return Container(
      width: w,
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          const Row(
            children: [
              Icon(Icons.local_offer,
                  color: Color(0xFF2E7D32), size: 16),
              SizedBox(width: 8),
              Text('Offers',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),

          // ── Coupon input ─────────────────────────────────────────────────────
          const Text('Enter coupon code ( Optional )',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4)),
                  child: TextField(
                    controller: _couponController,
                    enabled: _appliedCoupon == null && !_gbCoinsApplied,
                    decoration: const InputDecoration(
                      hintText: 'Enter Code',
                      hintStyle:
                          TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Show "Remove" if coupon applied, else "Apply"
              _appliedCoupon != null
                  ? GestureDetector(
                      onTap: _removeCoupon,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4)),
                        child: const Center(
                          child: Text('Remove',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14)),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: _handleApplyCoupon,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                            color: _gbCoinsApplied
                                ? Colors.grey
                                : const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(4)),
                        child: const Center(
                          child: Text('Apply',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14)),
                        ),
                      ),
                    ),
            ],
          ),

          // ── Applied coupon badge ──────────────────────────────────────────────
          if (_appliedCoupon != null) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade200)),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'Coupon applied! You save ₹ ${_fmt(_couponDiscount)}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.green)),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // ── GB Coins section ─────────────────────────────────────────────────
          const Text('Use your GB coins and get discount',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Your GB Coins Balance: ',
                  style: TextStyle(fontSize: 12, color: Colors.black54)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(2)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on,
                        size: 12, color: Colors.white),
                    const SizedBox(width: 2),
                    Text(
                      _userCoins > 0 ? _userCoins.toInt().toString() : "0",
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Toggle button — disabled if coupon is active
          GestureDetector(
            onTap: _toggleGbCoins,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _gbCoinsApplied
                    ? const Color(0xFF2E7D32)
                    : Colors.transparent,
                border: Border.all(
                    color: _appliedCoupon != null
                        ? Colors.grey
                        : const Color(0xFF2E7D32)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monetization_on,
                      size: 14,
                      color: _gbCoinsApplied
                          ? Colors.white
                          : _appliedCoupon != null
                              ? Colors.grey
                              : const Color(0xFF2E7D32)),
                  const SizedBox(width: 6),
                  Text(
                    _gbCoinsApplied
                        ? '✓ GB Coins Applied'
                        : 'Use 🪙 GB Coins',
                    style: TextStyle(
                        fontSize: 12,
                        color: _gbCoinsApplied
                            ? Colors.white
                            : _appliedCoupon != null
                                ? Colors.grey
                                : const Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
          ),

          // Mutual exclusion hint
          if (_appliedCoupon != null)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                  '* Remove coupon to use GB Coins',
                  style: TextStyle(fontSize: 11, color: Colors.orange)),
            ),
          if (_gbCoinsApplied) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade200)),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'GB Coins applied! You save ₹ ${_fmt(_cappedActiveDiscount)}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                  '* Remove GB Coins to apply a coupon',
                  style: TextStyle(fontSize: 11, color: Colors.orange)),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Payment summary ──────────────────────────────────────────────────────────

  Widget _buildPaymentSummary(double w) {
    return Container(
      width: w,
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Summary',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 16),

          // Base service amount
          _summaryRow('Service Amount', '₹ ${_fmt(_servicesTotal)}'),
          const SizedBox(height: 8),

          // Addons total (shown only when addons selected)
          if (_addonsTotal > 0) ...[
            _summaryRow('Add-Ons Total', '₹ ${_fmt(_addonsTotal)}'),
            const SizedBox(height: 8),
          ],

          // Subtotal
          _summaryRow('Subtotal', '₹ ${_fmt(_subtotal)}',
              isBold: true),
          const SizedBox(height: 8),

          // Provider discount (if applicable)
          if (_effectiveDiscountPrice > 0) ...[
            _summaryRow(
              'Provider Discount',
              '- ₹ ${_fmt(_effectiveDiscountPrice)}',
              valueColor: Colors.green,
            ),
            const SizedBox(height: 8),
          ],

          // Discount (coupon or GB coins)
          if (_cappedActiveDiscount > 0) ...[
            _summaryRow(
              _gbCoinsApplied ? 'GB Coins Discount' : 'Coupon Discount',
              '- ₹ ${_fmt(_cappedActiveDiscount)}',
              valueColor: Colors.green,
            ),
            const SizedBox(height: 8),
          ],

          // GST 8%
          _summaryRow('GST (8%)', '+ ₹ ${_fmt(_gstAmount)}',
              valueColor: Colors.black54),
          const SizedBox(height: 8),

          // Platform fee
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Platform fee',
                          style: TextStyle(
                              fontSize: 14, color: Colors.black54)),
                      Text(
                        _isSubscribed
                            ? '( Subscribed Member - Waived )'
                            : '( Subscribe and avoid this fee )',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: _isSubscribed ? FontWeight.w600 : FontWeight.normal,
                            color: const Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                  Text(
                    _isSubscribed ? '₹ 0.00' : '+ ₹ ${_fmt(_platformFee)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _isSubscribed ? FontWeight.bold : FontWeight.normal,
                      color: _isSubscribed ? const Color(0xFF2E7D32) : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Off-Hour Convenience Fee (if applicable)
          if (_isOffHour) ...[
            _summaryRow(
              'Off-Hour Fee (8 PM - 8 AM)',
              '+ ₹ ${_fmt(_offHourFee)}',
              valueColor: Colors.orange.shade800,
            ),
            const SizedBox(height: 8),
          ],

          const SizedBox(height: 12),
          Container(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: MyColors.appThemeDark)),
              Text('₹ ${_fmt(_totalAmount)}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 12),

          // Pay now note
          Row(
            children: [
              Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('Amount to pay now: ₹ ${_fmt(_totalAmount)}',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    final style = TextStyle(
        fontSize: 14,
        fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
        color: Colors.black54);
    final valStyle = TextStyle(
        fontSize: 14,
        fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
        color: valueColor ?? Colors.black87);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: valStyle),
      ],
    );
  }

  // ─── Terms ────────────────────────────────────────────────────────────────────

  Widget _buildTermsAndConditions(double w) {
    return Container(
      width: w,
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(4)),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Above price is estimated price only. Actual cost may vary after service completion',
                      style:
                          TextStyle(fontSize: 10, color: Colors.black54)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _termsAccepted,
                onChanged: (v) =>
                    setState(() => _termsAccepted = v ?? false),
                activeColor: const Color(0xFF2E7D32),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54),
                    children: [
                      const TextSpan(text: 'Accept '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, Config.terms),
                          child: const Text('Terms & Conditions',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Pay button ───────────────────────────────────────────────────────────────

  Widget _buildPayButton(double w) {
    return Container(
      width: w,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            _isSubscribed
                ? 'Active subscription applied • Platform fee waived (₹0.00)'
                : 'Please pay platform fee of ₹ ${_fmt(_platformFee)} and place your order',
            style: TextStyle(
              fontSize: 12,
              color: _isSubscribed ? const Color(0xFF2E7D32) : Colors.black54,
              fontWeight: _isSubscribed ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _termsAccepted
                  ? () {
                      Navigator.pushNamed(
                        context,
                        Config.servicePaymentScreen,
                        arguments: {
                          'provider_total_orignal_price': _fmt(_totalAmount),
                          'provider_discount_price': _fmt(_effectiveDiscountPrice),
                          'sub_total': _fmt(_subtotal),
                          'provider_id': providerId,
                          'date': date ?? "",
                          'time': time ?? "",
                          'services': getServices,
                          'user_id': userId ?? "",
                          'main_category_id': mainCategoryId,
                          'addons': selectedAddOns,
                          'location': customerDetails?.location ?? "",
                          'address': customerDetails?.address ?? "",
                          'longitude': customerDetails?.longitude ?? "",
                          'lattitude': customerDetails?.latitude ?? "",
                          'landmark': customerDetails?.landmark ?? "",
                          'platform_fee': _isSubscribed ? '0.00' : _fmt(_platformFee),
                          'off_hour_fee': _fmt(_offHourFee),
                          'gst_amount': _fmt(_gstAmount),
                          'gst_percentage': '8',
                          'coupon_name': _appliedCoupon != null
                              ? (_appliedCoupon!.couponName ?? _couponController.text.trim())
                              : "",
                          'coupon_id': _appliedCoupon?.couponId ?? "",
                          'coupon_amount': _appliedCoupon != null
                              ? _fmt(_couponDiscount)
                              : "0",
                          'gb_coins': _gbCoinsApplied
                              ? _fmt(_cappedActiveDiscount)
                              : "0",
                          'payment_id': _isSubscribed ? "SUBSCRIPTION_COVERED" : "",
                        },
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _isSubscribed ? 'Place Order with Subscription' : 'Pay & Place Order',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}