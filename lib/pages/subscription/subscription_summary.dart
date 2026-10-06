import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/data/prefernces.dart';
import 'package:gobuddy_customer_app/models/subscription_added_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:convert';

import 'package:gobuddy_customer_app/pages/subscription_renewal/active_planscreen.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/session_manager.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';

class SubscriptionSummary extends StatefulWidget {


  const SubscriptionSummary({
   super.key
  }) ;

  @override
  State<SubscriptionSummary> createState() => _SubscriptionSummaryState();
}

class _SubscriptionSummaryState extends State<SubscriptionSummary> {
  final TextEditingController _couponController = TextEditingController();
  bool _termsAccepted = false;
  bool _useGBCoins = false;
  bool _showServicesSection = false; // Added state variable for toggle
  double _couponDiscount = 0.0;
  String? _appliedCouponName;

  // Dynamic values from planData
  late String planName;
  late String planDuration;
  late double planAmount;
  late List<Map<String, dynamic>> selectedJobs;

  // Fixed values
  // GST is 18% as per backend API (Postman: gst=18)
  double get gstAmount => ((selectedPrice ?? 0) * 0.18);
  final int gbCoinsBalance = 125;

Map<String, dynamic>? completedPlan;
List<Map<String, dynamic>> selectedServices = [];
Map<String, dynamic> planDetails = {};
String? selectedDuration;
double? selectedPrice;
String? userId;
double get totalPrice => ((selectedPrice ?? 0) + gstAmount - _couponDiscount).clamp(0.0, double.infinity);
GetSubscriptionStatusModel?pushintoSubscriptionModel;
String? _scheduledInspectionDate;
String? _scheduledInspectionTime;


@override
void didChangeDependencies() {
  super.didChangeDependencies();

  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

  if (args != null && args.containsKey('completed_packed_plan')) {
    completedPlan = Map<String, dynamic>.from(args['completed_packed_plan']);
    userId = args['user_id']?.toString();
    if (userId == null || userId!.isEmpty) {
      SessionManager.getUserId().then((id) {
        if (id != null && mounted) setState(() => userId = id);
      });
    }
    // Extract services list
    selectedServices = List<Map<String, dynamic>>.from(completedPlan!['services_data'] ?? []);
    final planData = completedPlan!['plan_data'];
    if (planData is Map) {
      planDetails = Map<String, dynamic>.from(planData);
    } else if (planData is List) {
      // If plan_data is a List, convert it to a map with index keys or handle as needed
      planDetails = {
        for (int i = 0; i < planData.length; i++) 'item_$i': planData[i],
      };
    } else {
      planDetails = {}; // fallback if plan_data is a String or null
    }
    
    // Extract selected duration and price
    selectedDuration = completedPlan!['selected_duration'];
    // selectedPrice = completedPlan!['selected_price']?.toDouble();
    final priceData = completedPlan!['selected_price'];
if (priceData is int) {
  selectedPrice = priceData.toDouble();
} else if (priceData is double) {
  selectedPrice = priceData;
} else if (priceData is String) {
  selectedPrice = double.tryParse(priceData) ?? 0.0;
} else {
  selectedPrice = 0.0;
}

    
    print("📦 Complete Plan: $completedPlan");
    print("🛠 Selected Services: $selectedServices");
    print("💰 Plan Details: $planDetails");
    print("⏱ Selected Duration: $selectedDuration");
    print("💸 Selected Price: $selectedPrice");

    _checkActivePlanStatus();
  }
}

