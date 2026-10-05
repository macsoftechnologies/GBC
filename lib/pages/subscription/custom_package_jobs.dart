import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/pages/subscription/subscription_summary.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';

class CustomPackageJobsScreen extends StatefulWidget {
 

  const CustomPackageJobsScreen({
    super.key
  }) ;

  @override
  State<CustomPackageJobsScreen> createState() =>
      _CustomPackageJobsScreenState();
}

class _CustomPackageJobsScreenState extends State<CustomPackageJobsScreen> {
 List<Map<String, dynamic>> servicesList = [];
  Map<String, dynamic> planData = {};
    String? _tempSelectedDuration;
  double? _tempSelectedPrice;
  String? userId;
  bool _isInit = true;

@override
void didChangeDependencies() {
  super.didChangeDependencies();

  if (_isInit) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      if (args.containsKey('user_id')) {
        userId = args['user_id']?.toString();
      }
      // Load services
      if (args.containsKey('services_data')) {
        servicesList = List<Map<String, dynamic>>.from(args['services_data']);
        print("🧾 Services Data Loaded — Count: ${servicesList.length}");
      }

      // Load plan data
      if (args.containsKey('plan_data')) {
        planData = Map<String, dynamic>.from(args['plan_data']);
        print("💰 Plan Data Loaded: $planData");
      }
      _tempSelectedDuration = null;
      _tempSelectedPrice = null;

      _isInit = false;
    }
  }
}


  @override
  void initState() {
    super.initState();
  
  }

void _updateQuantity(int index, int delta) {
  setState(() {
    int newQty = servicesList[index]['quantity'] + delta;

    // Prevent negative quantities
    if (newQty >= 0) {
      servicesList[index]['quantity'] = newQty;

      // Recalculate service totals and plan totals
      Map<String, double> totals = calculateServicesPrice(servicesList);

      // Optionally, update planData for the bottom sheet
      planData['6_months'] = totals['6_months'];
      planData['12_months'] = totals['12_months'];

      // If a duration is already selected, update _tempSelectedPrice
      if (_tempSelectedDuration != null) {
        _tempSelectedPrice = totals[_tempSelectedDuration!.contains("6") ? '6_months' : '12_months'];
      }
    }
  });
}


Map<String, double> calculateServicesPrice(List<Map<String, dynamic>> selectedServices) {
  double totalPrice6Months = 0.0;
  double totalPrice12Months = 0.0;

  for (var service in selectedServices) {
    double price = double.tryParse(service['price']?.toString() ?? "0") ?? 0.0;
    int quantity = int.tryParse(service['quantity']?.toString() ?? "1") ?? 1;

    double serviceTotal6 = price * quantity * 6;
    double serviceTotal12 = price * quantity * 12 * 0.9; // 10% discount

    service['total_6_months'] = serviceTotal6.toStringAsFixed(2);
    service['total_12_months'] = serviceTotal12.toStringAsFixed(2);

    totalPrice6Months += serviceTotal6;
    totalPrice12Months += serviceTotal12;
  }

  print("🧾 6 Months Total Price: ₹${totalPrice6Months.toStringAsFixed(2)}");
  print("🧾 12 Months Total Price: ₹${totalPrice12Months.toStringAsFixed(2)}");
  print("📋 Updated Services: $selectedServices");

  // ✅ Return both totals
  return {
    "6_months": totalPrice6Months,
    "12_months": totalPrice12Months,
  };
}




