import 'package:flutter/material.dart';

class PlanDetails extends StatefulWidget {
  const PlanDetails({super.key});

  @override
  State<PlanDetails> createState() => _PlanDetailsState();
}

class _PlanDetailsState extends State<PlanDetails> {
  // JSON data for the plan
  final Map<String, dynamic> planData = {
    "planName": "Repair",
    "price": 3499,
    "duration": "6 Months",
    "validTill": "10 Nov, 2025",
    "status": "ACTIVE",
    "services": [
      {
        "title": "Prevent Package Services",
        "value": null,
        "used": 1,
        "total": 1,
        "left": 0
      },
      {
        "title": "5 AC Services up to 500/- Value",
        "subtitle": "( Jet servicing + Gas pressure check )",
        "value": "500/-",
        "used": 2,
        "total": 5,
        "left": 3
      },
      {
        "title": "5 Electrical services up to 500/-  Value",
        "subtitle": null,
        "value": "500/-",
        "used": 1,
        "total": 5,
        "left": 4
      },
      {
        "title": "5 Plumbing Services up to 500/- Value",
        "subtitle": null,
        "value": "500/-",
        "used": 0,
        "total": 5,
        "left": 5
      },
    ]
  };

  // ✅ JSON for cancellation reasons
  final List<Map<String, dynamic>> cancelReasons = [
    {"id": 1, "reason": "Lorem Ipsum dummy text"},
    {"id": 2, "reason": "Lorem Ipsum dummy text"},
    {"id": 3, "reason": "Lorem Ipsum dummy text"},
    {"id": 4, "reason": "Lorem Ipsum dummy text"},
    {"id": 5, "reason": "Others"},
  ];

