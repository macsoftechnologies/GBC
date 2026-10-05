import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';

class PaymentSuccessfulScreen extends StatefulWidget {
  const PaymentSuccessfulScreen({super.key});

  @override
  State<PaymentSuccessfulScreen> createState() => _PaymentSuccessfulScreenState();
}

class _PaymentSuccessfulScreenState extends State<PaymentSuccessfulScreen> {
  String? userId;
  String? OderId;
  String? PaymentId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      userId = args['user_id']?.toString();
      OderId = (args['oder_id'] ?? args['job_calender_id'] ?? args['order_id'])?.toString();
      PaymentId = args['payment_id']?.toString();
    }
  }

  void _navigateToBookings() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Config.homeRouteName,
      (route) => false,
      arguments: {
        "user_id": userId,
        "tab_index": 1, // Directly opens My Bookings tab in HomeMainScreen
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateToBookings();
      },
      child: Scaffold(
        backgroundColor: MyColors.appThemeLight,
        body: SafeArea(
          child: Center(
            child: Container(
              width: screenWidth * 0.9,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Green Check Icon
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Success Text
                  const Text(
                    'Order Placed Successfully',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // OK Button
                  SizedBox(
                    width: screenWidth * 0.7,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _navigateToBookings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
