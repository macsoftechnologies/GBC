import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/models/bookings_overview_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';

import 'package:intl/intl.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';

import '../../utils/config.dart';
import 'package:gobuddy_customer_app/data/prefernces.dart';

class EditScheduleVisitDateForServiceScreen extends StatefulWidget {
  const EditScheduleVisitDateForServiceScreen({super.key});

  @override
  State<EditScheduleVisitDateForServiceScreen> createState() =>
      _ScheduleVisitDateScreenState();
}

class _ScheduleVisitDateScreenState
    extends State<EditScheduleVisitDateForServiceScreen> {
  dynamic selectedServicesList;
  dynamic servicesPassed;
  String? userId;
  String? jobcalendarId;
  String? orderId;
  Order? getorder;
 bool isLoading = false;

  GetBookingOverview? pushintoOverview;
  Provider? providerId;
  String? providerIdStr;

  DateTime selectedDate = DateTime.now();
  String selectedTime = "";
 List<String> timeSlots = [
  "09:00:00",
  "09:30:00",
  "10:00:00",
  "10:30:00",
  "11:00:00",
  "11:30:00",
  "12:00:00",
  "12:30:00",
  "13:00:00",
  "13:30:00",
  "14:00:00",
  "14:30:00",
  "15:00:00",
  "15:30:00",
  "16:00:00",
  "16:30:00",
  "17:00:00",
  "17:30:00",
  "18:00:00",
  "18:30:00",
  "19:00:00",
  "19:30:00",
];


  List<DateTime> next7Days = [];

  @override
  void initState() {
    super.initState();
    _generateNext7Days();
  }

  void _generateNext7Days() {
    DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      next7Days.add(now.add(Duration(days: i)));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      userId = args['user_id']?.toString();
      jobcalendarId = args['job_calender_id']?.toString();
      orderId = args['order_id']?.toString();
      if (args.containsKey('provider_id') && args['provider_id'] != null) {
        providerIdStr = args['provider_id'].toString();
      }
    }
  }


Future<void> _editSchedule() async {
  // Ensure a time slot is selected
  if (selectedTime.isEmpty) {
    UtilClass.showAlertDialog(
        context: context, message: "Please select a time slot");
    return;
  }

  // Check internet connection
  bool internet = await UtilClass.checkInternet();
  if (!internet) {
    UtilClass.showAlertDialog(
        context: context, message: "No Internet Connection");
    return;
  }

  try {
    // Show loading indicator
    setState(() {
      isLoading = true;
    });

    final String y = selectedDate.year.toString();
    final String m = selectedDate.month.toString().padLeft(2, '0');
    final String d = selectedDate.day.toString().padLeft(2, '0');
    String formattedDate = "$y-$m-$d";

    final uid = userId ?? await Preferences.getUserID() ?? "";

    Map<String, dynamic> requestBody = {
      'user_id': uid,
      'job_calender_id': jobcalendarId ?? "",
      'schedule_date': formattedDate,
      'schedule_time': selectedTime.toString(),
      'provider_id': providerIdStr ?? "",
    };

    print("Request Body: $requestBody");

    // Call API
    final response = await Repository.FlexiblePostApi(
        EndPoints.editscheduleforbookings, requestBody);

    print("Decoded Response: $response");

    if (response["status"] == "valid" || response["status"] == true) {
      UtilClass.showAlertDialog(
        context: context,
        message: "Date & Time Updated Successfully",
        onOkClick: () {
          Navigator.pop(context, true);
        },
      );
    } else {
      UtilClass.showAlertDialog(
          context: context, message: response["message"] ?? "Error");
    }
  } catch (e) {
    print("Error updating schedule: $e");
    UtilClass.showAlertDialog(
        context: context, message: "Something went wrong, try again");
  } finally {
    // Hide loading indicator
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFf6fbf9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header with back button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3)),
                          ]),
                      child: Center(
                        child: Image.asset(
                          "assets/images/whiteLeftArrow.png",
                          width: 9,
                          color: Color(0xFF19a64b),
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Schedule Your Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "When should the professional arrive?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 4),
              const Text(
                "Select time and date for Property visit",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 15),
              const Text(
                "Select Date",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),

              // Horizontal Date Picker
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: next7Days.length,
                  itemBuilder: (context, index) {
                    DateTime date = next7Days[index];
                    bool isSelected = date.day == selectedDate.day &&
                        date.month == selectedDate.month &&
                        date.year == selectedDate.year;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? MyColors.lightGreen2
                              : MyColors.topCardColor,
                          border: isSelected
                              ? Border.all(
                                  color: Colors.green,
                                  width: 1.5,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat.E().format(date),
                              style: TextStyle(
                                color: const Color(0xFFa9b1b0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.green : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              if (selectedDate.weekday == DateTime.sunday)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFEEBA)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF856404), size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Sunday bookings may incur additional service / peak charges.",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF856404),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Text(
                "Select Time ${providerId?.name ?? ''}",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),

              // Time Slots Grid
              Expanded(
                child: GridView.builder(
                  itemCount: timeSlots.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: 45,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    String time = timeSlots[index];
                    bool isSelected = selectedTime == time;

                    final now = DateTime.now();
                    DateTime slotTime;
                    try {
                      if (time.contains("AM") || time.contains("PM")) {
                        slotTime = DateFormat("hh:mm a").parse(time.trim());
                      } else {
                        slotTime = DateFormat("HH:mm:ss").parse(time.trim());
                      }
                    } catch (_) {
                      try {
                        slotTime = DateFormat("HH:mm").parse(time.trim());
                      } catch (_) {
                        slotTime = DateTime.now();
                      }
                    }
                    slotTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      slotTime.hour,
                      slotTime.minute,
                    );
                    bool isSlotUnavailable = selectedDate.year == now.year &&
                        selectedDate.month == now.month &&
                        selectedDate.day == now.day &&
                        slotTime.isBefore(now.add(const Duration(hours: 2)));

                    return GestureDetector(
                      onTap: isSlotUnavailable
                          ? null
                          : () {
                              setState(() {
                                selectedTime = time;
                              });
                            },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSlotUnavailable
                              ? Colors.grey[300]
                              : isSelected
                                  ? MyColors.lightGreen2
                                  : MyColors.topCardColor,
                          border: isSelected
                              ? Border.all(
                                  color: Colors.green,
                                  width: 1.5,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                            color: isSlotUnavailable
                                ? Colors.grey
                                : isSelected
                                    ? Colors.green
                                    : Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Proceed Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedTime.isNotEmpty
                        ? Colors.green
                        : Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: (selectedTime.isNotEmpty )
                      ? () {
                          _editSchedule();
                        }
                      : null,
                  child: const Text(
                    "Proceed",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