  int? _selectedReason;
  String _cancellationReason = '';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(width, height),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: height * 0.02,
                ),
                child: _buildPlanCard(width, height),
              ),
            ),
          ),
          _buildUpgradeButton(width, height),
        ],
      ),
    );
  }

  Widget _buildHeader(double width, double height) {
    return Container(
      width: width,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + height * 0.01,
        bottom: height * 0.02,
        left: width * 0.05,
        right: width * 0.05,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF00A651),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(width * 0.03),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: width * 0.06,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Plan Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: width * 0.06,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: width * 0.12),
        ],
      ),
    );
  }

  Widget _buildPlanCard(double width, double height) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanHeader(width, height),
          SizedBox(height: height * 0.03),
          ...List.generate(
            planData['services'].length,
                (index) => _buildServiceItem(
              width,
              height,
              planData['services'][index],
              index < planData['services'].length - 1,
            ),
          ),
          SizedBox(height: height * 0.02),
          _buildCancelButton(width, height),
        ],
      ),
    );
  }

  Widget _buildPlanHeader(double width, double height) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                planData['planName'],
                style: TextStyle(
                  color: const Color(0xFF4169E1),
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: width * 0.01),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '₹ ${planData['price']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' /${planData['duration']}',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: width * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Valid till ${planData['validTill']}',
              style: TextStyle(
                color: Colors.black87,
                fontSize: width * 0.037,
              ),
            ),
            SizedBox(height: width * 0.02),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04, vertical: width * 0.015),
              decoration: BoxDecoration(
                color: const Color(0xFF90EE90),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                planData['status'],
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: width * 0.032,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceItem(
      double width, double height, Map<String, dynamic> service, bool showDivider) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.verified, color: Colors.grey.shade600, size: width * 0.06),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['title'],
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (service['subtitle'] != null)
                    Padding(
                      padding: EdgeInsets.only(top: width * 0.01),
                      child: Text(
                        service['subtitle'],
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: width * 0.037,
                        ),
                      ),
                    ),
                  SizedBox(height: width * 0.02),
                  _buildServiceStatus(width, service),
                ],
              ),
            ),
          ],
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(vertical: height * 0.015),
            child: Divider(color: Colors.grey.shade300, thickness: 1),
          ),
      ],
    );
  }

  Widget _buildServiceStatus(double width, Map<String, dynamic> service) {
    return Row(
      children: [
        if (service['used'] > 0)
          Row(children: [
            Container(
              width: width * 0.025,
              height: width * 0.025,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B6B),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: width * 0.02),
            Text(
              service['total'] == 1 ? 'Used' : '${service['used']} Used',
              style: TextStyle(fontSize: width * 0.037),
            ),
          ]),
        if (service['left'] > 0) ...[
          SizedBox(width: width * 0.04),
          Container(
            width: width * 0.025,
            height: width * 0.025,
            decoration: const BoxDecoration(
              color: Color(0xFF00C853),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: width * 0.02),
          Text(
            '${service['left']} Left',
            style: TextStyle(fontSize: width * 0.037),
          ),
        ],
      ],
    );
  }

  Widget _buildCancelButton(double width, double height) {
    return Center(
      child: OutlinedButton(
        onPressed: () => _showCancelDialog(context),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.15,
            vertical: height * 0.015,
          ),
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Cancel plan',
          style: TextStyle(
            color: Colors.black54,
            fontSize: width * 0.042,
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.03),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cancel Plan ?',
                  style: TextStyle(
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
                SizedBox(height: height * 0.015),
                Text(
                  'Are you sure you want to Cancel your subscription plan',
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(fontSize: width * 0.04, color: Colors.black54, height: 1.4),
                ),
                SizedBox(height: height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: width * 0.3,
                      height: height * 0.055,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side:
                          BorderSide(color: Colors.grey.shade300, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('No',
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.3,
                      height: height * 0.055,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showCancelReasonSheet(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Yes',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCustomCancelReasonPopup(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Create a local controller for this dialog
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(width * 0.05),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Please write reason for cancel",
                    style: TextStyle(
                        fontSize: width * 0.045, fontWeight: FontWeight.w600)),
                SizedBox(height: height * 0.02),
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8)),
                  child: TextField(
                    controller: reasonController, // Use local controller
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Write here",
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.03),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final reason = reasonController.text.trim();
                      if (reason.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please enter a reason")),
                        );
                        return;
                      }

                      // Store the reason
                      _cancellationReason = reason;

                      // Close current dialog
                      Navigator.pop(context);

                      // Show cancel request popup after a small delay
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _showCancelRequestPopup(context);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding:
                        EdgeInsets.symmetric(vertical: height * 0.018),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: Text("Cancel",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w600)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }


  void _showCancelRequestPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap OK
      builder: (BuildContext context) {
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.06, vertical: height * 0.03),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: width * 0.22,
                  width: width * 0.22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFA726), // light orange background
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: width * 0.12,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.025),
                Text(
                  "Cancel Request Submitted",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: height * 0.015),
                Text(
                  "Your cancellation request has been submitted. Sorry to see you go, one of our representatives will contact you to initiate cancellation or you can message/call us at 9347785705.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.04,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: height * 0.035),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // close popup
                      // Navigator.pushReplacementNamed(context, '/nextScreen');
                      // Replace '/nextScreen' with your actual screen route
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A651), // green
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: EdgeInsets.symmetric(vertical: height * 0.018),
                    ),
                    child: Text(
                      "Ok",
                      style: TextStyle(
                        fontSize: width * 0.045,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  /// ✅ Bottom sheet for cancel reasons
  void _showCancelReasonSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
      const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: width * 0.06,
                  right: width * 0.06,
                  top: height * 0.025),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Why do you want to cancel plan?",
                      style: TextStyle(
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  SizedBox(height: height * 0.005),
                  Text("Please provide the reason for cancellation",
                      style: TextStyle(
                          fontSize: width * 0.04, color: Colors.black54)),
                  Divider(height: height * 0.04, color: Colors.grey.shade300),
                  ...cancelReasons.map((reason) {
                    return Column(
                      children: [
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(reason['reason'],
                              style: TextStyle(
                                  fontSize: width * 0.043, color: Colors.black87)),
                          trailing: Radio<int>(
                            value: reason['id'],
                            groupValue: _selectedReason,
                            activeColor: Colors.orange,
                            onChanged: (val) {
                              setSheetState(() {
                                _selectedReason = val;
                              });
                            },
                          ),
                        ),
                        Divider(height: height * 0.02, color: Colors.grey.shade200),
                      ],
                    );
                  }),
                  SizedBox(height: height * 0.02),
                  SizedBox(
                    width: double.infinity,
                    child:ElevatedButton(
                      onPressed: _selectedReason != null
                          ? () {
                        Navigator.pop(context);
                        if (_selectedReason ==
                            cancelReasons.last['id']) {
                          _showCustomCancelReasonPopup(context);
                        } else {
                          _showCancelRequestPopup(context);
                        }
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedReason != null
                            ? Colors.orange
                            : Colors.grey.shade300,
                        padding: EdgeInsets.symmetric(vertical: height * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Cancel Plan",
                        style: TextStyle(
                            color: _selectedReason != null
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                ],
              ),
            );
          },
        );
      },
    );
  }



  Widget _buildUpgradeButton(double width, double height) {
    return Container(
      width: width,
      padding: EdgeInsets.all(width * 0.05),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFDB54E),
          padding: EdgeInsets.symmetric(vertical: height * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Upgrade Plan',
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}