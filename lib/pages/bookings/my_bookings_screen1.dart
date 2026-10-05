import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/data/prefernces.dart';
import 'package:gobuddy_customer_app/models/all_oders_model.dart';
import 'package:gobuddy_customer_app/models/cancel_oders_reason_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import '../../components/custom_app_header.dart';
import '../rateProvider/rate_provider.dart';
import 'booking_order_details.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key, required this.userData, this.onBack});
  final Map<String, dynamic>? userData;
  final VoidCallback? onBack;

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {



GetBookings? bookingsResponse;
Order?getOders;
User?getuser;
String selectedTab = "All";
List<Order> allOrders = [];
List<Order> filteredOrders = [];
bool _isLoadingBookings = false;
CancelReason? pushintoCancelReason;
GetCancelOrderReasons? getCancelReasons;
String? userId;



Future<void> _getCancelReasons() async {
  bool internet = await UtilClass.checkInternet();
  if (!internet) {
    UtilClass.showAlertDialog(context: context, message: "No Internet Connection");
    return;
  }

  try {
    final response = await Repository.getApiService(EndPoints.getCancelReasons);

    Map<String, dynamic> jsonResponse;

    if (response is String) {
      jsonResponse = json.decode(response);
    } else if (response is Map<String, dynamic>) {
      jsonResponse = response;
    } else {
      throw Exception("Invalid response type");
    }

    if (jsonResponse["status"] == "valid") {
      final parsedData = GetCancelOrderReasons.fromJson(jsonResponse);

      setState(() {
        getCancelReasons = parsedData;
      });
    } else {
      UtilClass.showAlertDialog(context: context, message: "Failed to fetch cancel reasons");
    }
  } catch (e) {
    UtilClass.showAlertDialog(context: context, message: "Something went wrong: $e");
  }
}

Future<void> _getBookings() async {
  bool internet = await UtilClass.checkInternet();
  if (!internet) {
    UtilClass.showAlertDialog(
      context: context,
      message: "No Internet Connection!",
    );
    return;
  }

  setState(() {
    _isLoadingBookings = true;
  });

  try {
    final uid = widget.userData?['user_id'] ?? await Preferences.getUserID();
    final response = await Repository.NewPostApiService(
      EndPoints.getAllOdersApi,
      {'user_id': uid ?? ''},
    );
    Map<String, dynamic> jsonResponse;

    if (response is String) {
      jsonResponse = json.decode(response as String);
    } else if (response is Map<String, dynamic>) {
      jsonResponse = response;
    } else {
      jsonResponse = {};
    }

    if (jsonResponse["status"] == "valid" || jsonResponse["status"] == true) {
      bookingsResponse = GetBookings.fromJson(jsonResponse);

      setState(() {
        allOrders = bookingsResponse?.orders ?? [];
        filteredOrders = allOrders!;
        getuser = bookingsResponse?.user;
      });

      _filterOrders(selectedTab);

    } else {
      print("Invalid status in response: ${jsonResponse["status"]}");
    }
  } catch (e, stack) {
    print("Error fetching bookings: $e");
    print(stack);
  } finally {
    if (mounted) {
      setState(() {
        _isLoadingBookings = false;
      });
    }
  }
}




Future<void> _ConfirmCancellation(int selectedReasonId, String reasonText, String jobcalendarId) async {
  bool internet = await UtilClass.checkInternet();
  if (!internet) {
    UtilClass.showAlertDialog(
        context: context, message: "No Internet Connection");
    return;
  }

  if (jobcalendarId.isEmpty) {
    UtilClass.showAlertDialog(
        context: context, message: "Booking ID not found to cancel.");
    return;
  }

  UtilClass.showProgress(context: context);

  try {
    final response = await Repository.NewPostApiService(
      EndPoints.cancelSubcription,
      {
        "job_calender_id": jobcalendarId,
        "cancel_reason": reasonText,
        "cancel_note": reasonText,
      },
    );

    UtilClass.hideProgress();
    print('Cancel request: $response');

    if (response["status"] == "valid" || response["status"] == true || response["status"] == "success") {
      _showCancelRequestPopup(context);
      _getBookings();
    } else {
      UtilClass.showAlertDialog(
          context: context, message: response["message"] ?? "Error updating Cancellation Request");
    }
  } catch (e) {
    UtilClass.hideProgress();
    print('Error cancelling: $e');
    UtilClass.showAlertDialog(
        context: context, message: "Something went wrong. Please try again.");
  }
}




  int? _selectedReason;
  final TextEditingController _reasonController = TextEditingController();
  String _cancellationReason = '';

  @override
  void initState() {
    super.initState();
   _getBookings();
   _getCancelReasons();
  }

  // Filter orders based on the selected tab
void _filterOrders(String tab) {
  setState(() {
    selectedTab = tab;

    if (tab == "All") {
      filteredOrders = allOrders;
    } else {
      filteredOrders = allOrders.where((order) {
        final status = order.status?.toLowerCase() ?? "";
        switch (tab) {
          case "Upcoming":
            return status == "scheduled";
          case "Completed":
            return status == "completed";
          case "Cancelled":
            return status == "cancelled";
          default:
            return true;
        }
      }).toList();
    }
  });
}




  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

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
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F0),
        appBar: CustomAppHeader(
            title: "My Bookings", // Pass the required title
            onBack: widget.onBack ?? () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
        ),
        body: SafeArea(
          child: Column(
            children: [
              // ✅ Horizontally scrollable Tabs
             Container(
  color: Colors.white,
  padding: EdgeInsets.all(w * 0.03),
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _tabButton("All"),
        SizedBox(width: w * 0.02),
        _tabButton("Upcoming"),
        SizedBox(width: w * 0.02),
        _tabButton("Completed"),
        SizedBox(width: w * 0.02),
        _tabButton("Cancelled"),
      ],
    ),
  ),
),


              // Bookings List
           Expanded(
              child: _isLoadingBookings
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                      child: Column(
                        children: [
                          if (filteredOrders.isNotEmpty)
                            ...filteredOrders.map((order) => _buildBookingCard(context, order)).toList()
                          else
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text("No bookings found"),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),

            ],
          ),
        ),
      ),
    );
  }


  void _showCancelDialog(BuildContext context, [String? jobcalendarId]) {
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
                  'Cancel Booking?',
                  style: TextStyle(
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
                SizedBox(height: height * 0.015),
                Text(
                  'Are you sure you want to cancel this booking?',
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
                       onPressed: ()=> Navigator.pop(context),
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
                          if (getCancelReasons != null) {
                            _showCancelReasonSheet(context, getCancelReasons!, jobcalendarId);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cancel reasons not available yet')),
                            );
                          }
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
                      Navigator.pop(context);
                       // close popup
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


void _showCustomCancelReasonPopup(BuildContext context, int selectedReasonId, [String? jobcalendarId]) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;

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
              Text(
                "Please write reason for cancellation",
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: height * 0.02),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: reasonController,
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
                child:Column(
                  children: [
                         
                 ElevatedButton(
                  
                  onPressed: () {
                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a reason")),
                      );
                      return;
                    } else {
                      Navigator.pop(context);
                      final jId = jobcalendarId?.isNotEmpty == true ? jobcalendarId! : (getOders?.jobCalenderId ?? '');
                      _ConfirmCancellation(selectedReasonId, reason, jId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    
                    padding: EdgeInsets.symmetric(vertical: height * 0.018,),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                ),
              

                  ],
                )
                
                
              
         
              )
            ],
          ),
        ),
      );
    },
  );
}



