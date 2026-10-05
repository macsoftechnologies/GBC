
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/data/prefernces.dart';
import 'package:gobuddy_customer_app/models/getall_subscriptions_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';

import '../../utils/my_colors.dart';
import 'custom_plan_services.dart';
import 'subscription_summary.dart';


class CustomPlanModel {
  final String heading;
  final String description;
  final String buttonText;

  CustomPlanModel({
    required this.heading,
    required this.description,
    required this.buttonText,
  });
}

class ChoosePlanScreen extends StatefulWidget {
  const ChoosePlanScreen({
    super.key,
    required this.userData,
    this.activePlans,
    this.currentActivePlan,
  });
  final Map<String, dynamic>? userData;
  final List<Map<String, dynamic>>? activePlans;
  final Map<String, dynamic>? currentActivePlan;

  @override
  State<ChoosePlanScreen> createState() => _ChoosePlanScreenState();
}

class _ChoosePlanScreenState extends State<ChoosePlanScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  String _selectedHouseType = '1BHK';
  List<String> _houseTypes = ['1BHK', '2BHK', '3BHK'];

  // Key = planIndex in allPlans → selected DurationPrice index
  final Map<int, int> _selectedDurationIndex = {};

  bool isLoading = false;
  List<dynamic> allPlans = [];
  List<Map<String, dynamic>> _userActivePlans = [];

  final CustomPlanModel customPlan = CustomPlanModel(
    heading: 'Custom',
    description: 'Pick the services you need and\nbuild your package',
    buttonText: 'Create Package',
  );

  Future<void> _getAllSubscriptionPlans() async {
    final bool internet = await UtilClass.checkInternet();
    if (!internet) {
      UtilClass.showAlertDialog(context: context, message: "No Internet Connection!");
      return;
    }
    setState(() => isLoading = true);
    try {
      final response =
          await Repository.getApiService(EndPoints.getAllSubscriptionPlans);

      late Map<String, dynamic> jsonResponse;
      if (response is String) {
        jsonResponse = json.decode(response);
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      } else {
        throw Exception("Unexpected response type: ${response.runtimeType}");
      }

      final subscriptions = GetAllSubscriptions.fromJson(jsonResponse);

      if (subscriptions.status) {
        if (!mounted) return;
        final allApiPlans = subscriptions.data.toList();

        // Dynamically extract unique house types from API plans
        final List<String> extractedTypes = [];
        for (final p in allApiPlans) {
          for (final htp in p.pricing) {
            final ht = htp.houseType.trim();
            if (ht.isNotEmpty && !extractedTypes.contains(ht)) {
              extractedTypes.add(ht);
            }
          }
        }

        setState(() {
          allPlans = [...allApiPlans, customPlan];
          if (extractedTypes.isNotEmpty) {
            _houseTypes = extractedTypes;
            if (!_houseTypes.any((ht) =>
                ht.replaceAll(' ', '').toUpperCase() ==
                _selectedHouseType.replaceAll(' ', '').toUpperCase())) {
              _selectedHouseType = _houseTypes.first;
            }
          }
        });
      } else {
        UtilClass.showAlertDialog(
          context: context,
          message: subscriptions.message.isNotEmpty
              ? subscriptions.message
              : "Failed to load subscriptions",
        );
      }
    } catch (e, st) {
      debugPrint("Error fetching subscriptions: $e\n$st");
      UtilClass.showAlertDialog(
        context: context,
        message: "Something went wrong while fetching plans.",
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ── Pricing helpers ───────────────────────────────────────────────────────
  List<DurationPrice> _availablePrices(SubscriptionPlan plan) {
    final block = plan.pricingFor(_selectedHouseType);
    if (block == null) return [];
    return block.prices.where((p) => p.isAvailable).toList();
  }

  int _safeDurationIdx(SubscriptionPlan plan, int planIndex) {
    final prices = _availablePrices(plan);
    if (prices.isEmpty) return 0;
    final stored = _selectedDurationIndex[planIndex] ?? 0;
    return stored.clamp(0, prices.length - 1);
  }

  DurationPrice? _selectedPrice(SubscriptionPlan plan, int planIndex) {
    final prices = _availablePrices(plan);
    if (prices.isEmpty) return null;
    return prices[_safeDurationIdx(plan, planIndex)];
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _userActivePlans = widget.activePlans != null
        ? List<Map<String, dynamic>>.from(widget.activePlans!)
        : [];
    _fetchUserActivePlans();
    _getAllSubscriptionPlans();
    _pageController.addListener(() {
      final next = _pageController.page!.round();
      if (_currentPage != next) setState(() => _currentPage = next);
    });
  }

  Future<void> _fetchUserActivePlans() async {
    try {
      String? uid = widget.userData?['user_id']?.toString() ??
          widget.userData?['id']?.toString();
      if (uid == null || uid.isEmpty) {
        uid = await Preferences.getUserID();
      }
      if (uid == null || uid.isEmpty) return;

      final response = await Repository.postApiRawService(
        EndPoints.getMySubscriptionPlans,
        {"user_id": uid},
      );

      Map<String, dynamic> jsonResponse;
      if (response is String) {
        jsonResponse = jsonDecode(response);
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      } else {
        return;
      }

      final statusVal = jsonResponse['status'];
      final bool isStatusValid = statusVal == true ||
          statusVal == 'valid' ||
          statusVal == 'true' ||
          statusVal == 1 ||
          statusVal == '1' ||
          statusVal == 'success';

      final dynamic rawList = jsonResponse['data'] ??
          jsonResponse['subscriptions'] ??
          jsonResponse['plans'];
      if (isStatusValid && rawList is List && mounted) {
        setState(() {
          _userActivePlans =
              rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching active plans: $e");
    }
  }

  Map<String, dynamic>? _getActivePlanFor(SubscriptionPlan plan) {
    if (_userActivePlans.isEmpty) return null;
    for (final ap in _userActivePlans) {
      final apPlanId =
          ap['plan_id']?.toString() ?? ap['planId']?.toString() ?? '';
      final apPlanName = (ap['plan_name']?.toString() ??
              ap['planName']?.toString() ??
              '')
          .trim()
          .toLowerCase();
      final currentPlanName = plan.planName.trim().toLowerCase();
      final currentPlanId = plan.id.trim();

      final bool idMatch = currentPlanId.isNotEmpty &&
          apPlanId.isNotEmpty &&
          currentPlanId == apPlanId;
      final bool nameMatch = currentPlanName.isNotEmpty &&
          apPlanName.isNotEmpty &&
          (currentPlanName == apPlanName ||
              currentPlanName.contains(apPlanName) ||
              apPlanName.contains(currentPlanName));

      if (idMatch || nameMatch) {
        final status = (ap['status']?.toString() ?? 'active').toLowerCase();
        if (status == 'active' ||
            status == '1' ||
            status == 'valid' ||
            status == 'success') {
          return ap;
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── House-type bottom sheet ───────────────────────────────────────────────
  void _showHouseTypeBottomSheet() {
    String tempSelected = _selectedHouseType;
    const proceedGreen = Color(0xFF00A651);
    const proceedGrey = Color(0xFFBDBDBD);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModal) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Select House Type',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: _houseTypes.map((ht) {
                        return ListTile(
                          title: Text(ht,
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF2C3E50))),
                          trailing: Radio<String>(
                            value: ht,
                            groupValue: tempSelected,
                            activeColor: proceedGreen,
                            onChanged: (v) =>
                                setModal(() => tempSelected = v ?? ht),
                          ),
                          onTap: () => setModal(() => tempSelected = ht),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedHouseType = tempSelected;
                            _selectedDurationIndex.clear();
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: proceedGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: const Text('Proceed',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00A651)))
            : Column(
                children: [
                  _buildAppBar(w, h),
                  SizedBox(height: h * 0.015),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: allPlans.length,
                      itemBuilder: (context, index) {
                        final plan = allPlans[index];
                        if (plan is SubscriptionPlan) {
                          return _buildPlanCard(plan, w, h, index);
                        } else if (plan is CustomPlanModel) {
                          return _buildCustomPlanCard(w, h, index);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  _buildPageIndicator(w),
                  SizedBox(height: h * 0.02),
                ],
              ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar(double w, double h) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.09, vertical: h * 0.01),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: w * 0.10,
              height: w * 0.10,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 5,
                      offset: const Offset(0, 1))
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  color: const Color(0xFF00A651), size: w * 0.045),
            ),
          ),
          SizedBox(width: w * 0.05),
          Text('Choose Plan',
              style: TextStyle(
                  color: const Color(0xFF2C3E50),
                  fontSize: w * 0.05,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
        ],
      ),
    );
  }

  // ── Standard Plan Card ────────────────────────────────────────────────────
  Widget _buildPlanCard(SubscriptionPlan plan, double w, double h, int index) {
    final scale = _currentPage == index ? 1.0 : 0.95;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: h * 0.005),
        child: Card(
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: const BorderSide(color: Colors.grey, width: 0.2),
          ),
          child: Column(
            children: [
              // ── White header ──
              _buildCardHeader(w, h, plan, index),

              // ── Green body: services list + duration chips ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.green[50]),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: w * 0.05, vertical: h * 0.018),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Services count badge + list ──
                        _buildServicesList(plan, w, h),
                        SizedBox(height: h * 0.018),
                        // ── Duration selector chips ──
                        _buildDurationChips(plan, w, h, index),
                      ],
                    ),
                  ),
                ),
              ),

              // ── White footer: Get Plan button ──
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.1, vertical: h * 0.025),
                  child: _buildGetPlanButton(w, h, plan, index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card Header ───────────────────────────────────────────────────────────
  Widget _buildCardHeader(double w, double h, SubscriptionPlan plan, int index) {
    final selPrice = _selectedPrice(plan, index);
    final priceText = selPrice?.displayAmount ?? '—';
    final activePlan = _getActivePlanFor(plan);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      padding: EdgeInsets.fromLTRB(w * 0.05, h * 0.025, w * 0.05, h * 0.015),
      child: Column(
        children: [
          // Image + Plan name
          Row(
            children: [
              Container(
                width: w * 0.12,
                height: w * 0.12,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  plan.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      size: 30,
                      color: Colors.grey),
                ),
              ),
              SizedBox(width: w * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.planName,
                      style: TextStyle(
                        color: MyColors.appThemeLight,
                        fontSize: w * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (activePlan != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF00A651), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                color: Color(0xFF00A651), size: 12),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                activePlan['valid_till'] != null
                                    ? 'Active till ${activePlan['valid_till']}'
                                    : 'Currently Active',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF00A651),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.015),

          // Price — animates when house type or duration changes
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Row(
              key: ValueKey(
                  '$_selectedHouseType-${_safeDurationIdx(plan, index)}'),
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  priceText == '—' ? '' : '₹',
                  style: TextStyle(
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  priceText,
                  style: TextStyle(
                    fontSize: w * 0.07,
                    fontWeight: FontWeight.bold,
                    color: priceText == '—'
                        ? Colors.grey
                        : const Color(0xFF2C3E50),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: h * 0.006),

          // House-type selector
          InkWell(
            onTap: _showHouseTypeBottomSheet,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: w * 0.02, vertical: h * 0.005),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '($_selectedHouseType)',
                    style: TextStyle(
                      fontSize: w * 0.035,
                      color: const Color(0xFF7F8C8D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: w * 0.015),
                  Icon(Icons.keyboard_arrow_down,
                      size: w * 0.04, color: const Color(0xFF7F8C8D)),
                ],
              ),
            ),
          ),
          SizedBox(height: h * 0.008),
        ],
      ),
    );
  }

  // ── Services List ─────────────────────────────────────────────────────────
  Widget _buildServicesList(SubscriptionPlan plan, double w, double h) {
    final services = plan.services;
    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: "What's Included" label + count badge
        Row(
          children: [
            Text(
              "What's Included",
              style: TextStyle(
                fontSize: w * 0.036,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
            SizedBox(width: w * 0.02),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: w * 0.025, vertical: h * 0.003),
              decoration: BoxDecoration(
                color: const Color(0xFF00A651),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${services.length} items',
                style: TextStyle(
                  fontSize: w * 0.028,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: h * 0.01),
        // Service rows — each as a check-circle row
        ...services.map((service) => Padding(
              padding: EdgeInsets.only(bottom: h * 0.008),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle,
                      color: Color(0xFF00A651), size: 16),
                  SizedBox(width: w * 0.025),
                  Expanded(
                    child: Text(
                      service.serviceName,
                      style: TextStyle(
                        fontSize: w * 0.033,
                        color: const Color(0xFF2C3E50),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ── Duration Chips ────────────────────────────────────────────────────────
  Widget _buildDurationChips(
      SubscriptionPlan plan, double w, double h, int planIndex) {
    final prices = _availablePrices(plan);

    if (prices.isEmpty) {
      final noPricingAtAll = plan.pricing.isEmpty;
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: h * 0.02),
          child: Column(
            children: [
              Icon(
                noPricingAtAll ? Icons.hourglass_empty : Icons.info_outline,
                color: Colors.grey[400],
                size: w * 0.07,
              ),
              SizedBox(height: h * 0.008),
              Text(
                noPricingAtAll
                    ? 'Pricing coming soon'
                    : 'No pricing available for $_selectedHouseType',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: w * 0.033,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final selIdx = _safeDurationIdx(plan, planIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider between services and durations
        Divider(height: 1, thickness: 1, color: Colors.green[100]!),
        SizedBox(height: h * 0.012),
        Text(
          'Select Duration',
          style: TextStyle(
            fontSize: w * 0.036,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: h * 0.012),
        Wrap(
          spacing: w * 0.025,
          runSpacing: h * 0.01,
          children: List.generate(prices.length, (i) {
            final isSelected = i == selIdx;
            final dp = prices[i];

            return GestureDetector(
              onTap: () => setState(() => _selectedDurationIndex[planIndex] = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                    horizontal: w * 0.05, vertical: h * 0.009),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00A651) : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00A651)
                        : const Color(0xFFBDBDBD),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00A651).withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dp.duration,
                      style: TextStyle(
                        fontSize: w * 0.033,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      '₹${dp.displayAmount}',
                      style: TextStyle(
                        fontSize: w * 0.028,
                        color: isSelected
                            ? Colors.white.withOpacity(0.85)
                            : const Color(0xFF00A651),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),

        // Discount badge (only for plans with discount data)
        if (_selectedPrice(plan, planIndex)?.discount != null) ...[
          SizedBox(height: h * 0.012),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: w * 0.03, vertical: h * 0.006),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFF00A651).withOpacity(0.4), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_offer_outlined,
                    color: Color(0xFF00A651), size: 14),
                SizedBox(width: w * 0.015),
                Text(
                  '${_selectedPrice(plan, planIndex)!.discount}% off  •  '
                  'Final ₹${_selectedPrice(plan, planIndex)!.finalAmount?.toStringAsFixed(0) ?? ''}',
                  style: TextStyle(
                    fontSize: w * 0.031,
                    color: const Color(0xFF00A651),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Get Plan Button ───────────────────────────────────────────────────────
  Widget _buildGetPlanButton(double w, double h, SubscriptionPlan plan, int index) {
    final activePlan = _getActivePlanFor(plan);
    if (activePlan != null) {
      return SizedBox(
        width: double.infinity,
        height: 45,
        child: OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF00A651)),
                    SizedBox(width: 8),
                    Text("Plan Already Active"),
                  ],
                ),
                content: Text(
                  "You currently have an active subscription for ${plan.planName}"
                  "${activePlan['valid_till'] != null ? ' (valid until ${activePlan['valid_till']})' : ''}.\n\n"
                  "You cannot purchase the same plan while it is active. To change services or upgrade, please select a different plan.",
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A651),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.check_circle,
              color: Color(0xFF00A651), size: 18),
          label: const Text(
            "Current Plan (Active)",
            style: TextStyle(
              color: Color(0xFF00A651),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF00A651), width: 1.5),
            backgroundColor: const Color(0xFFE8F5E9),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
          ),
        ),
      );
    }

    final selPrice = _selectedPrice(plan, index);

    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: selPrice == null
            ? null
            : () {
                final List<Map<String, dynamic>> serviceDestructure =
                    plan.services.map((s) => {
                          "service_id": s.id,
                          "service_name": s.serviceName,
                          "price":
                              double.tryParse(s.servicePrice) ?? 0.0,
                          "quantity": 0,
                        }).toList();

                final Map<String, dynamic> completePlan = {
                  "services_data": serviceDestructure,
                  "plan_name": plan.planName,
                  "plan_data": {
                    'duration': selPrice.duration,
                    'validity': selPrice.months?.toString() ?? '',
                    'price': selPrice.displayAmount,
                    'plan_id': plan.id,
                    'house_type': _selectedHouseType,
                  },
                  "selected_duration": selPrice.duration,
                  "selected_price":
                      double.tryParse(selPrice.displayAmount) ?? 0.0,
                  "final_price": selPrice.finalAmount,
                  "discount": selPrice.discount,
                  "house_type": _selectedHouseType,
                };

                Navigator.pushNamed(
                  context,
                  Config.subscriptionSummary,
                  arguments: {
                    'completed_packed_plan': completePlan,
                    'user_id': widget.userData?['user_id'] ?? "",
                  },
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: selPrice == null ? Colors.grey[300] : Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          elevation: 0,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
        ),
        child: Text(
          selPrice == null
              ? 'Not Available'
              : (_userActivePlans.isNotEmpty
                  ? 'Upgrade to ${plan.planName}'
                  : 'Get Plan'),
          style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ── Custom Plan Card (100% UNCHANGED) ─────────────────────────────────────
  Widget _buildCustomPlanCard(double w, double h, int index) {
    final scale = _currentPage == index ? 1.0 : 0.95;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: h * 0.005),
        child: Card(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          child: Column(
            children: [
              // Top White Section
              Container(
                height: h * 0.2,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Text(
                  "Custom",
                  style: TextStyle(
                    color: const Color(0xFF1C2834),
                    fontSize: w * 0.07,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Middle Light Green Section
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: MyColors.lightMintGreen,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Pick the services you need and build your package",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: w * 0.04,
                          color: const Color(0xFF263238),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom White Section with Button
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.1,
                    vertical: h * 0.03,
                  ),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CustomPlanServices()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFF1C2834), width: 1.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      padding: EdgeInsets.symmetric(
                          vertical: h * 0.018, horizontal: w * 0.02),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      "Create Package",
                      style: TextStyle(
                        color: const Color(0xFF1C2834),
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Page Indicator ────────────────────────────────────────────────────────
  Widget _buildPageIndicator(double w) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(allPlans.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: w * 0.01),
          width: _currentPage == index ? w * 0.05 : w * 0.015,
          height: w * 0.015,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFF00A651)
                : const Color(0xFFBDBDBD),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}