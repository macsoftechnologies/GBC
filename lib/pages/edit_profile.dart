import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:gobuddy_customer_app/models/my_profile_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'package:gobuddy_customer_app/data/prefernces.dart';
import 'package:gobuddy_customer_app/components/customer_profile_avatar.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfile> {
  CustomerDetails? getcustomerDetails;
  String? userId;

  File? _profileImage;
  final ImagePicker picker = ImagePicker();
  bool _isInit = true;

  // 🔥 TEXT CONTROLLERS
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController dobCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController landmarkCtrl = TextEditingController();
  final TextEditingController companyCtrl = TextEditingController();
  final TextEditingController alterPhoneNumberCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['user_id'] != null) {
        userId = args['user_id']?.toString();
      }
      _initAndFetch();
      _isInit = false;
    }
  }

  Future<void> _initAndFetch() async {
    if (userId == null || userId!.isEmpty) {
      userId = await Preferences.getUserID();
    }
    _getUserProfileDetails();
  }

  // 🔥 IMAGE PICKER
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // 🔥 FETCH USER PROFILE
  Future<void> _getUserProfileDetails() async {
    bool internet = await UtilClass.checkInternet();
    if (!internet) {
      UtilClass.showAlertDialog(
        context: context,
        message: "No Internet Connection!",
      );
      return;
    }

    try {
      if (userId == null || userId!.isEmpty) {
        userId = await Preferences.getUserID();
      }
      if (userId == null || userId!.isEmpty) return;

      final response = await http.post(
        Uri.parse(EndPoints.userprofileDetails),
        body: {"id": userId},
      );

      if (response.statusCode == 200) {
        final profileData = GetUserProfileDetails.fromJson(
          jsonDecode(response.body),
        );

        setState(() {
          getcustomerDetails = profileData.customerDetails;
          nameCtrl.text = getcustomerDetails?.name ?? "";
          emailCtrl.text = getcustomerDetails?.email ?? "";
          phoneCtrl.text = getcustomerDetails?.phoneNumber ?? "";
          dobCtrl.text = getcustomerDetails?.dob ?? "";
          addressCtrl.text = getcustomerDetails?.address ?? "";
          locationCtrl.text = getcustomerDetails?.location ?? "";
          landmarkCtrl.text = getcustomerDetails?.landmark ?? "";
          companyCtrl.text = getcustomerDetails?.companyName ?? "";
          alterPhoneNumberCtrl.text =
              getcustomerDetails?.alternatePhoneNumber ?? "";
        });
      }
    } catch (_) {
      UtilClass.showAlertDialog(
        context: context,
        message: "Something Went Wrong!",
      );
    }
  }

  Future<void> _updateUserProfile() async {
    bool internet = await UtilClass.checkInternet();
    if (!internet) {
      UtilClass.showAlertDialog(
        context: context,
        message: "No Internet Connection!",
      );
      return;
    }
    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final address = addressCtrl.text.trim();

    if (name.isEmpty) {
      UtilClass.showAlertDialog(
        context: context,
        message: "Name cannot be empty",
      );
      return;
    }
    if (phone.isNotEmpty && phone.length < 10) {
      UtilClass.showAlertDialog(
        context: context,
        message: "Phone number must be at least 10 digits",
      );
      return;
    }
    if (address.isEmpty) {
      UtilClass.showAlertDialog(
        context: context,
        message: "Address cannot be empty",
      );
      return;
    }

    UtilClass.showProgress(context: context);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(EndPoints.CustomerProfileupdate),
      );

      // TEXT FIELDS
      request.fields.addAll({
        "user_id": userId ?? "",
        "name": nameCtrl.text.trim(),
        "phone_number": phoneCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "dob": dobCtrl.text.trim(),
        "address": addressCtrl.text.trim(),
        "location": locationCtrl.text.trim(),
        "landmark": landmarkCtrl.text.trim(),
        "company_name": companyCtrl.text.trim(),
        "terms_and_conditions": "accepted",
        "latitude": getcustomerDetails?.latitude ?? "17.6868",
        "longitude": getcustomerDetails?.longitude ?? "83.2185",
        "place_id": getcustomerDetails?.placeId?.toString() ?? "1",
        "alternate_phone_number": alterPhoneNumberCtrl.text.trim(),
      });

      // IMAGE FILE
      if (_profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile', _profileImage!.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      UtilClass.hideProgress();
      final decoded = jsonDecode(responseBody);

      if (decoded['status'] == "valid" ||
          decoded['status'] == "success" ||
          decoded['status'] == true) {
        UtilClass.showAlertDialog(
          context: context,
          message: decoded['message'] ?? "Profile Updated Successfully",
          onOkClick: () {
            Navigator.pop(context, true);
          },
        );
      } else {
        UtilClass.showAlertDialog(
          context: context,
          message: decoded['message'] ?? "Update Failed!",
        );
      }
    } catch (_) {
      UtilClass.hideProgress();
      UtilClass.showAlertDialog(context: context, message: "Update Failed!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: MyColors.appThemeLight,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: getcustomerDetails == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 40,
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        child: ClipOval(
                          child: _profileImage != null
                              ? Image.file(
                                  _profileImage!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                              : CustomerProfileAvatar(
                                  profile: getcustomerDetails?.profile,
                                  size: 120,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: MyColors.appThemeLight,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  _buildInput("Name", nameCtrl),
                  const SizedBox(height: 15),
                  _buildInputLocked("Email  Locked", emailCtrl, readOnly: true),
                  const SizedBox(height: 15),

                  _buildInput(
                    "Phone Number",
                    phoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),
                  _buildInput(
                    "Date of Birth",
                    dobCtrl,
                    readOnly: true,
                    onTap: () async {
                      final parsed = DateTime.tryParse(dobCtrl.text.trim());
                      final initial =
                          (parsed != null && parsed.isBefore(DateTime.now()))
                          ? parsed
                          : DateTime(1995, 1, 1);
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(1920),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          dobCtrl.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildInput("Address", addressCtrl, maxLines: 3),
                  const SizedBox(height: 15),
                  _buildInput("Location", locationCtrl),
                  const SizedBox(height: 15),
                  _buildInput("Landmark", landmarkCtrl),
                  const SizedBox(height: 15),
                  _buildInput("Company Name", companyCtrl),
                  const SizedBox(height: 15),
                  _buildInput(
                    "Alternate Phone Number",
                    alterPhoneNumberCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: MyColors.appThemeLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _updateUserProfile,
                    child: const Text(
                      "Update Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

Widget _buildInputLocked(
  String label,
  TextEditingController controller, {
  int maxLines = 1,
  bool readOnly = false,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    readOnly: readOnly,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: readOnly ? Colors.grey[200] : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
