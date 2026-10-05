// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:gobuddy_customer_app/services/end_points.dart';
// import 'package:gobuddy_customer_app/services/repository.dart';
// import 'package:gobuddy_customer_app/utils/util_class.dart';
// import '../../../utils/config.dart';
// import '../../../utils/my_colors.dart';
import 'package:sms_autofill/sms_autofill.dart';

// class OTPVerificationScreen extends StatefulWidget {


//   const OTPVerificationScreen({
// super.key
//   });

//   @override
//   State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
// }

// class _OTPVerificationScreenState extends State<OTPVerificationScreen>
//     with SingleTickerProviderStateMixin {

//   List<TextEditingController> controllers =
//   List.generate(4, (index) => TextEditingController());

//   List<FocusNode> focusNodes =
//   List.generate(4, (index) => FocusNode());

//   dynamic userData = {};
//   String? phoneNumber;
//   String?userId;
//   String?viewAs;


//   @override
// void didChangeDependencies() {
//   super.didChangeDependencies();

//   final args =
//       ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

//   phoneNumber = args['phone_number'];
//   userId = args['user_id'].toString();
//   viewAs = args['view_as'];

//   print("Phone: $phoneNumber");
//   print("UserId: $userId");
// }

//   @override
//   void dispose() {
//     for (var controller in controllers) {
//       controller.dispose();
//     }
//     for (var focusNode in focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }



//   void _onChanged(String value, int index) {

//     if (value.isNotEmpty && index < 3) {
//       focusNodes[index + 1].requestFocus();
//     }

//     if (value.isEmpty && index > 0) {
//       focusNodes[index - 1].requestFocus();
//     }

//     setState(() {});
//   }

//   bool get _isOtpComplete {
//     return controllers.every((controller) => controller.text.isNotEmpty);
//   }

//   /// SMOOTH SUCCESS POPUP
//   void _showAnimatedSuccess(String message) {

//     showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: "",
//       barrierColor: Colors.black45,
//       transitionDuration: const Duration(milliseconds: 300),

//       pageBuilder: (_, __, ___) {
//         return Center(
//           child: Container(
//             width: 260,
//             padding: const EdgeInsets.all(22),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(18),
//               boxShadow: [
//                 BoxShadow(
//                     color: Colors.black.withOpacity(.2),
//                     blurRadius: 20)
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [

//                 const Icon(
//                   Icons.check_circle,
//                   color: Colors.green,
//                   size: 65,
//                 ),

//                 const SizedBox(height: 15),

//                 Text(
//                   message,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600),
//                 ),

//                 const SizedBox(height: 15),

//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: MyColors.appThemeLight,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text(
//                     "OK",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         );
//       },

//       transitionBuilder: (_, animation, __, child) {

//         return Transform.scale(
//           scale: Curves.easeOutBack.transform(animation.value),
//           child: child,
//         );
//       },
//     );
//   }

//   Future<void> _resendOTP() async {

//     bool internet = await UtilClass.checkInternet();

//     if (!internet) {
//       UtilClass.showAlertDialog(
//           context: context,
//           message: "No Internet Connection !");
//       return;
//     }

//     try {

//       final response = await Repository.NewPostApiService(
//           EndPoints.resendOTP,
//           {"user_id": userId??""});
//       if (response["status"] == "valid") {

//         /// SMOOTH POPUP
//         _showAnimatedSuccess("OTP Sent Successfully");

//       } else {

//         UtilClass.showAlertDialog(
//             context: context,
//             message: "Please try Again after Sometime");
//       }

//     } catch (e) {

//       UtilClass.showAlertDialog(
//           context: context,
//           message: "Something went wrong $e");
//     }
//   }

//   Future<void> _verifyOTP() async {

//     String otp = controllers.map((controller) => controller.text).join();

//     bool internet = await UtilClass.checkInternet();

//     if (!internet) {
//       UtilClass.showAlertDialog(
//           context: context,
//           message: "No internet connection");
//       return;
//     }

//     UtilClass.showProgress(context: context);

//     try {

//       final response = await Repository.postApiService(
//         EndPoints.newVerifyOtpApi,
//         {
//           "user_id": userId??"",
//           "otp":  otp,
//           "token": "testing",
//         },
//       );

//       UtilClass.hideProgress();

//       final parsed = json.decode(response);

//       if (parsed["status"] == "valid") {

//         UtilClass.showAlertDialog(
//             context: context,
//             message: "Login Successfully !");

//         String? property = parsed["property"];

//         Navigator.pushReplacementNamed(
//           context,
//           Config.homeRouteName,
//           arguments: {
//             "user_id": userId??"",
//             "phone_number": phoneNumber??"",
//           },
//         );

//       } else {

//         _showErrorDialog();
//       }

//     } catch (e) {

//       UtilClass.hideProgress();

//       UtilClass.showAlertDialog(
//           context: context,
//           message: "Something went wrong. Please try again.");
//     }
//   }

//   void _showErrorDialog() {

//     showDialog(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20)),

//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [

//               const Icon(Icons.error,
//                   color: Colors.red,
//                   size: 60),

//               const SizedBox(height: 15),

//               const Text(
//                 "OTP not matched",
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600),
//               ),

