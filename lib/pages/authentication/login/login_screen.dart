import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gobuddy_customer_app/data/prefernces.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();

  String? _phoneError;

  late AnimationController leafController;
  late AnimationController floatingController;

  late Animation<double> leftLeaf;
  late Animation<double> rightLeaf;
  late Animation<double> floatingMan;

  @override
  void initState() {
    super.initState();

    _phoneFocus.addListener(() => setState(() {}));

    leafController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);

    leftLeaf = Tween<double>(begin: -0.15, end: 0.05).animate(
      CurvedAnimation(parent: leafController, curve: Curves.easeInOut),
    );

    rightLeaf = Tween<double>(begin: 0.15, end: -0.05).animate(
      CurvedAnimation(parent: leafController, curve: Curves.easeInOut),
    );

    floatingController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);

    floatingMan = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: floatingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    leafController.dispose();
    floatingController.dispose();
    _phoneFocus.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _phoneError = "Phone number cannot be empty");
      return;
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      setState(() => _phoneError = "Please enter a valid 10-digit phone number");
      return;
    }

    setState(() => _phoneError = null);
    callOtpVerifyAPI();
  }

  Future<void> showSuccessAndNavigate(String phoneNumber, dynamic parsed) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: 
          Container(
            width: 220,
            padding: const EdgeInsets.symmetric(vertical: 25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: 
            
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.5, end: 1.0),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 70,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                const Text(
                  "OTP Sent Successfully!",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: MyColors.appThemeLight
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    Navigator.pop(context);

    Navigator.pushNamed(
      context,
      Config.otpRouteName,
      arguments: {
        "phone": phoneNumber,
        "user_id": parsed["user_id"],
        "property": parsed["property"]
      },
    );
  }

  // void callOtpVerifyAPI() async {

  //   final phoneNumber = _phoneController.text.trim();
  //   final internet = await UtilClass.checkInternet();

  //   if (!internet) {
  //     UtilClass.showAlertDialog(context: context, message: Config.kNoInternet);
  //     return;
  //   }

  //   UtilClass.showProgress(context: context);

  //   try {
  //     final value = await Repository.postApiService(EndPoints.newLoginApi, {
  //       "phone_number": phoneNumber,
  //     });

  //     UtilClass.hideProgress();

  //     final parsed = json.decode(value);

  //     if (parsed["status"] == "valid") {

  //       Preferences.setUserDetails(value);

  //       await showSuccessAndNavigate(phoneNumber, parsed);

  //     } else {
  //       UtilClass.showAlertDialog(context: context, message: parsed["message"]);
  //     }

  //   } catch (e) {
  //     UtilClass.hideProgress();
  //     UtilClass.showAlertDialog(context: context, message: e.toString());
  //   }
  // }


void callOtpVerifyAPI() async {

  final phoneNumber = _phoneController.text.trim();
  final internet = await UtilClass.checkInternet();

  if (!internet) {
    UtilClass.showAlertDialog(context: context, message: Config.kNoInternet);
    return;
  }

  UtilClass.showProgress(context: context);

  try {
    final value = await Repository.postApiService(EndPoints.newLoginApi, {
      "phone_number": phoneNumber,
    });

    UtilClass.hideProgress();

    final parsed = json.decode(value);

    if (parsed["status"] == "valid") {
      Preferences.setUserDetails(value);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', parsed["user_id"].toString());
      await showSuccessAndNavigate(phoneNumber, parsed);
    } else {
      UtilClass.showAlertDialog(context: context, message: parsed["message"]);
    }

  } catch (e) {
    UtilClass.hideProgress();
    UtilClass.showAlertDialog(context: context, message: e.toString());
  }
}
  @override
  Widget build(BuildContext context) {

    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: MyColors.appThemeLight,
        body: SafeArea(
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          SystemNavigator.pop();
                        }
                      },
                      child: Image.asset(
                        "assets/images/whiteLeftArrow.png",
                        width: 18,
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [

                  AnimatedBuilder(
                    animation: leafController,
                    builder: (context, child) {
                      return Positioned(
                        top: 105,
                        left: -15,
                        child: Transform.rotate(
                          angle: leftLeaf.value,
                          child: Image.asset(
                            "assets/images/leftSideLeaf.png",
                            width: 70,
                          ),
                        ),
                      );
                    },
                  ),

                  AnimatedBuilder(
                    animation: leafController,
                    builder: (context, child) {
                      return Positioned(
                        top: 100,
                        right: -15,
                        child: Transform.rotate(
                          angle: rightLeaf.value,
                          child: Image.asset(
                            "assets/images/rightSideLeaf.png",
                            width: 70,
                          ),
                        ),
                      );
                    },
                  ),

                  Positioned(
                    top: deviceHeight * 0.19,
                    child: Container(
                      width: deviceWidth,
                      height: deviceHeight * 0.20,
                      decoration: const BoxDecoration(
                        color: MyColors.topCardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: deviceHeight * 0.25,
                    child: Container(
                      width: deviceWidth,
                      height: deviceHeight * 0.72,
                      decoration: const BoxDecoration(
                        color: MyColors.cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 40),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [

                              const SizedBox(height: 40),

                              _buildTextField(
                                controller: _phoneController,
                                focusNode: _phoneFocus,
                                label: "Phone Number",
                                prefix: "+91 ",
                                keyboardType: TextInputType.phone,
                              ),

                              if (_phoneError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5, left: 12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _phoneError!,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 35),

                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: _validateAndSubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MyColors.appThemeLight,
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  Config.signUpGuidingRouteName,
                                ),
                                child: const Text(
                                  "Don't have an account? Register here",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  AnimatedBuilder(
                    animation: floatingController,
                    builder: (context, child) {
                      return Positioned(
                        top: 2 + floatingMan.value,
                        child: Image.asset(
                          "assets/images/manWithReport.png",
                          width: 170,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    String? prefix,
    TextInputType? keyboardType,
  }) {

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType ?? TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        filled: true,
        fillColor: MyColors.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}