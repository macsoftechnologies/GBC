import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/models/inspection_report_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';

class Inspectionreport extends StatefulWidget {
  const Inspectionreport({super.key});

  @override
  State<Inspectionreport> createState() => _InspectionReportScreenState();
}

class _InspectionReportScreenState extends State<Inspectionreport> {
  GetInspectionReport? getInspectionReport;
  String? inspectionRelay;

  @override
  void initState() {
    super.initState();
    _getInspectionReport();
  }

  Future<void> _getInspectionReport() async {
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
          await Repository.getApiService(EndPoints.getinspectionreport);

      late Map<String, dynamic> jsonResponse;

      if (response is String) {
        jsonResponse = json.decode(response);
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      } else {
        throw Exception("Invalid API response format");
      }

      if (jsonResponse["status"] == "valid") {
        setState(() {
          getInspectionReport = GetInspectionReport.fromJson(jsonResponse);
          inspectionRelay = getInspectionReport?.inspectionReport ?? "";
        });
      } else {
        setState(() {
          inspectionRelay = jsonResponse["message"] ?? "Something went wrong";
        });
      }
    } catch (e) {
      print("InspectionReport Error: $e");
      setState(() {
        inspectionRelay = "Failed to load inspection report.";
      });
    }
  }

  /// Converts plain text into bullet-point lines
  List<String> _formatToPoints(String text) {
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
    final List<String> points = _formatToPoints(inspectionRelay ?? "");

    return Scaffold(
      backgroundColor: MyColors.appThemeLight,
      appBar: AppBar(
        backgroundColor: MyColors.appThemeLight,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Inspection Report",
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: inspectionRelay == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.black),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Card(
                elevation: 6,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Header
                      const Text(
                        "Vehicle Inspection Summary",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        height: 3,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Bullet points content
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
                                  height: 1.3,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  p,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.35,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (points.isEmpty)
                        const Center(
                          child: Text(
                            "No inspection report found.",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