//               const SizedBox(height: 20),

//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text(
//                   "Ok",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {

//     double deviceHeight =
//         MediaQuery.of(context).size.height;

//     return AnimatedPadding(
//       duration: const Duration(milliseconds: 200),
//       padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom),

//       child: Scaffold(
//         backgroundColor: MyColors.lightGreen,
//         resizeToAvoidBottomInset: true,

//         body: SafeArea(
//           child: Column(
//             children: [

//               Padding(
//                 padding: const EdgeInsets.only(
//                     left: 10, top: 8, right: 20),

//                 child: Row(
//                   children: [

//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),

//                       child: const Icon(
//                         Icons.arrow_back_ios,
//                         color: MyColors.appThemeLight,
//                       ),
//                     ),

//                     const SizedBox(width: 45),

//                     const Text(
//                       "OTP Verification",
//                       style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600),
//                     ),
//                   ],
//                 ),
//               ),

//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(20),

//                   child: Column(
//                     children: [

//                       SizedBox(height: deviceHeight * 0.03),

//                       Image.asset(
//                         "assets/images/otpVerifyImg.png",
//                         width: 180,
//                       ),

//                       SizedBox(height: deviceHeight * 0.05),

//                       Text(
//                         'Enter the code we sent to the number',
//                         style: TextStyle(
//                             fontSize: 15,
//                             color: Colors.grey.shade600),
//                       ),

//                       const SizedBox(height: 6),

//                       Text(
//                         phoneNumber??"",
//                         style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500),
//                       ),

//                       SizedBox(height: deviceHeight * 0.03),

//                       Row(
//                         mainAxisAlignment:
//                         MainAxisAlignment.spaceEvenly,

//                         children:
//                         List.generate(4, (index) {

//                           return Container(
//                             width: 50,
//                             height: 50,

//                             decoration: BoxDecoration(
//                               color: MyColors.lightGreen2,
//                               borderRadius:
//                               BorderRadius.circular(10),

//                               border: Border.all(
//                                 color: controllers[index]
//                                     .text
//                                     .isNotEmpty
//                                     ? Colors.green
//                                     : Colors.grey.shade300,
//                               ),
//                             ),

//                             child: TextField(
//                               controller:
//                               controllers[index],

//                               focusNode:
//                               focusNodes[index],

//                               textAlign:
//                               TextAlign.center,

//                               keyboardType:
//                               TextInputType.number,

//                               maxLength: 1,

//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight:
//                                 FontWeight.w500,
//                               ),

//                               inputFormatters: [
//                                 FilteringTextInputFormatter
//                                     .digitsOnly,
//                               ],

