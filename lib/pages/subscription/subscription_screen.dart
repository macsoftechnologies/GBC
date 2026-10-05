import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/data/prefernces.dart';
import 'package:gobuddy_customer_app/pages/subscription/plan_details.dart';
import 'package:gobuddy_customer_app/pages/subscription_renewal/active_planscreen.dart';
import 'package:gobuddy_customer_app/pages/subscription_renewal/subscription_review.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'dart:convert';

import '../../utils/my_colors.dart';
import 'choose_plan_screen.dart';
import 'package:gobuddy_customer_app/pages/inspectionReport.dart';

class MySubscriptionScreen extends StatefulWidget {
  const MySubscriptionScreen({super.key, required this.userData, this.onBack});
    final Map<String, dynamic>? userData;
    final VoidCallback? onBack;

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen> {
  int _selectedIndex = 2;
  bool is_subscriptions = false; 
  bool isLoading = true;
  List<Map<String, dynamic>> activePlans = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    _checkUserSubscriptions();
  }

  Future<void> _checkUserSubscriptions() async {
    try {
      userId = widget.userData?['user_id']?.toString() ?? widget.userData?['id']?.toString();
      if (userId == null || userId!.isEmpty) {
        userId = await Preferences.getUserID();
      }
      if (userId == null || userId!.isEmpty) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final response = await Repository.postApiRawService(
        EndPoints.getMySubscriptionPlans,
        {"user_id": userId},
      );

      Map<String, dynamic> jsonResponse;
      if (response is String) {
        jsonResponse = jsonDecode(response);
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      } else {
        jsonResponse = {};
      }

      final statusVal = jsonResponse['status'];
      final bool isStatusValid = statusVal == true ||
          statusVal == 'valid' ||
          statusVal == 'true' ||
          
          statusVal == 1 ||
          statusVal == '1' ||
          statusVal == 'success';

      final dynamic rawList = jsonResponse['data'] ?? jsonResponse['subscriptions'] ?? jsonResponse['plans'];
      if (isStatusValid && rawList is List && rawList.isNotEmpty && mounted) {
        setState(() {
          is_subscriptions = true;
          activePlans = rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error checking user subscription: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: MyColors.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: MyColors.appThemeLight),
        ),
      );
    }
    final content = (is_subscriptions && activePlans.isNotEmpty)
        ? _buildCurrentSubscriptions()
        : _buildMySubscriptionScreen();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.onBack != null) {
          widget.onBack!();
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: content,
    );
  }

  Widget _buildCurrentSubscriptions() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final paddingTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: Column(
        children: [
          // App Bar
          _buildCurrentSubscriptionsAppBar(width, height, paddingTop),

          // Body Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: height * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // View Subscription Plans Card
                    _buildViewSubscriptionPlansCard(width, height),

                    SizedBox(height: height * 0.03),

                    // My Active Plans Title
                    Text(
                      'My Active Plans',
                      style: TextStyle(
                        fontSize: width * 0.055,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: height * 0.02),

                    // Active Plan Cards from JSON data
                    ...activePlans.map((plan) => Column(
                      children: [
                        _buildActivePlanCard(width, height, plan),
                        SizedBox(height: height * 0.025),
                      ],
                    )).toList(),

                    SizedBox(height: height * 0.025),

                    // View Inspection Report Button
                    _buildInspectionReportButton(width, height),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMySubscriptionScreen() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(width, height),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: height * 0.06),
                   
                    SizedBox(height: height * 0.02),
                    _buildIllustration(width, height),
                    SizedBox(height: height * 0.05),
                    _buildMainTitle(width),
                    SizedBox(height: height * 0.02),
                    _buildSubtitle(width),
                    _buildKnowMoreButton(),
                    SizedBox(height: height * 0.03),
                    _buildGetSubscriptionButton(width, height),
                    SizedBox(height: height * 0.02),
                    _buildGetSubscriptionButton2(width, height),
                    SizedBox(height: height * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Current Subscriptions Widgets
  Widget _buildCurrentSubscriptionsAppBar(double width, double height, double paddingTop) {
    return Container(
      width: width,
      height: height * 0.13 + paddingTop, // Add status bar height
      padding: EdgeInsets.only(top: paddingTop), // Padding for status bar
      decoration: const BoxDecoration(color: MyColors.appThemeLight),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: widget.onBack ?? () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushNamedAndRemoveUntil(context, Config.homeRouteName, (route) => false);
                }
              },
              child: Container(
                width: width * 0.12,
                height: width * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),

            SizedBox(width: width * 0.05),

            // Title
            Expanded(
              child: Text(
                'My Subscription',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewSubscriptionPlansCard(double width, double height) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChoosePlanScreen(userData: widget.userData),
          ),
        );
        if (mounted) _checkUserSubscriptions();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.02,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: width * 0.12,
              height: width * 0.12,
              padding: EdgeInsets.all(width * 0.02),
              decoration: BoxDecoration(
                color: const Color(0xFF00A651).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: const Color(0xFF00A651),
                    size: width * 0.06,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A651),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: width * 0.03,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: width * 0.04),

            // Text
            Expanded(
              child: Text(
                'View Subscription Plans',
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: width * 0.05,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePlanCard(double width, double height, Map<String, dynamic> plan) {
    return Container(
      width: width,
      padding: EdgeInsets.all(width * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan Name and Validity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (plan['plan_name'] ?? plan['planName'] ?? 'Subscription Plan').toString(),
                style: TextStyle(
                  fontSize: width * 0.055,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Valid till  ',
                      style: TextStyle(
                        fontSize: width * 0.038,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: (plan['valid_till'] ?? plan['end_date'] ?? plan['endDate'] ?? 'N/A').toString(),
                      style: TextStyle(
                        fontSize: width * 0.038,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: height * 0.01),

          // Duration and Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (plan['duration'] ?? plan['plan_type'] ?? plan['planType'] ?? 'N/A').toString(),
                style: TextStyle(
                  fontSize: width * 0.042,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                plan['price']?.toString() ??
                    (plan['amount'] != null ? '₹${plan['amount']}' : '₹0'),
                style: TextStyle(
                  fontSize: width * 0.06,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: height * 0.02),

          // Buttons
          Row(
            children: [
              // Active Badge
              Builder(
                builder: (context) {
                  final statusText = (plan['status'] ?? 'Active').toString();
                  final isCancelled = statusText.toLowerCase() == 'cancelled';
                  
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: height * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: isCancelled ? Colors.red : _getStatusColor(plan['status_color']),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: width * 0.031,
                        fontWeight: FontWeight.w600,
                        color: isCancelled ? Colors.white : MyColors.appThemeDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                }
              ),

              SizedBox(width: width * 0.03),

              // View Details Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _viewPlanDetails(plan);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(vertical: height * 0.012),
                  ),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: width * 0.03,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SizedBox(width: width * 0.03),

              // Upgrade Plan Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _upgradePlan(plan);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFB74D)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(vertical: height * 0.012),
                  ),
                  child: Text(
                    'Upgrade Plan',
                    style: TextStyle(
                      fontSize: width * 0.03,
                      color: const Color(0xFFFFB74D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionReportButton(double width, double height) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: () {
          _viewInspectionReport();
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF00A651), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: height * 0.02),
          backgroundColor: Colors.white,
        ),
        child: Text(
          'View Inspection Report',
          style: TextStyle(
            fontSize: width * 0.04,
            color: const Color(0xFF00A651),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(dynamic colorHex) {
    if (colorHex == null) {
      return const Color(0xFF5CF26E); // Default color
    }
    try {
      String hex = colorHex.toString().trim().replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse('0x$hex'));
    } catch (e) {
      return const Color(0xFF5CF26E); // Default color
    }
  }

  void _viewPlanDetails(Map<String, dynamic> plan) async {
    final subId = plan['subscription_id']?.toString() ??
        plan['subscriptionId']?.toString() ??
        plan['id']?.toString() ??
        '';
    final subStatus = plan['status']?.toString() ?? 'Active';
    if (subId.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubscriptionOverview(
            subscriptionId: subId,
          ),
        ),
      );
      if (mounted) _checkUserSubscriptions();
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlanDetails()),
      );
      if (mounted) _checkUserSubscriptions();
    }
  }

  void _upgradePlan(Map<String, dynamic> plan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChoosePlanScreen(userData: widget.userData),
      ),
    );
    if (mounted) _checkUserSubscriptions();
  }

  void _viewInspectionReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Inspectionreport()),
    );
  }

  Widget _buildGetSubscriptionButton2(double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: ElevatedButton(
        onPressed: () async {
          
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivePlanscreen(userData : widget.userData ),
            ),
          );
          if (mounted) _checkUserSubscriptions();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.appThemeLight,
          foregroundColor: Colors.black,
          minimumSize: Size(width * 0.9, height * 0.07),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          'View My Subscriptions ',
          style: TextStyle(
            fontSize: width * 0.048,
            fontWeight: FontWeight.w600,
            color :Colors.white
          ),
        ),
      ),
    );
  }

  // Original MySubscriptionScreen Widgets
  Widget _buildIllustration(double width, double height) {
    return Container(
      width: width * 0.7,
      height: height * 0.25,
      child: Image.network(
        'https://www.appsflyer.com/wp-content/uploads/2023/07/51800-Subscription-based-apps-1024x538.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildAppBar(double width, double height) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.015,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF00A651),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: widget.onBack ?? () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushNamedAndRemoveUntil(context, Config.homeRouteName, (route) => false);
              }
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: width * 0.12,
              height: width * 0.12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'My Subscription',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: width * 0.12),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircle(double size, Color color,
      {double? left, double? right, double? top, double? bottom}) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildStar(double size,
      {double? left, double? right, double? top, double? bottom}) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Icon(
        Icons.star,
        color: const Color(0xFFFFC107),
        size: size,
      ),
    );
  }

  Widget _buildMainTitle(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
      child: Text(
        'Save time & money with subscription-based bundled services!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: width * 0.058,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C3E50),
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildSubtitle(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
      child: Text(
        'Transform your House into Home and discover piece of mind with our subscription packages tailored to fit your needs.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: width * 0.04,
          color: const Color(0xFF95A5A6),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildKnowMoreButton() {
    return TextButton.icon(
      onPressed: _showSubscriptionBenefitsDialog,
      icon: const Icon(Icons.info_outline, color: Color(0xFFFF9800), size: 18),
      label: const Text(
        'Know More & Benefits',
        style: TextStyle(
          color: Color(0xFFFF9800),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFFFF9800),
          decorationThickness: 2,
        ),
      ),
    );
  }

  void _showSubscriptionBenefitsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.verified_outlined, color: Color(0xFFFF9800), size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    "Subscription Benefits",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.darkGray),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _benefitRow(Icons.build_circle_outlined, "Scheduled Property Inspections", "Periodic health checks for electrical, plumbing, and structural maintenance."),
            _benefitRow(Icons.money_off_csred_outlined, "Zero Platform Fees", "Enjoy 100% waiver on platform fees across all service bookings."),
            _benefitRow(Icons.bolt_outlined, "Priority Service Dispatch", "Get first-priority booking slots and immediate provider allocation."),
            _benefitRow(Icons.discount_outlined, "Exclusive Member Discounts", "Save up to 30% on repairs, add-ons, and seasonal maintenance."),
            const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChoosePlanScreen(userData: widget.userData ?? {}),
                      ),
                    );
                    if (mounted) _checkUserSubscriptions();
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("Explore Plans", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _benefitRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00A651), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetSubscriptionButton(double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChoosePlanScreen(userData: {}),
            ),
          );
          if (mounted) _checkUserSubscriptions();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9800),
          foregroundColor: Colors.white,
          minimumSize: Size(width * 0.9, height * 0.07),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          'Get Subscriptions',
          style: TextStyle(
            fontSize: width * 0.048,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class ShoppingBagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE91E63)
      ..style = PaintingStyle.fill;

    final handlePaint = Paint()
      ..color = const Color(0xFFE91E63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.15);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.05,
      size.width * 0.5,
      size.height * 0.05,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.05,
      size.width * 0.7,
      size.height * 0.15,
    );

    canvas.drawPath(path, handlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GiftBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFEB3B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}