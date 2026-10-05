import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:gobuddy_customer_app/models/getreferalmodel.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';

class Referandearn extends StatefulWidget {
  const Referandearn({super.key});

  @override
  State<Referandearn> createState() => _ReferandEarnScreenState();
}

class _ReferandEarnScreenState extends State<Referandearn> {
  String? referCode;
  String? userId;

  GetReferalCodeModel? pushintoreferalModel;
  Profile? myprofile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      userId = args['user_id']?.toString();
      _getReferalCode();
    }
  }

  Future<void> _getReferalCode() async {
    bool internet = await UtilClass.checkInternet();

    if (!internet) {
      UtilClass.showAlertDialog(
          context: context, message: "No Internet Connection");
      return;
    }

    try {
      final response = await Repository.postApiService(
        EndPoints.getUserProfileDetailsRefer,
        {'user_id': userId ?? ""},
      );

      Map<String, dynamic> jsonResponse;

      if (response is String) {
        jsonResponse = json.decode(response);
      } else {
        jsonResponse = Map<String, dynamic>.from(response);
      }

      if (jsonResponse['status'] == 'valid') {
        setState(() {
          pushintoreferalModel =
              GetReferalCodeModel.fromJson(jsonResponse);

          myprofile = pushintoreferalModel?.profile;
          referCode = myprofile?.referralId ?? "";
        });
      }
    } catch (e) {
      UtilClass.showAlertDialog(
          context: context, message: "Something went wrong");
    }
  }


  void _shareReferral() {
    if (referCode != null && referCode!.isNotEmpty) {
      Share.share(
        "🎉 Join me on GoBuddy!\n\nUse my referral code: $referCode\n\nGet exciting rewards 💰\nDownload now: https://yourapp.link",
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Referral code not available")),
      );
    }
  }

  /// ✅ COPY FUNCTION
  void _copyCode() {
    if (referCode != null && referCode!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: referCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Copied to clipboard")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEDEDED),
      appBar: AppBar(
        backgroundColor: const Color(0xff1FA739),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Refer & Earn",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(.2),
            child: IconButton(
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xffF2F2F2),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),

            const SizedBox(height: 30),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Refer a friend or family member and get a cash reward",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Share the link with your friend and after they register, both of you will get cash reward or GB coins",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// ✅ REFER CODE BOX
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xffE4ECE7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      referCode ?? "Loading...",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: _copyCode,
                      child: const Text(
                        "Copy",
                        style: TextStyle(
                          color: Color(0xff1FA739),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// ✅ SHARE BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1FA739),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text(
                    "Refer Now",
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: _shareReferral,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}