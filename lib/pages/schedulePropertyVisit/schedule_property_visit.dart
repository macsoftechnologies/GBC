import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gobuddy_customer_app/models/main_category.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../components/details_submitted.dart';
import '../../components/schedule_visit_screen.dart';
import '../../utils/config.dart';

class SchedulePropertyVisitScreen extends StatefulWidget {
  const SchedulePropertyVisitScreen({super.key});
  

  @override
  State<SchedulePropertyVisitScreen> createState() =>
      _SchedulePropertyVisitScreenState();
}


double? _latitude;
double? _longitude;
String? _fullAddress;




class _SchedulePropertyVisitScreenState
    extends State<SchedulePropertyVisitScreen> {
  late String userId;
  late String date;
  late String time;
  
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _altPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();


 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    userId = args['user_id'] ?? '';
    date = args['date'] ?? '';
    time = args['time'] ?? '';
    print("Received userId: $userId");
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

Future<void> requestLocationPermission()async {
  var status = await Permission.location.request();
   if(status.isGranted){
    print("Location Permission Granted");
   }else if (status.isPermanentlyDenied){
      UtilClass.showAlertDialog(context: context, message: "Location Permission is permenantly denied ! open Settings.");
      openAppSettings();
   }else{
    Fluttertoast.showToast(msg: "Location Permission Denied");
   }
}

@override
void initState() {
  super.initState();
  _callMainCategories(); 
}



  String selectedService = "";
 List<MainCategory> services = [];
List<String> selectedServiceIds = [];
List<String> selectedServiceNames = [];
List<MainCategory> selectedCategoriesList = [];
 List<String> categoryList = [];


  DateTime? selectedDate;
  String? selectedTime;

  bool _dateTimeError = false;
  bool _submitted = false;

  final double _fieldHeight = 50;

String formattedDateTime() {
  if (selectedDate == null || selectedTime == null) return "";

  final datePart = DateFormat('yyyy-MM-dd').format(selectedDate!);
  final fullDateTime = "$datePart $selectedTime";

  return fullDateTime;
}




Future<void> _callMainCategories() async {
  bool internet = await UtilClass.checkInternet();
  if (!internet) return;


  try {
    final response = await Repository.getApiService(EndPoints.getMainHeadCategories);
    UtilClass.hideProgress();

    Map<String, dynamic> parsed = response is String
        ? json.decode(response)
        : response;

    if (parsed["status"] == "valid") {
      List<dynamic> categoriesList = parsed["categories"];

      setState(() {
        services = categoriesList.map((item) => MainCategory(
          id: item["id"].toString(),
          category: item["category"].toString().trim(),
        )).toList();
      });
    } else {
      UtilClass.showAlertDialog(
        context: context,
        message: parsed["message"] ?? "Something went wrong",
      );
    }
  } catch (e) {
    UtilClass.hideProgress();
    print("Error: $e");
    UtilClass.showAlertDialog(
      context: context,
      message: "Failed to load categories",
    );
  }
}



 Future<void> _callUserId() async {
  bool internet = await UtilClass.checkInternet();

  if (!internet) return;


   try {
    String finalDateTime = formattedDateTime();

     final requestBody = {
      "alternate_phone": _altPhoneController.text.trim(),
      "user_id": userId,
      "date": finalDateTime,
      "category": categoryList,
      "property": _fullAddress ?? _addressController.text.trim(),
    };
    print(requestBody);



    final response = await Repository.postApiRawService(
      EndPoints.AddSchedulePropertyVisitAPi,
      requestBody,
    );

    UtilClass.hideProgress();

    Map<String, dynamic> parsed = json.decode(response);

    if (parsed["status"] == "valid") {
      print("Property Scheduled Successfully");
      // Consider adding a success message or redirect here
    } else {
      UtilClass.showAlertDialog(
        context: context,
        message: parsed["message"] ?? "Something Went Wrong!",
      );
    }
  } catch (e, stacktrace) {
    UtilClass.hideProgress();
    print(stacktrace);
    UtilClass.showAlertDialog(
      context: context,
      message: "Error: ${e.toString()}",
    );
  }
}

  // ---------------- Service Bottom Sheet ----------------
  void _openServicesBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            double sheetHeight = MediaQuery.of(context).size.height * 0.6;

            return SizedBox(
              height: sheetHeight,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Service(s) Type",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

              Expanded(
  child: SingleChildScrollView(
    child: Column(
      children: services.map((service) {
        bool isSelected = selectedServiceIds.contains(service.id);

        return Column(
          children: [
            InkWell(
              onTap: () {
                setStateBottomSheet(() {
                  if (isSelected) {
                    selectedServiceIds.remove(service.id);
                  } else {
                    selectedServiceIds.add(service.id);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.category,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      activeColor: Colors.green,
                      value: isSelected,
                      onChanged: (value) {
                        setStateBottomSheet(() {
                          if (value == true) {
                            selectedServiceIds.add(service.id);
                          } else {
                            selectedServiceIds.remove(service.id);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey.shade300,
              thickness: 1,
              height: 0,
            ),
          ],
        );
      }).toList(),
    ),
  ),
),

const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: selectedServiceIds.isNotEmpty
          ? const Color(0xFF1DB954)
          : Colors.grey.shade300,
      foregroundColor: selectedServiceIds.isNotEmpty
          ? Colors.white
          : Colors.black54,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  onPressed: selectedServiceIds.isNotEmpty
    ? () async {
        Navigator.pop(context);

        // Get selected categories from IDs
        selectedCategoriesList = services
            .where((service) => selectedServiceIds.contains(service.id))
            .toList();

        // Display selected category names (for UI)
        selectedService = selectedCategoriesList
            .map((cat) => cat.category)
            .join(", ");

         String idsCsv = selectedCategoriesList.map((cat) => cat.id).join(",");
categoryList = [idsCsv]; // ✅ Now this works


        // ✅ Wrap in a list to get ["1,2,3"]
       


        // Send to your API
        // await Repository.postApiService(EndPoints.yourNextEndpoint, payload);
      }
    : null,


    child: const Text("Proceed"),
  ),
),

                 
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- Date & Time Picker ----------------
  void _selectDateTime() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScheduleVisitScreen();
      },
    );

    if (result != null && result is Map) {
      setState(() {
        // Parse the date string to DateTime object
        selectedDate = DateTime.parse(result['date']);
        selectedTime = result['time'];
        _dateTimeError = false;
      });
    }
  }

  // ---------------- Reusable Fields ----------------
  Widget _buildLabeledField(
      {required String label, required Widget child, required double h}) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.012),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? prefixText,
    IconData? suffixIcon,
  }) {
    return SizedBox(
      height: _fieldHeight,
      child: TextFormField(
        controller: controller,
        validator: validator,
        autovalidateMode:
        _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefixText,
          suffixIcon:
          suffixIcon != null ? Icon(suffixIcon, color: Colors.black54) : null,
          filled: true,
          fillColor: MyColors.lightGreen2,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      {required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: _fieldHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: MyColors.lightGreen2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: text.contains("Select") ? Colors.grey : Colors.black)),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField({required VoidCallback onTap}) {
    String displayText;

    if (selectedDate == null) {
      displayText = "Select Date";
    } else {
      final dateFormat = DateFormat('dd/MM/yyyy');
      displayText = "${dateFormat.format(selectedDate!)} ${selectedTime ?? ''}";
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: _fieldHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: MyColors.lightGreen2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(displayText, style: TextStyle(
                color: selectedDate == null ? Colors.grey : Colors.black)),
            const Icon(Icons.calendar_today_outlined, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  // ---------------- Submit Handler ----------------
  void _handleSubmit() {
    setState(() {
      _submitted = true;
    });

    if (_formKey.currentState!.validate()) {
      if (selectedServiceIds.isEmpty) {
        return;
      }

      if (selectedDate == null || selectedTime == null) {
        setState(() {
          _dateTimeError = true;
        });
        return;
      }

      _callUserId();
     

      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(seconds: 3), () {
            // ignore: use_build_context_synchronously
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop(); // close the dialog first
            }
            Navigator.of(
              // ignore: use_build_context_synchronously
              context,
            ).pushNamedAndRemoveUntil(
              Config.homeRouteName,
              (route) => false,
              arguments: {"user_id": userId},
            );
          });

          return const DetailsSubmittedDialog(
            title: "Details Submitted Successful",
            subtitle: "Thank You for request!.One of  of our represetatives will contact for assessment and get the needed services scheduled stay tuned!.",
            image: "assets/images/successIcon.png",
          );
        },
      );
    }
  }



  // ---------------- Build UI ----------------
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: MyColors.appThemeLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding:
              EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF19a64b),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset("assets/images/whiteLeftArrow.png",
                            width: 9),
                      ),
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Text(
                    "Schedule Property Visit!",
                    style: TextStyle(
                      fontSize: w * 0.05,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Expanded(
              child: Container(
                width: double.infinity,
                color: MyColors.lightGreen,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(w * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Tell us a little more about your need!",
                            style: TextStyle(
                                fontSize: w * 0.04, color: Colors.black87),
                          ),
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(w * 0.045),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: h * 0.01),

                              // Alternate Phone
                              _buildLabeledField(
                                label: "Alternate Phone Number (Optional)",
                                child: _buildTextFormField(
                                  controller: _altPhoneController,
                                  prefixText: "+91 ",
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return null;
                                    }
                                    if (!RegExp(r'^[0-9]{10}$')
                                        .hasMatch(value)) {
                                      return "Enter valid 10-digit number";
                                    }
                                    return null;
                                  },
                                ),
                                h: h,
                              ),

                              // Address
                              _buildTextField(
                            controller: _addressController,
                            
                            label: "Address",
                           
                            isRequired: true,
                            suffixIcon: GestureDetector(
                              onTap: () async{
                                await callLocation();
                                if (_latitude != null && _longitude != null) {
    Navigator.pushNamed(
      context,
      Config.googleMapScreen, // or Config.GoogleMap(), depending on your route setup
      arguments: {
        "latitude": _latitude,
        "longitude": _longitude,
        "address": _addressController.text.trim(),
      },
    );
  } else {
    Fluttertoast.showToast(msg: "Location not available.");
  }
                              },
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.black54,
                                size: 20,
                              ),
                            ),
                          
                          
                          ),
                        
                              // Services
                              _buildLabeledField(
                                label: "Select type of Service(s) you need",
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDropdownField(
                                      text: selectedService.isEmpty
                                          ? "Select Services"
                                          : selectedService,
                                      onTap: _openServicesBottomSheet,
                                    ),
                                    if (_submitted && selectedServiceIds.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            top: 4.0, left: 8.0),
                                        child: Text(
                                          "Please select at least one service",
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                                h: h,
                              ),

                              // Date (Required)
                              _buildLabeledField(
                                label:
                                "Select Time and Date for property visit",
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDatePickerField(
                                      onTap: _selectDateTime,
                                    ),
                                    if (_submitted &&
                                        (_dateTimeError || selectedDate == null || selectedTime == null))
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            top: 4.0, left: 8.0),
                                        child: Text(
                                          "Please select a valid date & time",
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                                h: h,
                              ),

                              SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Submit Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(w * 0.045, 0, w * 0.045, h * 0.02),
        color: MyColors.lightGreen,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1DB954),
            padding: EdgeInsets.symmetric(vertical: h * 0.018),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _handleSubmit,
          child: const Text(
            "Submit",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ),
    );
  }



   Widget _buildTextField({
    required TextEditingController controller,

    required String label,
    String? prefix,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? errorText,
    Function(String)? onChanged,
    bool isRequired = true,
  }) {
    
    Color activeColor = MyColors.appThemeLight;
    Color inactiveColor = Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          style: const TextStyle(fontSize: 14),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label + (isRequired ? " *" : ""),
            labelStyle: TextStyle(
              fontSize: 14,
            
            ),
            prefixText: prefix,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color.fromARGB(255, 199, 235, 220),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: errorText != null ? Colors.red : inactiveColor,
                  width: 0.5
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: errorText != null ? Colors.red : activeColor,
                  width: 1
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
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }


}