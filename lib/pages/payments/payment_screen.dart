import 'package:gobuddy_customer_app/data/prefernces.dart';

import 'package:flutter/material.dart';


import 'package:gobuddy_customer_app/components/custom_back_button.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';



class PaymentMethodScreen extends StatefulWidget {

  const PaymentMethodScreen({
    super.key,
  
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  PaymentMethod? selectedPaymentMethod = PaymentMethod.phonePe;
    dynamic userData= {};
    String? selectedPrice;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      selectedPrice = args['amount']?.toString();
    }
  }


 @override
  void initState() {
    super.initState();

    //  var userDataValue = Preferences.getUserDetails();
      // userData =  json.decode(userDataValue!);
   
  }

  void callRagerPayment(String selectedPrice) async {
    Razorpay razorpay = Razorpay();
    double amountDouble = double.tryParse(selectedPrice) ?? 0.0;
    if (amountDouble <= 0) {
      UtilClass.showAlertDialog(context: context, message: "Invalid payment amount");
      return;
    }

    int amountInPaise = (amountDouble * 100).round();
    String contactPhone = (await Preferences.getPhone()) ?? '';
    String contactEmail = (await Preferences.getEmail()) ?? '';

    var options = {
      'key': 'rzp_live_ZdGjJKZdukGGzL',
      'amount': amountInPaise,
      'name': 'Go buddy',
      'description': 'Subscription Payment',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        if (contactPhone.isNotEmpty) 'contact': contactPhone,
        if (contactEmail.isNotEmpty) 'email': contactEmail,
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
    print("---- RAZORPAY ERROR ----");
    print("CODE: ${response.code}");
    print("MESSAGE: ${response.message}");
    print("ERROR: ${response.error}");
    print("-------------------------");

    UtilClass.showAlertDialog(
      context: context,
      message:
          "Payment Failed : ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()} ",
    );
  }


  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    print("Payment Success: ${response.paymentId}");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Payment Successful!"),
        content: Text(
          "Payment ID: ${response.paymentId ?? ''}\nYour payment has been processed successfully.",
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
              Navigator.pop(context, true);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context, screenWidth),

            // UPI Section
            _buildUPISection(screenWidth),

            // Payment Methods Section
            Expanded(
              child: _buildPaymentMethodsSection(screenWidth, screenHeight),
            ),

            // Bottom Payment Section
            _buildBottomPaymentSection(screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 16,
      ),
      child: Row(
        children: [
          CustomBackButton(),
          SizedBox(width: screenWidth * 0.04),
          const Text(
            'Choose how to pay',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUPISection(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: const EdgeInsets.all(16),
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
          Image.asset(
            'assets/images/UPi.png',
            width: 40,
            height: 24,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 40,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'UPI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          const Text(
            'UNIFIED PAYMENTS INTERFACE',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.only(
        left: screenWidth * 0.04,
        right: screenWidth * 0.04,
        top: 16,
      ),
      padding: const EdgeInsets.all(20),
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
        children: [
          _buildPaymentMethodTile(
            PaymentMethod.phonePe,
            'PhonePe',
            'assets/images/PhonePe.png',
            const Color(0xFF5F259F),
          ),
          const Divider(height: 22, color: Color(0xFFE0E0E0)),
          _buildPaymentMethodTile(
            PaymentMethod.googlePay,
            'Google Pay',
            'assets/images/GooglePay.png',
            Colors.blue,
          ),
          const Divider(height: 22, color: Color(0xFFE0E0E0)),
          _buildPaymentMethodTile(
            PaymentMethod.paytm,
            'Paytm',
            'assets/images/Paytm.png',
            const Color(0xFF00BAF2),
          ),
          const Divider(height: 22, color: Color(0xFFE0E0E0)),
          _buildUPIIdSection(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(
    PaymentMethod method,
    String title,
    String iconPath,
    Color iconColor,
  ) {
    final isSelected = selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
     
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              // decoration: BoxDecoration(
              //   color: iconColor.withOpacity(0.1),
              //   borderRadius: BorderRadius.circular(22),
              // ),
              child: Image.asset(iconPath, height: 12, width: 14),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFBDBDBD),
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUPIIdSection() {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = PaymentMethod.upiId;
        });
      
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.add, color: Color(0xFF666666), size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Enter UPI ID',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPaymentSection(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    // '₹${widget.amount.toStringAsFixed(0)}',
                    '₹ ${selectedPrice.toString()}',
                   
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const Text(
                    'To be paid now',
                    style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {
                  // callpaymentVeifyAPI();
                  callRagerPayment(selectedPrice.toString());
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Pay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum PaymentMethod { phonePe, googlePay, paytm, upiId }