void _showCancelReasonSheet(
    BuildContext context, GetCancelOrderReasons? getCancelReasons, [String? jobcalendarId]) {
  if (getCancelReasons == null || getCancelReasons.cancelReasons.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cancel reasons not available')),
    );
    return;
  }

  int? _selectedReason;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
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
              top: height * 0.015,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                Text(
                  "Why do you want to cancel booking?",
                  style: TextStyle(
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.w700,
                      color: Colors.black),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  "Please provide the reason for cancellation",
                  style: TextStyle(fontSize: width * 0.04, color: Colors.black54),
                ),
                Divider(height: height * 0.04, color: Colors.grey.shade300),

                ...getCancelReasons.cancelReasons.map((reason) {
                  return Column(
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          reason.reason,
                          style: TextStyle(
                              fontSize: width * 0.043, color: Colors.black87),
                        ),
                        trailing: Radio<int>(
                          value: int.parse(reason.id),
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
                }).toList(),

                SizedBox(height: height * 0.02),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedReason != null
                        ? () {
                            Navigator.pop(context);
                            int lastReasonId =
                                int.parse(getCancelReasons.cancelReasons.last.id);

                            if (_selectedReason == lastReasonId) {
                              _showCustomCancelReasonPopup(
                                  context, _selectedReason!, jobcalendarId);
                            } else {
                              final selectedReasonText =
                                  getCancelReasons.cancelReasons
                                      .firstWhere((r) =>
                                          int.parse(r.id) == _selectedReason)
                                      .reason;
                              final jId = jobcalendarId?.isNotEmpty == true ? jobcalendarId! : (getOders?.jobCalenderId ?? "");

                              _ConfirmCancellation(
                                  _selectedReason!, selectedReasonText, jId);
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





Widget _tabButton(String tabName) {
  double w = MediaQuery.of(context).size.width;
  bool isSelected = selectedTab == tabName;

  return GestureDetector(
    onTap: () {
      // Only change state if a different tab is selected
      if (selectedTab != tabName) {
        _filterOrders(tabName);
      }
    },
    child: Container(
      width: w * 0.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(w * 0.02),
        color: isSelected ? const Color(0xFFDFF5E3) : Colors.white,
        border: Border.all(
          color: isSelected ? const Color(0xFF1EB35B) : Colors.grey.shade300,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: w * 0.02),
      alignment: Alignment.center,
      child: Text(
        tabName,
        style: TextStyle(
          color: isSelected ? const Color(0xFF1EB35B) : Colors.grey.shade700,
          fontWeight: FontWeight.w500,
          fontSize: w * 0.035,
        ),
      ),
    ),
  );
}



Widget _buildBookingCard(BuildContext context, Order order) {
  double w = MediaQuery.of(context).size.width;
  double h = MediaQuery.of(context).size.height;

  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(
        context,
       arguments: {
         'order_id' : order.orderId??"",

       },
       Config.OderDetailsScreen
       
       );
    },
    child: Container(
      margin: EdgeInsets.only(bottom: h * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.03,
              vertical: h * 0.012,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFDFF5E3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(w * 0.03)),
            ),
            child: Row(
              children: [
                Text("ID : ${order.orderTxn ?? ''}", style: TextStyle(fontSize: w * 0.035)),
                const Spacer(),
                Text(
                  "View Details",
                  style: TextStyle(
                    color: const Color(0xFF1EB35B),
                    fontWeight: FontWeight.w500,
                    fontSize: w * 0.035,
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: EdgeInsets.all(w * 0.03),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(w * 0.02),
                  child: order.serviceImage != null && order.serviceImage!.isNotEmpty
                      ? Image.network(
                          "https://dev.gobuddyindia.com/assets/images/${order.serviceImage}",
                          height: w * 0.18,
                          width: w * 0.18,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              "https://dev.gobuddyindia.com/assets/images/${order.serviceImage}",
                              height: w * 0.18,
                              width: w * 0.18,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _noImageContainer(w),
                            );
                          },
                        )
                      : _noImageContainer(w),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.serviceName?? "",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: w * 0.04),
                      ),
                      SizedBox(height: h * 0.005),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: w * 0.04, color: Colors.grey),
                          SizedBox(width: w * 0.02),
                          Text(
                            order.scheduleDate ?? "",
                            style: TextStyle(fontSize: w * 0.035, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: h * 0.006),
                      Row(
                        children: [
                          if (order.status == "Scheduled")
                            _statusContainer(w, h, "Scheduled", Color(0xFF1EB35B), Color(0xFFDFF5E3)),
                          if (order.status == "Completed")
                            Row(
                              children: [
                                Text("Completed", style: TextStyle(fontSize: w * 0.035, color: Colors.black87)),
                                SizedBox(width: w * 0.01),
                                Icon(Icons.check_circle, color: Colors.green, size: w * 0.045),
                              ],
                            ),
                          if (order.status == "Cancelled")
                            _statusContainer(w, h, "Cancelled", Colors.red, Colors.red.shade50),
                          const Spacer(),
                          Text(
                            "₹ ${(order.grandTotal != null && order.grandTotal!.isNotEmpty && order.grandTotal != '0') ? order.grandTotal : (order.price ?? '0')}",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: w * 0.04),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sections
       if (order.status == "Scheduled")
  _upcomingButtons(context, order, getuser!),// force unwrap safely

          if (order.status == "Completed") _completedSection( w, h, order),
          if (order.status == "Cancelled") _cancelledSection( w, h, order),
        ],
      ),
    ),
  );
}

