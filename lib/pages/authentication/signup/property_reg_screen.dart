// ignore_for_file: use_build_context_synchronously, avoid_print, unused_element, unused_local_variable
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gobuddy_customer_app/data/prefernces.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../api/firebase_api.dart';
import '../../../utils/my_colors.dart';

// import '../schedulePropertyVisit/schedule_property_visit.dart';

class PropertyRegScreen extends StatefulWidget {
  const PropertyRegScreen({super.key});

  @override
  State<PropertyRegScreen> createState() => _PropertyRegScreenState();
}

double? _latitude;
double? _longitude;
String? _fullAddress;

class _PropertyRegScreenState extends State<PropertyRegScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _companyFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();

  String? _deviceToken;

  // Error messages for each field
  String? _nameError;
  String? _phoneError;
  String? _emailError;
  String? _companyError;
  String? _addressError;

  @override
  void initState() {
    super.initState();

    // Add listeners to focus nodes to update UI on focus change
    _nameFocus.addListener(() => setState(() {}));
    _phoneFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _companyFocus.addListener(() => setState(() {}));
    _addressFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // Dispose all focus nodes
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _companyFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  // Validation methods
  void _validateName(String value) {
    if (value.isEmpty) {
      setState(() {
        _nameError = 'Name is required';
      });
    } else if (value.length < 2) {
      setState(() {
        _nameError = 'Name must be at least 2 characters';
      });
    } else {
      setState(() {
        _nameError = null;
      });
    }
  }

  void _validatePhone(String value) {
    if (value.isEmpty) {
      setState(() {
        _phoneError = 'Phone number is required';
      });
    } else if (value.length != 10) {
      setState(() {
        _phoneError = 'Phone number must be 10 digits';
      });
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      setState(() {
        _phoneError = 'Phone number must contain only digits';
      });
    } else {
      setState(() {
        _phoneError = null;
      });
    }
  }

  void _validateEmail(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value.trim())) {
        setState(() {
          _emailError = 'Please enter a valid email address';
        });
      } else {
        setState(() {
          _emailError = null;
        });
      }
    }
  }

  void _validateCompany(String value) {
    if (value.isEmpty) {
      setState(() {
        _companyError = 'Company/Property name is required';
      });
    } else if (value.length < 2) {
      setState(() {
        _companyError = 'Company/Property name must be at least 2 characters';
      });
    } else {
      setState(() {
        _companyError = null;
      });
    }
  }

  void _validateAddress(String value) {
    if (value.isEmpty) {
      setState(() {
        _addressError = 'Address is required';
      });
    } else if (value.length < 5) {
      setState(() {
        _addressError = 'Address must be at least 5 characters';
      });
    } else {
      setState(() {
        _addressError = null;
      });
    }
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
      throw Exception('Location permissions are permanently denied.');
    }

    // If permissions granted, return the position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
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

  callLocation() async {
    await requestLocationPermission(); // 👈 Ensure this is called first

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
      print("Location Permission Granted");
    } else if (status.isPermanentlyDenied) {
      UtilClass.showAlertDialog(
        context: context,
        message: "Location Permission is permenantly denied ! open Settings.",
      );
      openAppSettings();
    } else {
      Fluttertoast.showToast(msg: "Location Permission Denied");
    }
  }

  Future<void> callPropertyMaintanceApi() async {
    bool internet = await UtilClass.checkInternet();
    if (!internet) {
      UtilClass.showAlertDialog(
        context: context,
        message: "No Internet Connection",
      );
      return;
    }

    // Show loader before making the API call
    UtilClass.showProgress(context: context);

    try {
      final token =
          await FirebaseApi.getFCMToken() ?? _deviceToken ?? "testing";
      final dynamic response =
          await Repository.NewPostApiService(EndPoints.newSignupApi, {
            "name": _nameController.text.trim(),
            "email": _emailController.text.trim(),
            "phone_number": _phoneController.text.trim(),
            "property": 'property-route',
            "company": _companyController.text.trim(),
            "location": _fullAddress ?? _addressController.text.trim(),
            "landmark": _fullAddress ?? _addressController.text.trim(),
            "password": "",
            "terms_and_conditions": "",
            "token": token,
            "latitude": _latitude?.toString() ?? "",
            "longitude": _longitude?.toString() ?? "",
            "dob": "",
            "place_id": 0,
          });

      // Hide loader after response
      UtilClass.hideProgress();

      // Clean and parse response if it contains any PHP warnings
      Map<String, dynamic> parsed = {};
      if (response is String) {
        String clean = response;
        int firstBrace = clean.indexOf('{');
        int lastBrace = clean.lastIndexOf('}');
        if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
          clean = clean.substring(firstBrace, lastBrace + 1);
        }
        try {
          parsed = json.decode(clean);
        } catch (e) {
          parsed = {};
        }
      } else if (response is Map) {
        parsed = Map<String, dynamic>.from(response);
      }

      if (parsed["status"] == "valid") {
        final userId = parsed["user_id"]?.toString() ?? "";
        final phoneNumber =
            parsed["phone_number"]?.toString() ?? _phoneController.text.trim();

        Preferences.setUserDetails(jsonEncode(parsed));
        if (userId.isNotEmpty) {
          await Preferences.setUserID(userId);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userId);
        }

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
                  "view_as": "property",
                  "is_property": true,
                },
              );
            });
            return Center(
              child: Container(
                width: 260,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
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
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 60,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      parsed["message"] ?? "Registration Successful!",
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
          message: parsed["message"] ?? "Customer registration failed",
        );
      }
    } catch (e, stacktrace) {
      UtilClass.hideProgress();
      print("API Error: $e");
      print(stacktrace);
      UtilClass.showAlertDialog(
        context: context,
        message: "An error occurred. Please try again.",
      );
    }
  }

  // Future<void> callPropertyMaintanceApi() async{
  //   bool internet = await UtilClass.checkInternet();
  //   if(internet){
  //     try {
  //       final response = await Repository.postApiService(EndPoints.newSignupApi, {
  //         "name" : _nameController.text.trim(),
  //         "email" : _emailController.text.trim(),
  //         "phone_number" : _phoneController.text.trim(),
  //         "property": 'property-route',
  //         "location" :  _addressController.text.trim(),
  //         "token": _deviceToken ?? "",
  //         "lattitude" : _latitude.toString() ?? "",
  //         "longitude" : _longitude.toString()?? "",
  //       });

  //       UtilClass.hideProgress();
  //       print("Response : $response" );

  //       Map<String, dynamic>parsed = json.decode(response);

  //        if(parsed["status"]== "valid"){
  //           print("Parsed user id ${parsed["user_id"]}");
  //           print("Parsed phone Number : ${parsed["phone_number"]}");

  //           final userId = parsed["user_id"]?.toString()??"";
  //           final phoneNumber = parsed["phone_number"]?.toString() ??"";

  //           Preferences.setUserDetails(jsonEncode(parsed));

  //          Navigator.pushNamed(
  //         context,
  //         Config.scheduleVisitRouteName,
  //         arguments: {
  //           "phone_number": phoneNumber,
  //           "user_id": userId,
  //           "view_as": "customer",
  //         },
  //       );

  //        }else {
  //          UtilClass.showAlertDialog(context: context
  //          , message: parsed["message"] ?? "Something went Wrong");
  //        }
  //     } catch (e, stacktrace) {
  //       UtilClass.hideProgress();
  //       print(stacktrace);
  //       UtilClass.showAlertDialog(context: context, message: e.toString());
  //     }
  //   }
  // }

  // Validate all fields
  bool _validateAllFields() {
    _validateName(_nameController.text);
    _validatePhone(_phoneController.text);
    _validateEmail(_emailController.text);
    _validateCompany(_companyController.text);
    _validateAddress(_addressController.text);

    bool isValid =
        _nameError == null &&
        _phoneError == null &&
        _emailError == null &&
        _companyError == null &&
        _addressError == null;

    if (!isValid) {
      Fluttertoast.showToast(
        msg: "Please fill in all required fields correctly",
      );
    }

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.06,
                16,
                screenWidth * 0.06,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

                  // Back button + Title + Skip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Material(
                          shape: const CircleBorder(),
                          elevation: 4,
                          shadowColor: Colors.black26,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  size: 18,
                                  color: MyColors.appThemeLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Property Maintainance",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: MyColors.darkGray,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: MyColors.appThemeLight,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: Text(
                      "Let's Get You Set Up!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.06,
                  3, // Added top padding to push the form down
                  screenWidth * 0.06,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: "Name",
                      focusNode: _nameFocus,
                      errorText: _nameError,
                      onChanged: _validateName,
                      isRequired: true,
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      label: "Phone Number",
                      prefix: "+91 ",
                      keyboardType: TextInputType.phone,
                      errorText: _phoneError,
                      onChanged: _validatePhone,
                      isRequired: true,
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _emailController,
                      label: "Email",
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                      onChanged: _validateEmail,
                      isRequired: true,
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _companyController,
                      label: "Company or Property Name",
                      focusNode: _companyFocus,
                      errorText: _companyError,
                      onChanged: _validateCompany,
                      isRequired: true,
                    ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _addressController,
                      focusNode: _addressFocus,
                      label: "Address",
                      errorText: _addressError,
                      onChanged: _validateAddress,
                      isRequired: true,
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
                                _latitude = (result['latitude'] as num)
                                    .toDouble();
                              }
                              if (result['longitude'] != null) {
                                _longitude = (result['longitude'] as num)
                                    .toDouble();
                              }
                              if (result['address'] != null &&
                                  result['address']
                                      .toString()
                                      .trim()
                                      .isNotEmpty) {
                                _addressController.text = result['address']
                                    .toString()
                                    .trim();
                                _validateAddress(_addressController.text);
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
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.appThemeLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          if (_validateAllFields()) {
                            callPropertyMaintanceApi();
                          }
                        },
                        child: const Text(
                          "Submit Details",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
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
    String? errorText,
    Function(String)? onChanged,
    bool isRequired = true,
  }) {
    bool isFocused = focusNode.hasFocus;
    Color activeColor = MyColors.appThemeLight;
    Color inactiveColor = Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType ?? TextInputType.text,
          style: const TextStyle(fontSize: 14),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label + (isRequired ? " *" : ""),
            labelStyle: TextStyle(
              fontSize: 14,
              color: isFocused ? activeColor : inactiveColor,
            ),
            prefixText: prefix,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: MyColors.cardColor,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : inactiveColor,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : activeColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 12.0),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