  Future<void> _checkActivePlanStatus() async {
    try {
      String? uid = userId;
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
      if (isStatusValid && rawList is List) {
        final currentPlanName = (completedPlan?['plan_name'] ?? '').toString().trim().toLowerCase();
        final currentPlanId = (planDetails['plan_id'] ?? '').toString().trim();

        for (final ap in rawList) {
          if (ap is Map) {
            final apPlanId = (ap['plan_id'] ?? ap['planId'] ?? '').toString().trim();
            final apPlanName = (ap['plan_name'] ?? ap['planName'] ?? '').toString().trim().toLowerCase();
            final status = (ap['status']?.toString() ?? 'active').toLowerCase();

            final bool idMatch = currentPlanId.isNotEmpty && apPlanId.isNotEmpty && currentPlanId == apPlanId;
            final bool nameMatch = currentPlanName.isNotEmpty &&
                apPlanName.isNotEmpty &&
                (currentPlanName == apPlanName ||
                    currentPlanName.contains(apPlanName) ||
                    apPlanName.contains(currentPlanName));
            
            final bool isCustom = currentPlanId == '15' || currentPlanName.contains('custom');

            if (!isCustom && (idMatch || nameMatch) &&
                (status == 'active' || status == '1' || status == 'valid' || status == 'success')) {
              if (mounted) {
                setState(() {
                  _isPlanAlreadyActive = true;
                  _activePlanInfo = Map<String, dynamic>.from(ap);
                });
              }
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking if plan already active: $e");
    }
  }

  bool _isPlanAlreadyActive = false;
  Map<String, dynamic>? _activePlanInfo;


  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  double get totalAmount => (planAmount + gstAmount);
  double get amountToPay => _useGBCoins ? totalAmount - gbCoinsBalance : totalAmount;

  // Toggle function for services section
  void _toggleServicesSection() {
  setState(() {
    _showServicesSection = !_showServicesSection;
  });
}



  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      UtilClass.showAlertDialog(context: context, message: "Please enter a coupon code");
      return;
    }
    if (!await UtilClass.checkInternet()) {
      UtilClass.showAlertDialog(context: context, message: "No Internet Connection");
      return;
    }
    try {
      final response = await Repository.postApiService(
        EndPoints.verifyCouponcode,
        {'user_id': userId ?? '', 'coupon': code},
      );
      final res = response is String ? jsonDecode(response) : response;
      if (res?['status'] == 'valid' || res?['status'] == true) {
        final discountAmount = double.tryParse(res?['discount']?.toString() ?? '50') ?? 50.0;
        setState(() {
          _couponDiscount = discountAmount;
          _appliedCouponName = code;
        });
        if (mounted) {
          UtilClass.showAlertDialog(context: context, message: "Coupon applied successfully! You saved ₹${discountAmount.toInt()}");
        }
      } else {
        if (mounted) {
          UtilClass.showAlertDialog(context: context, message: res?['message']?.toString() ?? "Invalid coupon");
        }
      }
    } catch (e) {
      if (mounted) {
        UtilClass.showAlertDialog(context: context, message: "Could not apply coupon. Please try again.");
      }
    }
  }

  void callRagerPayment() async {
    String contact = await Preferences.getPhone() ?? '';
    String email = await Preferences.getEmail() ?? '';

    if (contact.isEmpty && (userId != null && userId!.isNotEmpty)) {
      try {
        final raw = await Repository.postApiService(
          EndPoints.getUserDetailsforDashboard,
          {'id': userId},
        );
        final res = jsonDecode(raw);
        if (res['customer_details'] != null) {
          contact = res['customer_details']['phone_number']?.toString() ?? '';
          email = res['customer_details']['email']?.toString() ?? '';
          if (contact.isNotEmpty) await Preferences.setPhone(contact);
          if (email.isNotEmpty) await Preferences.setEmail(email);
        }
      } catch (e) {
        debugPrint("Error fetching user details for payment: $e");
      }
    }

    if (_isPlanAlreadyActive) {
      UtilClass.showAlertDialog(
        context: context,
        message:
            "You already have an active subscription for this plan (${_activePlanInfo?['valid_till'] != null ? 'Valid until ' + _activePlanInfo!['valid_till'].toString() : 'Active'}). Repurchasing is disabled.",
      );
      return;
    }

    final payableAmt = ((selectedPrice ?? 0.0) - _couponDiscount).clamp(1.0, double.infinity);

    Razorpay razorpay = Razorpay();
    var options = {
      'key': 'rzp_live_ZdGjJKZdukGGzL',
      'amount': (payableAmt * 100).toInt(),
      'name': 'Go buddy',
      'description': 'Subscription Payment',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        if (contact.isNotEmpty) 'contact': contact,
        if (email.isNotEmpty) 'email': email,
      },
      'external': {
        'wallets': ['paytm'],
      },
    };
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    razorpay.open(options);
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    debugPrint("---- RAZORPAY ERROR ----");
    debugPrint("CODE: ${response.code}");
    debugPrint("MESSAGE: ${response.message}");
    debugPrint("ERROR: ${response.error}");
    debugPrint("-------------------------");

    UtilClass.showAlertDialog(
      context: context,
      message:
          "Payment Failed : ${response.code}\nDescription: ${response.message}\nMetadata: ${response.error.toString()}",
    );
  }




void handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
  try {
    print("PAYMENT SUCCESS: ${response.paymentId}");
    print("SELECTED SERVICES: $selectedServices");

    final List<int> serviceIds = selectedServices
        .map<int>((service) => int.parse(service["service_id"].toString()))
        .toList();

    print("SERVICE IDS: $serviceIds");

    final Map<String, dynamic> requestBody = {
      "user_id": userId ?? "",

      // 🔴 IMPORTANT: match working Postman plan
      "plan_id": planDetails['plan_id'] ?? 0,

      // 🔴 IMPORTANT: remove space (match backend format)
      "house_type": planDetails['house_type']?.replaceAll(' ', '') ?? '',

      // 🔴 IMPORTANT: match working duration if needed
      "duration": planDetails['duration'] ?? '3 Months',

      // optional: test with same working services first
      "services": serviceIds,
    };

    print("REQUEST BODY: ${jsonEncode(requestBody)}");

    final apiResponse = await Repository.postApiRawService(
      EndPoints.addSubscription,
      requestBody,
    );

    print("API RESPONSE: $apiResponse");

    final Map<String, dynamic> responseMap =
        apiResponse is String
            ? jsonDecode(apiResponse)
            : Map<String, dynamic>.from(apiResponse);

    pushintoSubscriptionModel =
        GetSubscriptionStatusModel.fromJson(responseMap);

    if (pushintoSubscriptionModel!.status) {
      print("Subscription Success");
      print(pushintoSubscriptionModel!.message);
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Subscription Activated!"),
            content: Text(
              "Your subscription has been successfully placed.\nSubscription ID: ${pushintoSubscriptionModel!.data?['subscription_id'] ?? 'N/A'}",
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A651),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivePlanscreen(
                        userData: {'user_id': userId},
                      ),
                    ),
                  );
                },
                child: const Text("View My Plans"),
              ),
            ],
          ),
        );
      }
    } else {
      print("Subscription Failed");
      print(pushintoSubscriptionModel!.message);

      UtilClass.showAlertDialog(
        context: context,
        message: pushintoSubscriptionModel!.message,
      );
    }
  } catch (e, stackTrace) {
    print("ERROR: $e");
    print(stackTrace);

    UtilClass.showAlertDialog(
      context: context,
      message: "Something went wrong. Please try again.",
    );
  }
}
    void handleExternalWalletSelected(ExternalWalletResponse response) {
 
 
    // showAlertDialog(
    //   context,
    //   "External Wallet Selected",
    //   "${response.walletName}",
    // );
    UtilClass.showAlertDialog(context: context, message: "External Wallet Selected");
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(context, padding),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildReviewPlanSection(size),
                  if (_showServicesSection) _buildServicesSection(size, selectedServices), // Conditional rendering
                  _buildScheduleSection(size),
                  _buildOffersSection(size),
                  _buildPaymentSummarySection(size),
                  _buildWarningSection(size),
                  _buildTermsSection(size),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildPayButton(size, padding),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EdgeInsets padding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: padding.top + 10,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
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
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Summary',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildReviewPlanSection(Size size) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      completedPlan!['plan_name']??"",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                   selectedDuration??"",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              Text(
                "₹ ${selectedPrice.toString()}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: OutlinedButton(
              onPressed: _toggleServicesSection, // Updated to use toggle function
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Plan Details',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildServicesSection(Size size, List servicesData) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Services',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16),

        // Render Services
        ...servicesData.asMap().entries.map((entry) {
          final index = entry.key;
          final service = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          service['service_name'] ?? 'Service',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Qty: ${service['quantity'] ?? 1}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    ),
  );
}


  Widget _buildScheduleSection(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule your home inspection (optional)',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                arguments: {
                  'amount' : selectedPrice.toString()
                },
               Config.scheduledateandTimeforSubscription);
              if (result != null && result is Map) {
                setState(() {
                  _scheduledInspectionDate = result['date'];
                  _scheduledInspectionTime = result['time'];
                });
              }
            },
            child: Row(
              children: [
                Text(
                  _scheduledInspectionDate != null
                      ? 'Scheduled: $_scheduledInspectionDate at $_scheduledInspectionTime'
                      : 'Set Time and Date',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _scheduledInspectionDate != null ? const Color(0xFF00A651) : Colors.grey[900],
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Color(0xFFFF8C00),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersSection(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer,
                color: Color(0xFF00A651),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Offers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Enter coupon code ( Optional )',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'Enter Code',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _applyCoupon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A651),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _appliedCouponName != null ? 'Applied' : 'Apply',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Use your GB coins and get discount',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Your GB Coins Balance:',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.monetization_on,
                color: Color(0xFFFFB300),
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                '$gbCoinsBalance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _useGBCoins = !_useGBCoins;
                });
              },
              icon: Icon(
                Icons.monetization_on,
                color: Color(0xFF00A651),
                size: 18,
              ),
              label: Text(
                'Use Coins',
                style: TextStyle(
                  color: Color(0xFF00A651),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                side: BorderSide(color: Color(0xFF00A651)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummarySection(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          _buildSummaryRow('Plan amount', '₹ ${selectedPrice.toString()}', false),
          SizedBox(height: 16),
          Divider(color: Colors.grey[200], height: 1),
          SizedBox(height: 16),
          _buildSummaryRow('GST (18%)', '₹ ${gstAmount.toStringAsFixed(0)}', false),
          SizedBox(height: 16),
          Divider(color: Colors.grey[200], height: 1),
          SizedBox(height: 16),
          _buildSummaryRow('Total Amount', '₹ $totalPrice', true),
          SizedBox(height: 16),
          Divider(color: Colors.grey[200], height: 1),
          SizedBox(height: 16),
          _buildSummaryRow('Amount to pay', '₹ $totalPrice', true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isBold ? Colors.grey[900] : Colors.grey[600],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildWarningSection(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber,
            color: Color(0xFFFFA726),
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Order cost might change if services offered require more work.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _termsAccepted = !_termsAccepted;
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _termsAccepted ? Color(0xFF00A651) : Colors.white,
                border: Border.all(
                  color: _termsAccepted ? Color(0xFF00A651) : Colors.grey[400]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _termsAccepted
                  ? Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
                  : null,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: 'Accept ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                children: [
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFF8C00),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(Size size, EdgeInsets padding) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isPlanAlreadyActive) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "You already have an active subscription for this plan"
                      "${_activePlanInfo?['valid_till'] != null ? ' (valid until ' + _activePlanInfo!['valid_till'].toString() + ')' : ''}. Repurchasing is disabled.",
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.brown.shade800,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_termsAccepted && !_isPlanAlreadyActive)
                  ? () {
                      callRagerPayment();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPlanAlreadyActive
                    ? Colors.grey[400]
                    : const Color(0xFF00A651),
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _isPlanAlreadyActive ? 'Plan Already Active' : 'Pay',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
