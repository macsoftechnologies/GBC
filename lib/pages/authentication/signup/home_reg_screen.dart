


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gobuddy_customer_app/data/prefernces.dart';
import 'package:gobuddy_customer_app/models/registration_model.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import '../../../api/firebase_api.dart';
import '../../../utils/my_colors.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';


class HomeRegScreen extends StatefulWidget {
  const HomeRegScreen({super.key});

  @override
  _HomeRegScreenState createState() => _HomeRegScreenState();
}


double? _latitude;
double? _longitude;
String? _fullAddress;
class _HomeRegScreenState extends State<HomeRegScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();

  String? _deviceToken;
  GetRegistrationModel? pushintoRegistrationModel;
  GetRegistrationModel?getmydata;
  String?phoneNumber;
  dynamic userId;

  late AnimationController leafController;
  late AnimationController floatingController;

  late Animation<double> leftLeaf;
  late Animation<double> rightLeaf;
  late Animation<double> floatingMan;

  @override
  void initState() {
    super.initState();
    _initFocusListeners();
    // _getDeviceToken();

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

  void _initFocusListeners() {
    _nameFocus.addListener(() => setState(() {}));
    _phoneFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _addressFocus.addListener(() => setState(() {}));
  }



// Show a loading dialog
static void showProgress({required BuildContext context}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
}

// Hide the loading dialog
static void hideProgress({required BuildContext context}) {
  Navigator.of(context, rootNavigator: true).pop();
}

  @override
  void dispose() {
    leafController.dispose();
    floatingController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();

    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }


 


 
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  // Check for permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception(
      'Location permissions are permanently denied.',
    );
  }

  // If permissions granted, return the position
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

callLocation() async {
  await requestLocationPermission(); 

  UtilClass.showProgress(context: context);

  try {
    Position position = await _determinePosition();

    _latitude = position.latitude;
    _longitude = position.longitude;

    String address = await _getAddressFromLatLng(position);
    _addressController.text = address;

    print("Latitude: $_latitude");
    print("Longitude: $_longitude");
    print("Address: $address");

    UtilClass.hideProgress(context: context);
  } catch (e) {
    UtilClass.hideProgress(context: context);
    Fluttertoast.showToast(msg: "Failed to get location: $e");
  }
}


Future<void> requestLocationPermission() async {
  var status = await Permission.location.request();

  if (status.isGranted) {
    print("✅ Location permission granted");
  } else if (status.isPermanentlyDenied) {
    Fluttertoast.showToast(msg: "Location permission permanently denied. Open settings.");
    openAppSettings(); // from permission_handler
  } else {
    Fluttertoast.showToast(msg: "Location permission denied.");
  }
}

Future<String> _getAddressFromLatLng(Position position) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
    } else {
      return "Address not found";
    }
  } catch (e) {
    return "Error: $e";
  }
}



