import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/models/my_profile_model.dart';
import 'package:gobuddy_customer_app/pages/user/myadress.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'package:gobuddy_customer_app/utils/session_manager.dart';
import 'package:gobuddy_customer_app/data/prefernces.dart';
import 'package:gobuddy_customer_app/components/customer_profile_avatar.dart';



class AccountScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback? onBack;
  final VoidCallback? onProfileUpdated;

  const AccountScreen({super.key, this.userData, this.onBack, this.onProfileUpdated});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
 
  final int coins = 125;
  GetUserProfileDetails? pushintoUserProfile;
  CustomerDetails? getcustomerDetails;
  String _displayName = Preferences.getNameSync() ?? "";
  String _displayPhone = Preferences.getPhoneSync() ?? "";
  String _displayProfilePic = Preferences.getProfilePicSync() ?? "";

  @override
  void initState() {
    super.initState();
    _loadCachedUserInfo();
    _getUserProfileDetails();
  }

  Future<void> _loadCachedUserInfo() async {
    final cachedName = await Preferences.getName();
    final cachedPhone = await Preferences.getPhone();
    final cachedPic = await Preferences.getProfilePic();
    if (mounted) {
      setState(() {
        if (cachedName != null && cachedName.isNotEmpty) _displayName = cachedName;
        if (cachedPhone != null && cachedPhone.isNotEmpty) _displayPhone = cachedPhone;
        if (cachedPic != null && cachedPic.isNotEmpty) _displayProfilePic = cachedPic;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (getcustomerDetails == null) {
      _getUserProfileDetails();
    }
  }


Future<void> _getUserProfileDetails() async {
  bool internet = await UtilClass.checkInternet();
  if (!internet) {
    return;
  }

  try {
    String? uid = widget.userData?['user_id']?.toString();
    if (uid == null || uid.isEmpty) {
      uid = await Preferences.getUserID();
    }
    if (uid == null || uid.isEmpty) return;

    final userResponse = await Repository.NewPostApiService(
      EndPoints.userprofileDetails,
      {
        "id": uid,
      },
    );

    late Map<String, dynamic> jsonResponse;

    if (userResponse is String) {
      jsonResponse = json.decode(userResponse as String);
    } else if (userResponse is Map<String, dynamic>) {
      jsonResponse = userResponse;
    } else {
      jsonResponse = {};
    }

    final status = jsonResponse["status"];
    if (status == "valid" || status == "success" || status == true) {
      final profileData = GetUserProfileDetails.fromJson(jsonResponse);

      if (mounted) {
        setState(() {
          getcustomerDetails = profileData.customerDetails;
          if (getcustomerDetails?.name != null && getcustomerDetails!.name!.isNotEmpty) {
            _displayName = getcustomerDetails!.name!;
            Preferences.setName(_displayName);
          }
          if (getcustomerDetails?.phoneNumber != null && getcustomerDetails!.phoneNumber!.isNotEmpty) {
            _displayPhone = getcustomerDetails!.phoneNumber!;
            Preferences.setPhone(_displayPhone);
          }
          if (getcustomerDetails?.profile != null && getcustomerDetails!.profile!.isNotEmpty) {
            _displayProfilePic = getcustomerDetails!.profile!;
            Preferences.setProfilePic(_displayProfilePic);
          }
        });
      }
    }
  } catch (e) {
    debugPrint("Error loading profile: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    // Device dimensions for responsiveness
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

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
        backgroundColor: const Color(0xFFF7FBF8),
        body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: deviceHeight * 0.05, // safe top padding
                  bottom: deviceHeight * 0.03,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF009846),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 🔥 fixes overflow
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: deviceHeight * 0.02),
                    ClipOval(
                      child: CustomerProfileAvatar(
                        profile: _displayProfilePic.isNotEmpty ? _displayProfilePic : getcustomerDetails?.profile,
                        size: deviceWidth * 0.24,
                      ),
                    ),

                    SizedBox(height: deviceHeight * 0.015),
                    Text(
                      _displayName.isNotEmpty ? _displayName : (getcustomerDetails?.name ?? ""),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _displayPhone.isNotEmpty ? _displayPhone : (getcustomerDetails?.phoneNumber ?? ""),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: deviceHeight * 0.01),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange, width: 1),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/logoImg.png",
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            coins.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),


              // Options List
              // Account Menu Card
              Transform.translate(
                offset: Offset(0, -deviceHeight * 0.03), // 🔥 moves card up over green header
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
                  child: Card(
                    color: Colors.white, // cream color
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: deviceWidth * 0.04,
                        vertical: deviceHeight * 0.015,
                      ),
                      child: SingleChildScrollView(   // 👈 scrollable wrapper
                        child: Column(
                          children: [
                            buildMenuItem(
                                icon: Icons.person,
                                title: "Edit Profile",
                                onTap: () async {
                                  String? uid = widget.userData?['user_id']?.toString();
                                  if (uid == null || uid.isEmpty) {
                                    uid = await Preferences.getUserID();
                                  }
                                  final updated = await Navigator.pushNamed(
                                    context,
                                    Config.editprofilepath,
                                    arguments: {
                                      'user_id': uid,
                                    },
                                  );
                                  if (updated == true) {
                                    _getUserProfileDetails();
                                    if (widget.onProfileUpdated != null) {
                                      widget.onProfileUpdated!();
                                    }
                                  }
                                }),

                            buildMenuItem(
                                icon: Icons.campaign, title: "Refer & Earn", onTap: () {
                                   Navigator.pushNamed(
                                    context,
                                    arguments: {
                                       'user_id' : widget.userData?['user_id']??""
                                    },
                                   Config.referandearnRouteName); 
                                }),

                            buildMenuItem(
                                icon: Icons.location_on, title: "Manage Address", onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyAddressScreen(
                                        userData: widget.userData,
                                        initialAddress: getcustomerDetails?.address,
                                        initialLocation: getcustomerDetails?.location,
                                        initialLandmark: getcustomerDetails?.landmark,
                                      ),
                                    ),
                                  );
                                  _getUserProfileDetails();
                                }),

                            buildMenuItem(
                                icon: Icons.description,
                                title: "Terms & Conditions",
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                     Config.terms);
                                }),

                            buildMenuItem(
                                icon: Icons.assignment_turned_in,
                                title: "Inspection Report",
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                     Config.inspectionReport);
                                }),

                            buildMenuItem(
                                icon: Icons.feedback, title: "Send Feedback", onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    arguments:  {
                                         'user_id' : widget.userData?['user_id'],
                                         'user_name'  : getcustomerDetails?.name??""
                                    },
                                     Config.sendfeedbackScreenRouteName);
                                }),

                            buildMenuItem(
                              icon: Icons.logout,
                              title: "Logout",
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Logout"),
                                    content: const Text("Are you sure you want to logout?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () async {
                                          Navigator.pop(ctx);
                                          await SessionManager.clearSession();
                                          if (mounted) {
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              Config.loginRouteName,
                                              (route) => false,
                                            );
                                          }
                                        },
                                        child: const Text("Logout"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )


            ],
          ),
        ),

      // Bottom Navigation Bar

    ),
    ),
    );
  }
  Widget buildDivider() {
    return const Divider(
      color: Colors.black26, // light gray line
      thickness: 1,
      height: 20, // space around divider
    );
  }

  // Reusable Menu Item Widget
  Widget buildMenuItem(
      {required IconData icon,
        required String title,
        required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.green),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios,
              size: 16, color: Colors.black54),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }

  // Reusable Bottom Navigation Item

}