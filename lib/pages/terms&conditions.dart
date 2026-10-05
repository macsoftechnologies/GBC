import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/models/terms_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';

class TermsConditions extends StatefulWidget {
  const TermsConditions({super.key});

  @override
  State<TermsConditions> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditions> {
  String? terms;
  GetTermsConditions? getTermsconditions;

  @override
  void initState() {
    super.initState();
    _getTermsAndConditions();
  }

  Future<void> _getTermsAndConditions() async {
    bool internet = await UtilClass.checkInternet();
    if (!internet) {
      UtilClass.showAlertDialog(
        context: context,
        message: "No Internet Connection",
      );
      return;
    }

    try {
      final response =
          await Repository.getApiService(EndPoints.getTermsandConditions);

      late Map<String, dynamic> jsonResponse;

      // Handle different response formats
      if (response is String) {
        jsonResponse = json.decode(response);
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      } else {
        throw Exception("Invalid API response format");
      }

      if (jsonResponse["status"] == "valid") {
        setState(() {
          getTermsconditions = GetTermsConditions.fromJson(jsonResponse);
          terms = getTermsconditions?.termsAndConditions ?? "";
        });
      } else {
        setState(() {
          terms = jsonResponse["message"] ?? "Something went wrong";
        });
      }
    } catch (e) {
      debugPrint("Terms Error: $e");
      setState(() {
        terms = "Failed to load Terms & Conditions.";
      });
    }
  }


  List<String> _formatTermsToPoints(String text) {
    if (text.isEmpty) return [];


    final regex = RegExp(r'(\n|-\s|\d+\.\s)');
    return text
        .split(regex)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.length > 2)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> points = _formatTermsToPoints(terms ?? "");

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: MyColors.appThemeLight,
        elevation: 0,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Please read these terms carefully:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (points.isNotEmpty)
                    ...points.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "•  ",
                              style: TextStyle(
                                fontSize: 20,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                p.trim(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (points.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "Loading...",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
