import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/models/getmyplans_model.dart';
import 'package:gobuddy_customer_app/pages/inspectionReport.dart';
import 'package:gobuddy_customer_app/pages/subscription/choose_plan_screen.dart';
import 'package:gobuddy_customer_app/pages/subscription/subscription_screen.dart';
import 'package:gobuddy_customer_app/pages/subscription_renewal/subscription_review.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';

class ActivePlanscreen extends StatefulWidget {
  const ActivePlanscreen({super.key, required this.userData});

  final Map<String, dynamic>? userData;

  @override
  State<ActivePlanscreen> createState() => _ActivePlanScreenState();
}

class _ActivePlanScreenState extends State<ActivePlanscreen> {
  static const Color primaryGreen = Color(0xff08A045);

  GetMySubscriptionsPlansModel? mySubscriptionModel;
  List<Data> plans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getMysubscriptionPlans();
  }

  Future<void> _getMysubscriptionPlans() async {
    bool internet = await UtilClass.checkInternet();

    if (!internet) {
      if (mounted) {
        UtilClass.showAlertDialog(
          context: context,
          message:
              "No internet connection. Please check your connection and try again.",
        );
      }
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await Repository.postApiRawService(
        EndPoints.getMySubscriptionPlans,
        {"user_id": widget.userData?['user_id'] ?? ""},
      );

      Map<String, dynamic> jsonResponse = response is String
          ? jsonDecode(response as String)
          : response;

      if (jsonResponse['status'] == true) {
        final model = GetMySubscriptionsPlansModel.fromJson(jsonResponse);
        setState(() {
          mySubscriptionModel = model;
          plans = model.data ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        UtilClass.showAlertDialog(
          context: context,
          message: "Something Went Wrong!",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;
    final hPad = sw * 0.05;

    return Scaffold(
      backgroundColor: const Color(0xffF4F6F5),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ────────────────────────────────────────────────
            _Header(sw: sw, sh: sh),

            // ── BODY ──────────────────────────────────────────────────
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff08A045),
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xff08A045),
                      onRefresh: _getMysubscriptionPlans,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          hPad,
                          hPad,
                          hPad,
                          hPad * 0.5,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // View Plans Card
                            _ViewPlansCard(sw: sw),

                            SizedBox(height: sh * 0.028),

                            // Section Title
                            Text(
                              "My Active Plans",
                              style: TextStyle(
                                fontSize: sw * 0.045,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff1A1A1A),
                              ),
                            ),

                            SizedBox(height: sh * 0.016),

                            // Plan Cards
                            plans.isEmpty
                                ? _EmptyState(sw: sw, sh: sh)
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: plans.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: sh * 0.018),
                                    itemBuilder: (context, index) {
                                      return _ActivePlanCard(
                                        plan: plans[index],
                                        sw: sw,
                                        sh: sh,
                                      );
                                    },
                                  ),

                            SizedBox(height: sh * 0.032),

                            // Inspection Report Button
                            SizedBox(
                              width: double.infinity,
                              height: sh * 0.065,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Inspectionreport(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.find_in_page_outlined,
                                  color: Color(0xff08A045),
                                ),
                                label: Text(
                                  "View Inspection Report",
                                  style: TextStyle(
                                    color: const Color(0xff08A045),
                                    fontSize: sw * 0.042,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xff08A045),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      sw * 0.035,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: sh * 0.02),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),

      // ── BOTTOM NAV ────────────────────────────────────────────────
      // bottomNavigationBar: _BottomNav(sw: sw),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final double sw, sh;
  const _Header({required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: sh * 0.11,
      padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
      decoration: const BoxDecoration(color: Color(0xff08A045)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: sw * 0.12,
              width: sw * 0.12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          SizedBox(width: sw * 0.04),
          Text(
            "My Subscriptions",
            style: TextStyle(
              color: Colors.white,
              fontSize: sw * 0.040,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW PLANS CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ViewPlansCard extends StatelessWidget {
  final double sw;
  const _ViewPlansCard({required this.sw});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChoosePlanScreen(userData: {})),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sw * 0.04,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.035),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: sw * 0.115,
              width: sw * 0.115,
              decoration: BoxDecoration(
                color: const Color(0xffE8FFF1),
                borderRadius: BorderRadius.circular(sw * 0.028),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xff08A045),
              ),
            ),
            SizedBox(width: sw * 0.035),
            Expanded(
              child: Text(
                "View Subscription Plans",
                style: TextStyle(
                  fontSize: sw * 0.042,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff333333),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: sw * 0.042,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE PLAN CARD  (uses real API fields)
// ─────────────────────────────────────────────────────────────────────────────
class _ActivePlanCard extends StatelessWidget {
  final Data plan;
  final double sw, sh;

  const _ActivePlanCard({
    required this.plan,
    required this.sw,
    required this.sh,
  });

  // Format "2026-09-09" → "Sep 9, 2026"
  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final parts = raw.split('-');
      if (parts.length < 3) return raw;
      final dt = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  // Format amount: remove trailing .00 → "₹5999"
  String _formatAmount(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final d = double.tryParse(raw);
    if (d == null) return '₹$raw';
    return d == d.truncateToDouble()
        ? '₹${d.toInt()}'
        : '₹${d.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final String planName = plan.planName ?? 'Plan';
    final String duration = plan.duration ?? '';
    final String houseType = plan.houseType ?? '';
    final String amount = _formatAmount(plan.amount);
    final String startDate = _formatDate(plan.startDate);
    final String endDate = _formatDate(plan.endDate);
    final String status = (plan.status ?? 'active').toLowerCase();
    final bool isActive = status == 'active';
    final List<Services> services = plan.services ?? [];
    final int servicesCount = plan.servicesCount ?? services.length;
    final String? imageUrl = plan.image;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.038),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP: image + plan info ─────────────────────────────────
          Padding(
            padding: EdgeInsets.all(sw * 0.04),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan image
                ClipRRect(
                  borderRadius: BorderRadius.circular(sw * 0.028),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: sw * 0.2,
                          height: sw * 0.2,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _PlaceholderImage(sw: sw),
                        )
                      : _PlaceholderImage(sw: sw),
                ),

                SizedBox(width: sw * 0.035),

                // Plan name, duration, house type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.028,
                          vertical: sw * 0.012,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xffD8FFE3)
                              : const Color(0xffFFE5E5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xff00A63E)
                                : const Color(0xffE53935),
                            fontSize: sw * 0.028,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),

                      SizedBox(height: sw * 0.02),

                      // Plan name
                      Text(
                        planName,
                        style: TextStyle(
                          fontSize: sw * 0.055,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff1A1A1A),
                          height: 1.1,
                        ),
                      ),

                      SizedBox(height: sw * 0.012),

                      // Duration + house type chips row
                      Wrap(
                        spacing: sw * 0.02,
                        runSpacing: sw * 0.015,
                        children: [
                          if (duration.isNotEmpty)
                            _InfoChip(
                              icon: Icons.access_time_rounded,
                              label: duration,
                              sw: sw,
                            ),
                          if (houseType.isNotEmpty)
                            _InfoChip(
                              icon: Icons.home_outlined,
                              label: houseType,
                              sw: sw,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount (top-right)
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: sw * 0.065,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xff1A1A1A),
                  ),
                ),
              ],
            ),
          ),

          // ── DIVIDER ───────────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0xffF0F0F0),
            indent: sw * 0.04,
            endIndent: sw * 0.04,
          ),

          // ── DATES ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sw * 0.032,
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: sw * 0.02,
              runSpacing: sw * 0.02,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DateBlock(
                      label: "Start Date",
                      value: startDate,
                      sw: sw,
                      iconColor: const Color(0xff4CAF50),
                    ),
                    SizedBox(width: sw * 0.04),
                    Container(
                      width: 1,
                      height: sw * 0.1,
                      color: const Color(0xffEEEEEE),
                    ),
                    SizedBox(width: sw * 0.04),
                    _DateBlock(
                      label: "Valid Till",
                      value: endDate,
                      sw: sw,
                      iconColor: const Color(0xffF44336),
                    ),
                  ],
                ),
                // Services count badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.03,
                    vertical: sw * 0.018,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF0FFF5),
                    borderRadius: BorderRadius.circular(sw * 0.02),
                    border: Border.all(color: const Color(0xffB2DFCC)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.build_outlined,
                        size: sw * 0.038,
                        color: const Color(0xff08A045),
                      ),
                      SizedBox(width: sw * 0.03),
                      Text(
                        "$servicesCount Services",
                        style: TextStyle(
                          fontSize: sw * 0.032,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff08A045),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── SERVICES CHIPS ────────────────────────────────────────
          if (services.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, sw * 0.032),
              child: Wrap(
                spacing: sw * 0.02,
                runSpacing: sw * 0.018,
                children:
                    services
                        .take(4) // show max 4 chips to keep card clean
                        .map(
                          (s) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.028,
                              vertical: sw * 0.014,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffF7F7F7),
                              borderRadius: BorderRadius.circular(sw * 0.02),
                              border: Border.all(
                                color: const Color(0xffE0E0E0),
                              ),
                            ),
                            child: Text(
                              s.serviceName ?? '',
                              style: TextStyle(
                                fontSize: sw * 0.03,
                                color: const Color(0xff555555),
                              ),
                            ),
                          ),
                        )
                        .toList()
                      ..addAll(
                        servicesCount > 4
                            ? [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sw * 0.028,
                                    vertical: sw * 0.014,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffE8FFF1),
                                    borderRadius: BorderRadius.circular(
                                      sw * 0.02,
                                    ),
                                    border: Border.all(
                                      color: const Color(0xffB2DFCC),
                                    ),
                                  ),
                                  child: Text(
                                    "+${servicesCount - 4} more",
                                    style: TextStyle(
                                      fontSize: sw * 0.03,
                                      color: const Color(0xff08A045),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ]
                            : [],
                      ),
              ),
            ),

          // ── DIVIDER ───────────────────────────────────────────────
          Divider(height: 1, thickness: 1, color: const Color(0xffF0F0F0)),

          // ── ACTION BUTTONS ────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sw * 0.032,
            ),
            child: Row(
              children: [
                // View Details
                Expanded(
                  child: SizedBox(
                    height: sh * 0.048,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubscriptionOverview(
                              subscriptionId: plan.subscriptionId ?? "",
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sh * 0.04),
                        ),
                      ),
                      child: Text(
                        "View Details",
                        style: TextStyle(
                          color: const Color(0xff555555),
                          fontSize: sw * 0.033,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: sw * 0.03),

                // Upgrade Plan
                Expanded(
                  child: SizedBox(
                    height: sh * 0.048,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ChoosePlanScreen(userData: {}),
                          ),
                        );

                        //    final List<int> serviceIds = (plan.services ?? [])
                        // .map((s) => int.tryParse(s.serviceId.toString()) ?? 0)
                        // .where((id) => id != 0)
                        // .toList();

                        //     final params = {
                        //       "subscription_id": plan.subscriptionId,
                        //       "plan_id": plan.planId,
                        //       "house_type": plan.houseType,
                        //       "duration": plan.duration,
                        //       "services": serviceIds,
                        //     };

                        //   print(plan.subscriptionId);
                        //   print(plan.planId);
                        //   print(plan.houseType);
                        //   print(plan.duration);
                        //   print(serviceIds);
                        // TODO: Navigate to upgrade screen with params
                        // Navigator.push(context, MaterialPageRoute(
                        //   builder: (_) => UpgradePlanScreen(params: params),
                        // ));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xffF3C545),
                          width: 1.4,
                        ),
                        backgroundColor: const Color(0xffFFFDE7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sh * 0.04),
                        ),
                      ),
                      child: Text(
                        "Upgrade Plan",
                        style: TextStyle(
                          color: const Color(0xff8B6914),
                          fontSize: sw * 0.033,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double sw;

  const _InfoChip({required this.icon, required this.label, required this.sw});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.022,
        vertical: sw * 0.01,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF4F4F4),
        borderRadius: BorderRadius.circular(sw * 0.015),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: sw * 0.033, color: const Color(0xff888888)),
          SizedBox(width: sw * 0.012),
          Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.031,
              color: const Color(0xff666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  final String label;
  final String value;
  final double sw;
  final Color iconColor;

  const _DateBlock({
    required this.label,
    required this.value,
    required this.sw,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: sw * 0.032,
              color: iconColor,
            ),
            SizedBox(width: sw * 0.012),
            Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.028,
                color: const Color(0xff999999),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: sw * 0.01),
        Text(
          value,
          style: TextStyle(
            fontSize: sw * 0.035,
            fontWeight: FontWeight.w600,
            color: const Color(0xff2C2C2C),
          ),
        ),
      ],
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final double sw;
  const _PlaceholderImage({required this.sw});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sw * 0.2,
      height: sw * 0.2,
      decoration: BoxDecoration(
        color: const Color(0xffE8FFF1),
        borderRadius: BorderRadius.circular(sw * 0.028),
      ),
      child: Icon(
        Icons.workspace_premium_outlined,
        color: const Color(0xff08A045),
        size: sw * 0.09,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final double sw, sh;
  const _EmptyState({required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: sh * 0.06),
        child: Column(
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: sw * 0.18,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: sw * 0.04),
            Text(
              "No active plans found",
              style: TextStyle(
                fontSize: sw * 0.042,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: sw * 0.02),
            Text(
              "Subscribe to a plan to get started",
              style: TextStyle(
                fontSize: sw * 0.035,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM NAVIGATION BAR
// ─────────────────────────────────────────────────────────────────────────────
// class _BottomNav extends StatelessWidget {
//   final double sw;
//   const _BottomNav({required this.sw});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.all(sw * 0.04),
//       padding: EdgeInsets.symmetric(horizontal: sw * 0.025),
//       height: sw * 0.175,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(40),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.09),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _NavIcon(icon: Icons.home_outlined, sw: sw),
//           _NavIcon(icon: Icons.assignment_outlined, sw: sw),

//           // Active pill
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: sw * 0.05,
//               vertical: sw * 0.028,
//             ),
//             decoration: BoxDecoration(
//               color: const Color(0xff08A045),
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.workspace_premium_outlined,
//                   color: Colors.white,
//                   size: sw * 0.048,
//                 ),
//                 SizedBox(width: sw * 0.018),
//                 Text(
//                   "Subscription",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                     fontSize: sw * 0.034,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           _NavIcon(icon: Icons.person_outline, sw: sw),
//         ],
//       ),
//     );
//   }
// }

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final double sw;
  const _NavIcon({required this.icon, required this.sw});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: sw * 0.115,
      width: sw * 0.115,
      decoration: const BoxDecoration(
        color: Color(0xffF4F4F4),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.grey, size: sw * 0.058),
    );
  }
}