//                               decoration:
//                               const InputDecoration(
//                                 counterText: '',
//                                 border:
//                                 InputBorder.none,
//                               ),

//                               onChanged: (value) =>
//                                   _onChanged(
//                                       value, index),
//                             ),
//                           );
//                         }),
//                       ),

//                       SizedBox(height: deviceHeight * 0.03),

//                       GestureDetector(
//                         onTap: _resendOTP,

//                         child: const Text(
//                           "Resend OTP",
//                           style: TextStyle(
//                             color:
//                             MyColors.appThemeLight,
//                             fontWeight:
//                             FontWeight.w600,
//                           ),
//                         ),
//                       ),

//                       SizedBox(height: deviceHeight * 0.07),
//                     ],
//                   ),
//                 ),
//               ),

//               Padding(
//                 padding: const EdgeInsets.all(20),

//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 50,

//                   child: ElevatedButton(
//                     onPressed:
//                     _isOtpComplete ? _verifyOTP : null,

//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                       MyColors.appThemeLight,
//                       shape:
//                       RoundedRectangleBorder(
//                         borderRadius:
//                         BorderRadius.circular(12),
//                       ),
//                     ),

//                     child: const Text(
//                       "Verify",
//                       style: TextStyle(
//                           fontSize: 16,
//                           fontWeight:
//                           FontWeight.w600,
//                           color: Colors.white
//                           ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/session_manager.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../api/firebase_api.dart';
import '../../../data/prefernces.dart';
import '../../../utils/config.dart';
import '../../../utils/my_colors.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with SingleTickerProviderStateMixin, CodeAutoFill {

  List<TextEditingController> controllers =
      List.generate(4, (_) => TextEditingController());

  List<FocusNode> focusNodes =
      List.generate(4, (_) => FocusNode());

  String? phoneNumber;
  String? userId;
  String? viewAs;
  bool isProperty = false;

  @override
  void initState() {
    super.initState();
    listenForCode();
  }

  @override
  void codeUpdated() {
    if (code != null && code!.isNotEmpty) {
      final digits = code!.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 4 && i < digits.length; i++) {
        controllers[i].text = digits[i];
      }
      setState(() {});
      if (digits.length >= 4) {
        _verifyOTP();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      phoneNumber = args['phone_number'] ?? args['phone'];
      userId = args['user_id']?.toString();
      isProperty = args['is_property'] == true ||
          viewAs == 'property' ||
          args['property'] == true ||
          args['property'] == 'true' ||
          args['property'] == '1' ||
          args['property'] == 'property';

      final passedOtp = args['otp']?.toString();
      if (passedOtp != null && passedOtp.isNotEmpty) {
        for (int i = 0; i < 4 && i < passedOtp.length; i++) {
          controllers[i].text = passedOtp[i];
        }
      }
    }
  }

  @override
  void dispose() {
    cancel();
    for (var c in controllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length > 1) {
      // User pasted full OTP or OS autofilled it
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 4; i++) {
        if (i < digits.length) {
          controllers[i].text = digits[i];
        }
      }
      if (digits.isNotEmpty) {
        int nextFocus = (digits.length >= 4) ? 3 : digits.length;
        focusNodes[nextFocus].requestFocus();
      }
      setState(() {});
      return;
    }
    if (value.isNotEmpty && index < 3) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  bool get _isOtpComplete =>
      controllers.every((c) => c.text.isNotEmpty);

  void _showAnimatedSuccess(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => Center(
        child: Container(
          width: 260,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.15),
                blurRadius: 20,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
      transitionBuilder: (_, animation, __, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(animation.value),
        child: child,
      ),
    );

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  void _showAutoSuccessAndRedirect({
    required String message,
    required VoidCallback onComplete,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "",
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => Center(
        child: Container(
          width: 260,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
      transitionBuilder: (_, animation, __, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(animation.value),
        child: child,
      ),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // Close dialog
        }
        onComplete();
      }
    });
  }

  Future<void> _resendOTP() async {
    if (!await UtilClass.checkInternet()) {
      UtilClass.showAlertDialog(
          context: context, message: "No internet connection");
      return;
    }
    try {
      final response = await Repository.NewPostApiService(
          EndPoints.resendOTP, {"user_id": userId ?? ""});
      if (response["status"] == "valid") {
        listenForCode();
        _showAnimatedSuccess("OTP Sent Successfully");
      } else {
        UtilClass.showAlertDialog(
            context: context,
            message: "Please try Again after Sometime");
      }
    } catch (e) {
      UtilClass.showAlertDialog(
          context: context, message: "Something went wrong $e");
    }
  }

  Future<void> _verifyOTP() async {
    final otp = controllers.map((c) => c.text).join();

    if (!await UtilClass.checkInternet()) {
      UtilClass.showAlertDialog(
          context: context, message: "No internet connection");
      return;
    }

    UtilClass.showProgress(context: context);

    try {
      final token = await FirebaseApi.getFCMToken() ?? "testing";
      final response = await Repository.postApiService(
        EndPoints.newVerifyOtpApi,
        {"user_id": userId ?? "", "otp": otp, "token": token},
      );

      UtilClass.hideProgress();

      final parsed = json.decode(response);

      if (parsed["status"] == "valid") {
        await SessionManager.setLoggedIn(true);
        if (userId != null && userId!.isNotEmpty) {
          await Preferences.setUserID(userId!);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userId!);
        }

        _showAutoSuccessAndRedirect(
          message: "Login Successful!",
          onComplete: () {
            if (!mounted) return;
            if (viewAs == "property" || isProperty == true) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Config.scheduleVisitRouteName,
                (route) => false,
                arguments: {
                  "user_id": userId ?? "",
                  "phone_number": phoneNumber ?? "",
                  "view_as": "property",
                },
              );
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Config.homeRouteName,
                (route) => false,
                arguments: {
                  "user_id": userId ?? "",
                  "phone_number": phoneNumber ?? "",
                },
              );
            }
          },
        );
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      UtilClass.hideProgress();
      UtilClass.showAlertDialog(
          context: context,
          message: "Something went wrong. Please try again.");
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 60),
            const SizedBox(height: 15),
            const Text("OTP not matched",
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Ok", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Let Flutter push content up naturally when keyboard opens
      resizeToAvoidBottomInset: true,
      backgroundColor: MyColors.lightGreen,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 8, right: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        color: MyColors.appThemeLight),
                  ),
                  const SizedBox(width: 45),
                  const Text(
                    "OTP Verification",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // ── Scrollable body — shrinks when keyboard appears ─────────────
            Expanded(
              child: SingleChildScrollView(
                // ✅ Ensures content scrolls above keyboard
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    Image.asset("assets/images/otpVerifyImg.png",
                        width: 180),

                    const SizedBox(height: 32),

                    Text(
                      'Enter the code we sent to the number',
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      phoneNumber ?? "",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 32),

                    // ── OTP boxes ───────────────────────────────────────────
                    AutofillGroup(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: MyColors.lightGreen2,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: controllers[index].text.isNotEmpty
                                    ? Colors.green
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: TextField(
                              controller: controllers[index],
                              focusNode: focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              autofillHints: const [AutofillHints.oneTimeCode],
                              maxLength: 4,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                              ),
                              onChanged: (v) => _onChanged(v, index),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: _resendOTP,
                      child: const Text(
                        "Resend OTP",
                        style: TextStyle(
                            color: MyColors.appThemeLight,
                            fontWeight: FontWeight.w600),
                      ),
                    ),

                    // ✅ Extra bottom padding so content clears the Verify button
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // ── Verify button — always pinned at bottom ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isOtpComplete ? _verifyOTP : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.appThemeLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Verify",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}