Future<void> callSignupApi() async {
  bool internet = await UtilClass.checkInternet();
  if (!internet) {
    UtilClass.showAlertDialog(
      context: context,
      message: "No Internet Connection",
    );
    return;
  }

  UtilClass.showProgress(context: context);

  try {
    final token = await FirebaseApi.getFCMToken() ?? _deviceToken ?? "testing";
    final response = await Repository.NewPostApiService(
      EndPoints.newSignupApi,
      {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone_number": _phoneController.text.trim(),
        "password" : "",
        "terms_and_conditions" : "",
        "latitude": _latitude?.toString() ?? "",
        "longitude": _longitude?.toString() ?? "",
        "location": _fullAddress ?? _addressController.text.trim(),
        "landmark" : _fullAddress?? _addressController.text.trim(),
        "token": token,
        "property": "home-route",
        "dob": "",
        "place_id"  : 0
      },
    );

    final Map<String, dynamic> jsonResponse = 
        response is String ? json.decode(response as String) : Map<String, dynamic>.from(response);

    if (jsonResponse['status'] == 'valid') {
      final registrationModel = GetRegistrationModel.fromJson(jsonResponse);
      setState(() {
        pushintoRegistrationModel = registrationModel;
        phoneNumber = registrationModel.phoneNumber ?? "";
        userId = registrationModel.userId ?? "";
      });



      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          Future.delayed(const Duration(milliseconds: 1300), () {
            if (Navigator.canPop(ctx)) {
              Navigator.pop(ctx);
            }
            if (!mounted) return;
            Navigator.pushNamed(
              context,
              Config.otpRouteName,
              arguments: {
                "phone_number": phoneNumber,
                "user_id": userId,
                "view_as": "customer",
              },
            );
          });
          return Center(
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
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 14),
                  Text(
                    jsonResponse['message'] ?? "Registration Successful!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      UtilClass.showAlertDialog(
        context: context,
        message: jsonResponse['message'] ?? "Registration Failed",
      );
    }
  } catch (e, stackTrace) {
    debugPrint("Signup Error: $e");
   
  } finally {
    UtilClass.hideProgress();
  }
}

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: MyColors.appThemeLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF19a64b),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/images/whiteLeftArrow.png",
                          width: 9,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Config.guestHomeScreen,
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
                        "Let's Get You Set Up!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: deviceHeight * 0.25,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: MyColors.cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 80),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _nameController,
                                focusNode: _nameFocus,
                                label: "Name",
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? "Name is required"
                                        : null,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _phoneController,
                                focusNode: _phoneFocus,
                                label: "Phone Number",
                           
                                prefix: "+91 ",
                                maxLength  :10,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Phone number is required";
                                  }
                                  if (value.length < 10) {
                                    return "Enter a valid phone number";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                label: "Email (Optional)",
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value != null &&
                                      value.isNotEmpty &&
                                      !RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                          .hasMatch(value)) {
                                    return "Enter a valid email";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _addressController,
                                focusNode: _addressFocus,
                                label: "Address",
                                validator: (value) => value == null || value.isEmpty
                                    ? "Address is required"
                                    : null,
                                suffixIcon: GestureDetector(
                                  onTap: () async {
                                    if (_latitude == null || _longitude == null) {
                                      await callLocation();
                                    }
                                    final result = await Navigator.pushNamed(
                                      context,
                                      Config.googleMapScreen,
                                      arguments: {
                                        "latitude": _latitude ?? 17.6868,
                                        "longitude": _longitude ?? 83.2185,
                                        "address": _addressController.text.trim(),
                                      },
                                    );
                                    if (result is Map) {
                                      setState(() {
                                        if (result['latitude'] != null) {
                                          _latitude = (result['latitude'] as num).toDouble();
                                        }
                                        if (result['longitude'] != null) {
                                          _longitude = (result['longitude'] as num).toDouble();
                                        }
                                        if (result['address'] != null &&
                                            result['address'].toString().trim().isNotEmpty) {
                                          _addressController.text = result['address'].toString().trim();
                                          _fullAddress = _addressController.text;
                                        }
                                      });
                                    }
                                  },
                                  child: const Icon(
                                    Icons.my_location,
                                    color: Colors.black54,
                                    size: 20,
                                  ),
                                ),
                              ),
                             
                             
                              const SizedBox(height: 25),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      callSignupApi();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MyColors.appThemeLight,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Register",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
 Padding(
  padding: const EdgeInsets.only(top: 20),  
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text('Already have an account? '),
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, Config.loginRouteName);
        },
        child: const Text(
          'Login',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ],
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    String? prefix,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
      int? maxLength,
  }) {
    bool isFocused = focusNode.hasFocus;
    Color activeColor = MyColors.appThemeLight;
    Color inactiveColor = Colors.grey;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      keyboardType: keyboardType ?? TextInputType.text,
        maxLength: maxLength,
      style: const TextStyle(fontSize: 14),

      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: isFocused ? activeColor : inactiveColor,
        ),
        prefixText: prefix,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: MyColors.cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: inactiveColor, width: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: activeColor, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

