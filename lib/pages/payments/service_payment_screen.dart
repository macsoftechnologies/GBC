import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:gobuddy_customer_app/components/custom_back_button.dart';
import 'package:gobuddy_customer_app/models/payment_arguments_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/data/prefernces.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ServicePaymentScreen extends StatefulWidget {
  const ServicePaymentScreen({super.key});

  @override
  State<ServicePaymentScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<ServicePaymentScreen> {
  PaymentMethod? selectedPaymentMethod = PaymentMethod.phonePe;

  String? totalPay;
  String? paymentId;

  late PaymentArguments paymentData;

  late Razorpay _razorpay;
  static const String _razorpayKey = 'rzp_test_B54BlMynixkzHI';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccessResponse);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentErrorResponse);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWalletResponse);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    debugPrint("RAW ARGS RECEIVED: $args");

    if (args == null) return;

    paymentData = PaymentArguments.fromMap(args);
    totalPay = paymentData.providerTotalOriginalPrice;

    if (paymentData.paymentId == 'SUBSCRIPTION_COVERED') {
      paymentId = 'SUBSCRIPTION_COVERED';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _completeOrder();
      });
    }
  }

  // ---------------------------
  // COMPLETE ORDER API
  // ---------------------------
  Future<void> _completeOrder() async {
    bool internet = await UtilClass.checkInternet();
    if (!internet) {
      UtilClass.showAlertDialog(
          context: context, message: "No Internet Connection");
      return;
    }

    try {
      // Format date and time for API
      DateTime parsedDateTime = DateTime.parse(paymentData.date); // ISO string
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDateTime);
      String formattedTime = DateFormat('HH:mm:ss').format(
        DateFormat('hh:mm a').parse(paymentData.time), // "11:00 AM" -> 24h
      );

      // Debug: inspect the raw shape of services/addons before mapping.
      // Remove these prints once you've confirmed the shape is correct.
      print("services raw: ${paymentData.services}");
      print("addons raw: ${paymentData.addons}");

      // Map services safely — guards against a List/Map shape mismatch,
      // which is what causes "type 'String' is not a subtype of type 'int'"
      List<Map<String, dynamic>> apiServices =
          paymentData.services.map((service) {
        if (service is! Map) {
          throw Exception(
              "Expected a Map for service, got ${service.runtimeType}: $service");
        }
        final s = Map<String, dynamic>.from(service);
        return {
          "category_id": int.tryParse(s["main_category_id"].toString()) ?? 0,
          "sub_category_id":
              int.tryParse(s["sub_category_id"]?.toString() ?? "0") ?? 0,
          "service_id": int.tryParse(s["id"].toString()) ?? 0,
          "quantity": s["quantity"].toString(),
        };
      }).toList();

      // Map addons safely — same guard as above
      List<Map<String, dynamic>> apiAddons = paymentData.addons.map((addon) {
        if (addon is! Map) {
          throw Exception(
              "Expected a Map for addon, got ${addon.runtimeType}: $addon");
        }
        final a = Map<String, dynamic>.from(addon);
        return {
          "category_id": int.tryParse(a["category_id"].toString()) ?? 0,
          "addon_id": int.tryParse(a["addon_id"].toString()) ?? 0,
          "price": double.tryParse(a["price"].toString()) ?? 0,
        };
      }).toList();

      final requestBody = {
        "user_id": paymentData.userId,
        "schedule_date": formattedDate,
        "schedule_time": formattedTime,
        "provider_id": paymentData.providerId,
        "coupon_id": paymentData.couponId,
        "coupon_name": paymentData.couponName,
        "coupon_amount": paymentData.couponAmount,
        "payment_id": paymentId ?? (paymentData.paymentId.isNotEmpty ? paymentData.paymentId : "PAY_${DateTime.now().millisecondsSinceEpoch}"),
        "gb_coins": paymentData.gbCoins,
        "platform_fee": paymentData.platformFee,
        "sub_total": paymentData.subTotal.isNotEmpty ? paymentData.subTotal : paymentData.providerTotalOriginalPrice,
        "total_amount": paymentData.providerTotalOriginalPrice,
        "discount_amount": paymentData.providerDiscountPrice,
        "gst_amount": paymentData.gstAmount,
        "off_hour_fee": paymentData.offHourFee,
        "address": paymentData.address,
        "latitude": paymentData.latitude,
        "longitude": paymentData.longitude,
        "landmark": paymentData.landmark,
        "location": paymentData.location,
        "services": apiServices,
        "addons": apiAddons,
      };

      // Debug: confirm what's actually being sent
      print("Request Body: ${jsonEncode(requestBody)}");

   final rawResponse = await Repository.postApiRawService(
  EndPoints.postAllserviceDataoder,
  requestBody,
);

final response = rawResponse is String
    ? jsonDecode(rawResponse) as Map<String, dynamic>
    : rawResponse as Map<String, dynamic>;

print("Decoded Response: $response");

final bool isSuccess = response["status"] == "success" ||
    response["status"] == "valid" ||
    response["status"] == true ||
    response["status"] == "1";

if (isSuccess) {
  final orderId = response['job_calender_id']?.toString() ??
      response['oder_id']?.toString() ??
      response['order_id']?.toString() ??
      "";
  if (mounted) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Close loading dialog
    }
    Navigator.pushReplacementNamed(
      context,
      Config.afterPaymentScreen,
      arguments: {
        'user_id': paymentData.userId,
        'payment_id': paymentId,
        'oder_id': orderId,
        'job_calender_id': orderId,
      },
    );
  }
} else {
  if (mounted) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Close loading dialog
    }
    UtilClass.showAlertDialog(
      context: context,
      message: response["message"] ?? "Order placement failed. Please contact support.",
    );
  }
}
    } catch (e, stack) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // Close loading dialog on error
      }
      print("Error in _completeOrder: $e");
      print(stack);
      UtilClass.showAlertDialog(
        context: context,
        message: "Something went wrong. Please try again.",
      );
    }
  }

  void callRagerPayment(String totalPay) async {
    double amountDouble = double.tryParse(totalPay) ?? 0;
    if (amountDouble <= 0) {
      UtilClass.showAlertDialog(
          context: context, message: "Invalid payment amount");
      return;
    }

    String contactPhone = (await Preferences.getPhone()) ?? '';
    String contactEmail = (await Preferences.getEmail()) ?? '';

    var options = {
      'key': _razorpayKey,
      'amount': (amountDouble * 100).round(),
      'name': 'Go buddy',
      'description': 'Service Booking Payment',
      'currency': 'INR',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        if (contactPhone.isNotEmpty) 'contact': contactPhone,
        if (contactEmail.isNotEmpty) 'email': contactEmail,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("ERROR OPENING RAZORPAY: $e");
    }
  }

  void _handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    paymentId = response.paymentId;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  SizedBox(height: 16),
                  Text(
                    "Confirming your order...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    await _completeOrder();
  }

  void _handlePaymentErrorResponse(PaymentFailureResponse response) {
    debugPrint("Razorpay Error: code=${response.code}, message=${response.message}");

    // If using test key and payment is cancelled/failed (common in testing environments)
    if (_razorpayKey.startsWith('rzp_test_')) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 8),
              Text("Payment Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            "Payment was not completed (${response.message ?? 'Cancelled'}).\n\n"
            "Because you are using a Razorpay Testing Key, real banking apps cancel test requests.\n\n"
            "Would you like to complete this booking with a Test Payment?",
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _simulateTestPayment();
              },
              child: const Text("Complete Test Order", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      UtilClass.showAlertDialog(
          context: context, message: "Payment Failed: ${response.message}");
    }
  }

  void _handleExternalWalletResponse(ExternalWalletResponse response) {
    UtilClass.showAlertDialog(
        context: context, message: "External Wallet Selected: ${response.walletName}");
  }

  void _simulateTestPayment() async {
    paymentId = "PAY_TEST_${DateTime.now().millisecondsSinceEpoch}";
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  SizedBox(height: 16),
                  Text(
                    "Placing your order (Test Mode)...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    await _completeOrder();
  }

  // ---------------------------
  // UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildUPISection(),
            Expanded(child: _buildPaymentMethods()),
            _buildBottomPaymentSection(),
          ],
        ),
      ),
    );
  }

  // ------------------ UI Widgets ------------------

  Widget _buildHeader() {
    return Row(
      children: const [
        SizedBox(width: 16),
        CustomBackButton(),
        SizedBox(width: 10),
        Text('Choose how to pay',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildUPISection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Image.asset("assets/images/UPi.png", width: 40, height: 24),
          const SizedBox(width: 12),
          const Text("UNIFIED PAYMENTS INTERFACE",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _tile(PaymentMethod.phonePe, "PhonePe", "assets/images/PhonePe.png"),
          const Divider(),
          _tile(PaymentMethod.googlePay, "Google Pay",
              "assets/images/GooglePay.png"),
          const Divider(),
          _tile(PaymentMethod.paytm, "Paytm", "assets/images/Paytm.png"),
          const Divider(),
          _tile(PaymentMethod.upiId, "Enter UPI ID", null),
        ],
      ),
    );
  }

  Widget _tile(PaymentMethod method, String title, String? icon) {
    bool selected = selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () => setState(() => selectedPaymentMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            icon != null
                ? Image.asset(icon, width: 40)
                : const Icon(Icons.add, size: 40, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            CircleAvatar(
              radius: 10,
              backgroundColor: selected ? Colors.green : Colors.transparent,
              child: selected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPaymentSection() {
    final isTestMode = _razorpayKey.startsWith('rzp_test_');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("₹ $totalPay",
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text("To be paid now",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => callRagerPayment(totalPay.toString()),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
                child: const Text("Pay",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          if (isTestMode) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF2E7D32)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _simulateTestPayment,
                label: const Text("Place Order with Test Key (Simulate Payment)",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum PaymentMethod { phonePe, googlePay, paytm, upiId }