Future<Map<String, dynamic>?> _showValidityBottomSheet(
    Map<String, dynamic> planData,
    {String? initialDuration, double? initialPrice}) async {
  String? selectedDuration = initialDuration;
  double? selectedPrice = initialPrice;
  bool isProceedEnabled = initialDuration != null;

  return await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateModal) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Validity Type",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 25),

                // 6 months option
                InkWell(
                  onTap: () {
                    setStateModal(() {
                      selectedDuration = "6 months";
                      selectedPrice =
                          double.tryParse(planData['6_months'].toString()) ??
                              0;
                      isProceedEnabled = true;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "6 months / ₹ ${planData['6_months']}",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                      Icon(
                        selectedDuration == "6 months"
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const Divider(thickness: 1.2, height: 30),

                // 12 months option
                InkWell(
                  onTap: () {
                    setStateModal(() {
                      selectedDuration = "12 months";
                      selectedPrice =
                          double.tryParse(planData['12_months'].toString()) ??
                              0;
                      isProceedEnabled = true;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "12 months / ₹ ${planData['12_months']}",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                      Icon(
                        selectedDuration == "12 months"
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Proceed button
                GestureDetector(
                  onTap: isProceedEnabled
                      ? () {
                          Navigator.pop(context, {
                            "duration": selectedDuration,
                            "price": selectedPrice,
                          });
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: isProceedEnabled ? Colors.green : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(15)),
                    child: Text(
                      "Proceed",
                      style: TextStyle(
                        color: isProceedEnabled ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: width * 0.03, top: height * 0.005),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.green),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Custom Plan Package',
          style: TextStyle(
            color: Colors.black,
            fontSize: width * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: Column(
          children: [
            Container(
              height: height * 0.80,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  SizedBox(height: height * 0.02),
                  Text(
                    'Custom',
                    style: TextStyle(
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: height * 0.005),
          Text(
  _tempSelectedPrice != null && _tempSelectedDuration != null
      ? '₹ ${_tempSelectedPrice!.toInt()} /-'
      : 'Total Price',
  style: TextStyle(
    fontSize: width * 0.09,
    fontWeight: FontWeight.w800,
    color: Colors.black87,
  ),
),




                  SizedBox(height: height * 0.005),

                  // Dynamic dropdown replaced with custom bottom sheet
               GestureDetector(
onTap: () async {
final result = await _showValidityBottomSheet(planData);
if (result != null) {
  setState(() {
    _tempSelectedDuration = result["duration"];
    _tempSelectedPrice = result["price"];
  });
}


},

  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        _tempSelectedDuration ?? "Select Duration",
        style: TextStyle(
          fontSize: width * 0.045,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      const SizedBox(width: 4),
      const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
    ],
  ),
),


                  SizedBox(height: height * 0.015),
                  _buildTag('Custom', width, height),

                  // Services section
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.05,
                        vertical: height * 0.02,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...List.generate(
  servicesList.length,
  (index) => Padding(
    padding: EdgeInsets.only(bottom: height * 0.015),
    child: Row(
      children: [
        Icon(Icons.verified_rounded, color: Colors.green, size: width * 0.05),
        SizedBox(width: width * 0.03),
        Expanded(
          child: Text(
            servicesList[index]['service_name'],
            style: TextStyle(
              fontSize: width * 0.04,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildQuantitySelector(index, width),
      ],
    ),
  ),
),

                                  SizedBox(height: height * 0.01),
                                  Row(
                                    children: [
                                      TextButton(onPressed: (){
                                       Navigator.pop(context);
                                      }, child: Text('Add service ', style: TextStyle(
                                            fontSize: width * 0.04,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                      ),)),
                                      SizedBox(width: width * 0.015),
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.add,
                                            color: Colors.green,
                                            size: width * 0.065),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.025),
                          SizedBox(
                            width: double.infinity,
                            height: height * 0.07,
                            child:
                             ElevatedButton(
                              onPressed: () {
          if (_tempSelectedDuration == null) {
      UtilClass.showAlertDialog(context: context, message: "Please select the Duration !");
    return; 
  }
                               

    // 1️⃣ Recalculate totals to make sure planData is up-to-date
     Map<String, double> totals = calculateServicesPrice(servicesList);

     

     Map<String, dynamic> selectedPlanData = {};
    if (_tempSelectedDuration != null) {
      if (_tempSelectedDuration!.contains("6")) {
        selectedPlanData['6_months'] = totals['6_months']!.toInt();
      } else if (_tempSelectedDuration!.contains("12")) {
        selectedPlanData['12_months'] = totals['12_months']!.toInt();
      }
      selectedPlanData['plan_id'] = 15; // 15 is Custom Plan ID in the backend
      selectedPlanData['house_type'] = '3 BHK';
      selectedPlanData['duration'] = _tempSelectedDuration!.replaceFirst('months', 'Months');
    }

     Map<String, dynamic> completePlan = {
      "services_data": servicesList,
      "plan_name" : "Custom-plan",
      "plan_data": selectedPlanData,
      "selected_duration": _tempSelectedDuration,
      "selected_price": _tempSelectedPrice?.toInt(),
    };


     Navigator.pushNamed(
      context,
      arguments: {
        'completed_packed_plan' : completePlan,
        'user_id': userId ?? '',
      },
       Config.subscriptionSummary);
      
            
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B2332),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'Get Plan',
                                style: TextStyle(
                                  fontSize: width * 0.045,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, double width, double height) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.08,
        vertical: height * 0.007,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: width * 0.04,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

Widget _buildQuantitySelector(int index, double width) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: width * 0.015),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.green),
      borderRadius: BorderRadius.circular(25),
    ),
    child: Row(
      children: [
        _buildQuantityButton('-', () => _updateQuantity(index, -1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.02),
          child: Text(
            '${servicesList[index]['quantity']}',
            style: TextStyle(
              color: Colors.green,
              fontSize: width * 0.04,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildQuantityButton('+', () => _updateQuantity(index, 1)),
      ],
    ),
  );
}

  Widget _buildQuantityButton(String symbol, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
        child: Text(
          symbol,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}