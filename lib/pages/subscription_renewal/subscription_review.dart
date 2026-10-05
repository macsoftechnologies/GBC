import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/models/mysubscription_overview_model.dart';
import 'package:gobuddy_customer_app/models/subscription_cancel_model.dart';
import 'package:gobuddy_customer_app/pages/subscription/choose_plan_screen.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';

class SubscriptionOverview extends StatefulWidget {
  const SubscriptionOverview({super.key, required this.subscriptionId});

  final String subscriptionId;

  @override
  State<SubscriptionOverview> createState() =>
      _SubscriptionOverviewScreenState();
}

class _SubscriptionOverviewScreenState extends State<SubscriptionOverview> {
  // ---------- state ----------
  bool _isLoading = true;
  bool _isCancelling = false;

  GetMySubscriptionsOverviewModel? pushintoMySubscriptionOverview;
  Data? subscriptionOverviewData;
  List<Services>? subscriptionServices;
  GetCancelSubscriptionModel? pushintoCancelSubscriptionModel;

  final TextEditingController _otherReasonController = TextEditingController();

  List<String> _cancelReasons = [
    'Selected wrong service',
    'Booked by mistake',
    'I will not be available at the time',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _getSubscriptionOverview();
    _fetchCancelReasons();
  }

  Future<void> _fetchCancelReasons() async {
    try {
      final response = await Repository.getApiService(EndPoints.getSubscriptionCancelReasons);
      final jsonResponse = response is String ? jsonDecode(response) : response;
      final rawList = jsonResponse?['cancelreasons'] ?? jsonResponse?['data'];
      if (rawList is List) {
        final reasons = rawList
            .map((e) => (e is Map ? (e['reason'] ?? e['title'])?.toString() : e.toString()) ?? '')
            .where((r) => r.isNotEmpty)
            .toList();
        if (reasons.isNotEmpty && mounted) {
          setState(() {
            _cancelReasons = reasons;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching subscription cancel reasons: $e");
    }
  }

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  // ── Responsive helpers ─────────────────────────────────────────────────────
  // Base design width = 390 (iPhone 14). Sizes scale proportionally.
  double _sw(BuildContext ctx) => MediaQuery.of(ctx).size.width;

  double _scale(BuildContext ctx, double value) =>
      value * (_sw(ctx) / 390).clamp(0.8, 1.3);

  double _fs(BuildContext ctx, double size) =>
      _scale(ctx, size).roundToDouble();

  double _sp(BuildContext ctx, double size) => _scale(ctx, size);

  String _formatEndDate(String? raw) {
    if (raw == null || raw.isEmpty) return '–';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month]}, ${dt.year}';
    } catch (_) {
      return raw; 
    }
  }

  /// Determine badge colour from Data.status
  Color _statusBgColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return const Color(0xffA5F3A8);
      case 'expired':
        return const Color(0xffFFD6D6);
      case 'cancelled':
        return const Color(0xffFFE4CC);
      default:
        return const Color(0xffE0E0E0);
    }
  }

  Color _statusTextColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return const Color(0xff007F1F);
      case 'expired':
        return const Color(0xffB00020);
      case 'cancelled':
        return const Color(0xffE65100);
      default:
        return Colors.black54;
    }
  }

  // ── API calls ──────────────────────────────────────────────────────────────

  Future<void> _getSubscriptionOverview() async {
    final bool internet = await UtilClass.checkInternet();
    if (!internet) {
      if (mounted) {
        UtilClass.showAlertDialog(
            context: context, message: 'No Internet Connection');
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await Repository.NewPostApiService(
          EndPoints.getMySubscriptionOverview,
          {'subscription_id': widget.subscriptionId});

      final Map<String, dynamic> jsonResponse =
          response is String ? json.decode(response as String) : response;

      if (jsonResponse['status'] == 'valid') {
        setState(() {
          pushintoMySubscriptionOverview =
              GetMySubscriptionsOverviewModel.fromJson(jsonResponse);
          // Model: GetMySubscriptionsOverviewModel.data → Data
          subscriptionOverviewData = pushintoMySubscriptionOverview?.data;
          // Model: Data.services → List<Services>
          subscriptionServices = subscriptionOverviewData?.services;
        });
      } else {
        debugPrint('Failed to fetch Subscription Overview');
      }
    } catch (e) {
      if (mounted) {
        UtilClass.showAlertDialog(
            context: context,
            message: 'Error fetching subscription overview: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelSubscription([String? reason]) async {
    print(
        "Cancelling subscription with ID: ${subscriptionOverviewData?.subscriptionId ?? widget.subscriptionId}");
    final bool internet = await UtilClass.checkInternet();
    if (!internet) {
      if (mounted) {
        UtilClass.showAlertDialog(
            context: context, message: 'No Internet Connection');
      }
      return;
    }

    setState(() => _isCancelling = true);
    try {
      final payload = <String, dynamic>{
        'subscription_id':
            subscriptionOverviewData?.subscriptionId ?? widget.subscriptionId,
      };
      if (reason != null && reason.isNotEmpty) {
        payload['reason'] = reason;
      }

      final dynamic rawResponse = await Repository.postApiRawService(
          EndPoints.cancelSubscriptionsNew, payload);

      Map<String, dynamic> jsonResponse;
      if (rawResponse is String) {
        jsonResponse = json.decode(rawResponse as String);
      } else {
        jsonResponse = rawResponse;
      }

      if (jsonResponse['status'] == 'valid' || jsonResponse['status'] == true) {
        print("Please check out the response: $jsonResponse");
        pushintoCancelSubscriptionModel =
            GetCancelSubscriptionModel.fromJson(jsonResponse);
        if (mounted) _showSuccessDialog();
      } else {
        if (mounted) {
          UtilClass.showAlertDialog(
              context: context,
              message: jsonResponse['message']?.toString() ??
                  'Cancellation failed.');
        }
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  // ── Cancel flow steps ──────────────────────────────────────────────────────

  // Step 1 – confirmation dialog
  void _showConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Plan?',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: _fs(ctx, 18)),
        ),
        content: Text(
          'Are you sure you want to cancel your subscription plan?',
          style: TextStyle(fontSize: _fs(ctx, 14)),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, _sp(ctx, 48)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('No',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: _fs(ctx, 14))),
                ),
              ),
              SizedBox(width: _sp(ctx, 12)),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF2832A),
                    minimumSize: Size(0, _sp(ctx, 48)),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showReasonsSheet();
                  },
                  child: Text('Yes',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: _fs(ctx, 14))),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Step 2 – reason bottom-sheet
  void _showReasonsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ReasonsSheet(
        reasons: _cancelReasons,
        onProceed: (reason) {
          Navigator.pop(context);
          if (reason == 'Others') {
            _showOtherReasonDialog();
          } else {
            _cancelSubscription(reason);
          }
        },
      ),
    );
  }

  // Step 3 – free-text (only for "Others")
  void _showOtherReasonDialog() {
    _otherReasonController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Please write reason for cancel',
            style: TextStyle(fontSize: _fs(ctx, 16))),
        content: TextField(
          controller: _otherReasonController,
          maxLines: 5,
          style: TextStyle(fontSize: _fs(ctx, 14)),
          decoration: InputDecoration(
            hintText: 'Write here',
            filled: true,
            fillColor: const Color(0xffEFF7F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: _sp(ctx, 48),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffF2832A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final text = _otherReasonController.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(ctx);
                _cancelSubscription(text);
              },
              child: Text('Submit',
                  style: TextStyle(
                      color: Colors.white, fontSize: _fs(ctx, 16))),
            ),
          )
        ],
      ),
    );
  }

  // Step 4 – success dialog (shown after API confirms cancellation)
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: _sp(ctx, 8)),
            Container(
              width: _sp(ctx, 72),
              height: _sp(ctx, 72),
              decoration: BoxDecoration(
                color: const Color(0xffF2832A),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffF2832A).withOpacity(.3),
                    blurRadius: 20,
                    spreadRadius: 6,
                  )
                ],
              ),
              child: Icon(Icons.check,
                  color: Colors.white, size: _sp(ctx, 36)),
            ),
            SizedBox(height: _sp(ctx, 20)),
            Text(
              'Cancel Request Submitted',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: _fs(ctx, 18), fontWeight: FontWeight.bold),
            ),
            SizedBox(height: _sp(ctx, 12)),
            Text(
              'Your cancellation request has been submitted. '
              'Sorry to see you go — one of our representatives '
              'will contact you shortly, or reach us at 9347785705.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black54,
                  height: 1.5,
                  fontSize: _fs(ctx, 13)),
            ),
            SizedBox(height: _sp(ctx, 24)),
            SizedBox(
              width: double.infinity,
              height: _sp(ctx, 48),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff10A63B),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);     // close success dialog
                  Navigator.pop(context); // go back to previous screen
                },
                child: Text('Ok',
                    style: TextStyle(
                        color: Colors.white, fontSize: _fs(ctx, 16))),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Model field aliases for brevity
    final d = subscriptionOverviewData; // Data?

    return Scaffold(
      backgroundColor: const Color(0xffF2F4F3),
      appBar: AppBar(
        backgroundColor: const Color(0xff10A63B),
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.all(_sp(context, 10)),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff3CBF5A),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: _sp(context, 18)),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Plan Details',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: _fs(context, 18)),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff10A63B)))
          : Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(_sp(context, 18)),
                        child: Container(
                          padding: EdgeInsets.all(_sp(context, 16)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(_sp(context, 14)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(.12),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Header row ─────────────────────────────
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      // Model: Data.planName
                                      d?.planName ?? '–',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: _fs(context, 26),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        // Model: Data.endDate
                                        'Valid till ${_formatEndDate(d?.endDate)}',
                                        style: TextStyle(
                                            fontSize: _fs(context, 12)),
                                      ),
                                      SizedBox(height: _sp(context, 8)),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: _sp(context, 12),
                                          vertical: _sp(context, 5),
                                        ),
                                        decoration: BoxDecoration(
                                          // Model: Data.status
                                          color: _statusBgColor(d?.status),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          (d?.status ?? 'ACTIVE')
                                              .toUpperCase(),
                                          style: TextStyle(
                                              fontSize: _fs(context, 11),
                                              color: _statusTextColor(
                                                  d?.status),
                                              fontWeight:
                                                  FontWeight.w600),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: _sp(context, 8)),

                              // ── Plan type & house type tags ─────────────
                              if (d?.planType != null ||
                                  d?.houseType != null) ...[
                                Wrap(
                                  spacing: _sp(context, 8),
                                  children: [
                                    if (d?.planType != null)
                                      _tagChip(context, d!.planType!),
                                    if (d?.houseType != null)
                                      _tagChip(context, d!.houseType!),
                                  ],
                                ),
                                SizedBox(height: _sp(context, 8)),
                              ],

                              // ── Price row ───────────────────────────────
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    // Model: Data.amount
                                    '₹ ${d?.amount ?? '–'}',
                                    style: TextStyle(
                                        fontSize: _fs(context, 32),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: _sp(context, 5)),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: _sp(context, 6)),
                                    child: Text(
                                      // Model: Data.duration
                                      '/ ${d?.duration ?? '–'}',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: _fs(context, 13)),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: _sp(context, 12)),
                              const Divider(),

                              // ── Services count summary ──────────────────
                              if (d?.servicesCount != null) ...[
                                Padding(
                                  padding: EdgeInsets.only(
                                      bottom: _sp(context, 8)),
                                  child: Text(
                                    // Model: Data.servicesCount
                                    '${d!.servicesCount} service${d.servicesCount == 1 ? '' : 's'} included',
                                    style: TextStyle(
                                        fontSize: _fs(context, 12),
                                        color: Colors.black45),
                                  ),
                                ),
                              ],

                              // ── Service tiles ───────────────────────────
                              // Model: Data.services → List<Services>
                              // Services fields used:
                              //   serviceName, used, remaining, total, price
                              if (subscriptionServices != null &&
                                  subscriptionServices!.isNotEmpty) ...[
                                ...subscriptionServices!.map((s) => Column(
                                      children: [
                                        _serviceTile(context: context, service: s),
                                        const Divider(),
                                      ],
                                    )),
                              ] else ...[
                                // Empty state
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: _sp(context, 24)),
                                  child: Center(
                                    child: Text(
                                      
                                      'No services found for this plan.',
                                      style: TextStyle(
                                          fontSize: _fs(context, 13),
                                          color: Colors.black45),
                                    ),
                                  ),
                                ),
                                const Divider(),
                              ],

                              SizedBox(height: _sp(context, 24)),

                              // ── Cancel plan button ──────────────────────
                              Center(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: Size(
                                        _sp(context, 160),
                                        _sp(context, 48)),
                                    side: const BorderSide(
                                        color: Colors.grey),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  onPressed: _showConfirmDialog,
                                  child: Text(
                                    'Cancel plan',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: _fs(context, 14)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Upgrade Plan CTA ────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.all(_sp(context, 20)),
                      child: SizedBox(
                        width: double.infinity,
                        height: _sp(context, 52),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffF2C93C),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ChoosePlanScreen(userData: {},)));
                      },
                          child: Text(
                            'Upgrade Plan',
                            style: TextStyle(
                                fontSize: _fs(context, 16),
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),

                // ── Full-screen loader during cancel API call ───────────────
                if (_isCancelling)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xff10A63B)),
                    ),
                  ),
              ],
            ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _tagChip(BuildContext ctx, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: _sp(ctx, 10), vertical: _sp(ctx, 3)),
      decoration: BoxDecoration(
        color: const Color(0xffEFF7F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xff10A63B).withOpacity(.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: _fs(ctx, 11),
            color: const Color(0xff007F1F),
            fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Service tile using exact model fields from [Services]:
  /// - [Services.serviceName]  → tile title
  /// - [Services.used]         → used count
  /// - [Services.remaining]    → remaining count  (was "left" before)
  /// - [Services.total]        → total count, used to draw usage bar
  /// - [Services.price]        → optional price label
  Widget _serviceTile({
    required BuildContext context,
    required Services service,
  }) {
    final int used = service.used ?? 0;
    final int? remaining = service.remaining;
    final int? total = service.total;
    final String name = service.serviceName ?? '–';
    final String? priceLabel =
        service.price != null ? '₹${service.price}' : null;

    // Usage fraction for the thin progress bar (0.0 – 1.0)
    final double fraction =
        (total != null && total > 0) ? (used / total).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: _sp(context, 12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: _sp(context, 2)),
            padding: EdgeInsets.all(_sp(context, 6)),
            decoration: BoxDecoration(
              color: const Color(0xffEFF7F0),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.build_outlined,
                size: _sp(context, 16),
                color: const Color(0xff10A63B)),
          ),
          SizedBox(width: _sp(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(name,
                          style: TextStyle(
                              fontSize: _fs(context, 14),
                              fontWeight: FontWeight.w500)),
                    ),
                    if (priceLabel != null)
                      Text(priceLabel,
                          style: TextStyle(
                              fontSize: _fs(context, 12),
                              color: Colors.black45)),
                  ],
                ),
                SizedBox(height: _sp(context, 8)),
                // Usage bar (only when total is known)
                if (total != null && total > 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: _sp(context, 5),
                      backgroundColor: const Color(0xffEEEEEE),
                      color: fraction >= 1.0
                          ? Colors.red.shade400
                          : const Color(0xff10A63B),
                    ),
                  ),
                  SizedBox(height: _sp(context, 6)),
                ],
                Row(
                  children: [
                    _statusDot(context, Colors.red, '$used Used'),
                    if (remaining != null) ...[
                      SizedBox(width: _sp(context, 20)),
                      _statusDot(
                          context, Colors.green, '$remaining Left'),
                    ],
                    if (total != null) ...[
                      SizedBox(width: _sp(context, 20)),
                      _statusDot(
                          context, Colors.blueGrey, '$total Total'),
                    ],
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _statusDot(BuildContext context, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _sp(context, 8),
          height: _sp(context, 8),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: _sp(context, 5)),
        Text(text,
            style: TextStyle(
                fontSize: _fs(context, 12), color: Colors.black54)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Separate StatefulWidget for the reasons bottom-sheet so radio state works
// ─────────────────────────────────────────────────────────────────────────────
class _ReasonsSheet extends StatefulWidget {
  final List<String> reasons;
  final void Function(String reason) onProceed;

  const _ReasonsSheet({required this.reasons, required this.onProceed});

  @override
  State<_ReasonsSheet> createState() => _ReasonsSheetState();
}

class _ReasonsSheetState extends State<_ReasonsSheet> {
  String? _selected;

  double _sw(BuildContext ctx) => MediaQuery.of(ctx).size.width;
  double _scale(BuildContext ctx, double v) =>
      v * (_sw(ctx) / 390).clamp(0.8, 1.3);
  double _fs(BuildContext ctx, double s) => _scale(ctx, s).roundToDouble();
  double _sp(BuildContext ctx, double s) => _scale(ctx, s);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _sp(context, 20),
        _sp(context, 24),
        _sp(context, 20),
        _sp(context, 32),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why do you want to cancel plan?',
            style: TextStyle(
                fontSize: _fs(context, 18), fontWeight: FontWeight.bold),
          ),
          SizedBox(height: _sp(context, 4)),
          Text(
            'Please provide the reason for cancellation',
            style: TextStyle(
                color: Colors.black54, fontSize: _fs(context, 13)),
          ),
          SizedBox(height: _sp(context, 16)),
          const Divider(),
          ...widget.reasons.map(
            (r) => Column(
              children: [
                RadioListTile<String>(
                  value: r,
                  groupValue: _selected,
                  title: Text(r,
                      style: TextStyle(fontSize: _fs(context, 14))),
                  activeColor: const Color(0xffF2832A),
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => _selected = v),
                ),
                const Divider(height: 1),
              ],
            ),
          ),
          SizedBox(height: _sp(context, 20)),
          SizedBox(
            width: double.infinity,
            height: _sp(context, 52),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selected != null
                    ? const Color(0xff10A63B)
                    : Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed:
                  _selected != null ? () => widget.onProceed(_selected!) : null,
              child: Text(
                'Cancel Plan',
                style: TextStyle(
                  fontSize: _fs(context, 16),
                  color: _selected != null ? Colors.white : Colors.black38,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}