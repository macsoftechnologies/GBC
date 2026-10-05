import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';

import '../../utils/config.dart';



class ScheduleVisitDateScreen extends StatefulWidget {
  final String serviceType;
  final String serviceTitle;

  final List<Map<String, dynamic>> services;

  const ScheduleVisitDateScreen({
    super.key,
    required this.serviceType,
    required this.serviceTitle,
    required this.services,
    
  });

  @override
  State<ScheduleVisitDateScreen> createState() => _ScheduleVisitDateScreenState();
}

class _ScheduleVisitDateScreenState extends State<ScheduleVisitDateScreen> {
  DateTime selectedDate = DateTime.now();
  String selectedTime = "";
  List<String> timeSlots = [
    "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM",
    "11:00 AM", "11:30 AM", "12:00 PM", "12:30 PM",
    "01:00 PM", "01:30 PM", "02:00 PM", "02:30 PM",
    "03:00 PM", "03:30 PM", "04:00 PM", "04:30 PM",
    "05:00 PM", "05:30 PM", "06:00 PM", "06:30 PM",
    "07:00 PM", "07:30 PM",
  ];



  List<DateTime> next7Days = [];

  @override
  void initState() {
    super.initState();
    print("yyyyyyyyyyyyyy");
    print(widget.services);
    _generateNext7Days();
  }

  void _generateNext7Days() {
    DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      next7Days.add(now.add(Duration(days: i)));
    }
  }

  void _proceed() {
    if (selectedTime.isEmpty) return;
    //sk
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => SchedulePropertyVisitScreen(
    //       date: DateFormat('yyyy-MM-dd').format(selectedDate),
    //       time: selectedTime,
    //     ),
    //   ),
    // );
    Navigator.pushNamed(
      // ignore: use_build_context_synchronously
      context,
      Config.selectProviderScreen,
      arguments: {
        "serviceType": widget.serviceType,
        "serviceTitle": widget.serviceTitle,
        "services": widget.services,
        'date': selectedDate.toString(),
        'time': selectedTime,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    //

    return Scaffold(
      backgroundColor: Color(0xFFf6fbf9), // Color(0xFFe5eeea),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close Button with white round background & elevation
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Container(
                  //   decoration: const BoxDecoration(
                  //     color: Colors.white,
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child: IconButton(
                  //     onPressed: () => Navigator.pop(context),
                  //     icon: const Icon(Icons.arrow_back, color: Colors.black),
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/images/whiteLeftArrow.png",
                          width: 9,
                          color:Color(0xFF19a64b) ,
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
                  const SizedBox(width: 48), // Balance the header
                ],
              ),
              const SizedBox(height: 8),

              const Text(
                "When should the professional arrive ?",
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
                height: 60, // reduced height
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
                        width: 60, // reduced width
                        margin: const EdgeInsets.only(right: 10),//(0xFFf6fbf9
                        decoration: BoxDecoration(
                          color: isSelected ? MyColors.lightGreen2 : MyColors.topCardColor,
                          border: isSelected
                              ? Border.all(
                            color: Colors.green,
                            width: 1.5,
                          )
                              : null, // No border if not selected
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat.E().format(date),
                              style: TextStyle(
                                color: isSelected ? Color(0xFFa9b1b0) : Color(0xFFa9b1b0),
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

              const Text(
                "Select Time",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),

              // Time Slots Grid
              Expanded(
                child: GridView.builder(
                  itemCount: timeSlots.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: 45, // reduced height
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    String time = timeSlots[index];
                    bool isSelected = selectedTime == time;

                    final now = DateTime.now();
                    DateFormat format = DateFormat("hh:mm a");
                    DateTime slotTime = format.parse(time);
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
                  onPressed: selectedTime.isNotEmpty ? _proceed : null,
                  child: const Text(
                    "Proceed",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: Colors.white),
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