// Helper for "No Image"
Widget _noImageContainer(double w) {
  return Container(
    height: w * 0.18,
    width: w * 0.18,
    color: Colors.grey.shade200,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: w * 0.08, color: Colors.grey),
          SizedBox(height: 4),
          Text("No Image Found", textAlign: TextAlign.center, style: TextStyle(fontSize: w * 0.025, color: Colors.grey)),
        ],
      ),
    ),
  );
}

// Helper for status container
Widget _statusContainer(double w, double h, String text, Color textColor, Color bgColor) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: h * 0.004),
    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(w * 0.015)),
    child: Text(text, style: TextStyle(color: textColor, fontSize: w * 0.035)),
  );
}


  Widget _upcomingButtons(BuildContext context, Order getorder, User getuser ) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
  final orderId = getorder?.orderId??"";
    return Padding(
      padding: EdgeInsets.only(left: w * 0.05, right: w * 0.05, bottom: h * 0.015),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timer aligned above Cancel Booking button
          Row(
            children: [
              Spacer(flex: 1), // This spacer matches the Edit Schedule button width
              SizedBox(width: w * 0.02), // This matches the gap between buttons
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.orange, size: w * 0.04),
                    SizedBox(width: w * 0.015),
                    Text(
                      "Timer",
                        style: TextStyle(
                            fontSize: w * 0.038,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.015),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      Config.editschedulescreen,
                      arguments: {
                        'user_id': getuser.id ?? "",
                        'job_calender_id': getorder.jobCalenderId ?? "",
                        'order_id': getorder.orderId ?? "",
                        'provider_id': getorder.serviceId ?? "",
                      },
                    ).then((val) {
                      if (val == true) {
                        _getBookings();
                      }
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey, width: 0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(w * 0.08)),
                  ),
                  child: Text("Edit Schedule",
                      style: TextStyle(
                          fontSize: w * 0.035, color: Colors.black87)),
                ),
              ),
              SizedBox(width: w * 0.02),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showCancelDialog(context, getorder.jobCalenderId ?? "");
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey, width: 0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(w * 0.08)),
                  ),
                  child: Text("Cancel Booking",
                      style: TextStyle(
                          fontSize: w * 0.035, color: Colors.black87)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
 
 
Widget _completedSection(double w, double h, Order order) {
  // Safely parse rating from String to double
  double rating = 0.0;
  if (order.rating != null && order.rating!.isNotEmpty) {
    rating = double.tryParse(order.rating!) ?? 0.0;
  }

  bool rated = rating > 0;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.015),
    child: Align(
      alignment: Alignment.centerLeft,
      child: rated
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Very Good",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: h * 0.005),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating.floor()
                          ? Icons.star
                          : (rating - index >= 0.5
                              ? Icons.star_half
                              : Icons.star_border),
                      color: Colors.orange,
                      size: w * 0.06,
                    ),
                  ),
                ),
              ],
            )
          : OutlinedButton(
              onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Config.rateProviderScreenforBookings,
                    arguments: {
                      'order_id': order.jobCalenderId ?? order.orderId ?? "",
                      'user_id': getuser?.id ?? widget.userData?['user_id'] ?? "",
                      'services': {
                        'service_name': order.serviceName ?? "",
                        'service_image': order.serviceImage ?? "",
                        'price': order.price ?? "",
                        'service_id': order.serviceId ?? "",
                      },
                    },
                  );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.orange, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.06),
                ),
              ),
              child: const Text(
                "Rate Provider",
                style: TextStyle(color: Colors.orange),
              ),
            ),
    ),
  );
}

  Widget _cancelledSection( double w, double h, Order order) {
    // bool refundDone = b['refund'] == "Completed";
    
    return Padding(
      padding:
      EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.015),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          // refundDone ? "Refund Completed" : "Refund Pending",
          "Refund  Pending",
          style: TextStyle(
            // color: refundDone ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
