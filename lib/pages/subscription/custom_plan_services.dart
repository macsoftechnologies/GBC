import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/models/custom_plan_maincategories.dart' hide SubCategory;
import 'package:gobuddy_customer_app/models/custom_plan_subcategory.model.dart';
import 'package:gobuddy_customer_app/models/getservices_for_custom.model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';

import 'custom_package_jobs.dart';

class CustomPlanServices extends StatefulWidget {
  const CustomPlanServices({Key? key}) : super(key: key);

  @override
  State<CustomPlanServices> createState() => _CustomPlanServicesState();
}

class _CustomPlanServicesState extends State<CustomPlanServices> {
  int selectedMainServiceIndex = 0;
  Map<String, bool> expandedSubServices = {};
  Map<String, bool> selectedJobs = {};
  int totalSelectedJobs = 0;
GetCustomPlanMainCategories? pushintoMainCustomPlanMainCategories;
List<Category>? getMainCategories = [];
GetSubcategoriesModelForCustomPlan ? pushintoSubcategoriesCustomPlan;
List<SubCategory> getSubcategories = [];
GetServicesForCustomPlanModel?pushintoServicesCustomModel;
List<Service> getCustomservices = [];
Map<String, List<Service>> subCategoryServices = {};
Set<String> loadingSubCategories = {}; 



Future<void> _getCustomPlanMainCategories() async {
  bool internet = await UtilClass.checkInternet();
  if (!internet) {
    UtilClass.showAlertDialog(context: context, message: "No Internet Connection!");
    return;
  }

  try {
    final response = await Repository.getApiService(EndPoints.getAllMainCategoriesforCustomPlan);

    Map<String, dynamic> jsonResponse = {};

    if (response is String) {
      jsonResponse = json.decode(response);
    } else if (response is Map<String, dynamic>) {
      jsonResponse = response;
    }

    if (jsonResponse["status"] == "valid") {
      setState(() {
        pushintoMainCustomPlanMainCategories =
            GetCustomPlanMainCategories.fromJson(jsonResponse);

        // Extract only main categories
        getMainCategories = pushintoMainCustomPlanMainCategories?.categories ?? [];
        
        // Fetch subcategories for the first main category automatically
        if (getMainCategories!.isNotEmpty) {
          final firstCategoryId = getMainCategories![0].id;
          if (firstCategoryId != null && firstCategoryId.isNotEmpty) {
            _getSubCategoriesForCustomPlan(firstCategoryId);
          }
        }
      });
    } else {
      UtilClass.showAlertDialog(
        context: context,
        message: jsonResponse["message"] ?? "Something went wrong!",
      );
    }
  } catch (e) {
    print("Error fetching main categories: $e");
    UtilClass.showAlertDialog(
      context: context,
      message: "An error occurred while fetching categories.",
    );
  }
}

Future<void> _getSubCategoriesForCustomPlan(String categoryId) async {
  // Check Internet connection
  bool internet = await UtilClass.checkInternet();
  if (!internet) {
    UtilClass.showAlertDialog(
        context: context, message: "No Internet Connection");
    return;
  }

  try {
    // Call API
    final response = await Repository.NewPostApiService(
      EndPoints.getSubCategoriesByMainCategoryId,
      {'category_id': categoryId},
    );

    Map<String, dynamic> jsonResponse;
    if (response is String) {
      jsonResponse = json.decode(response as String);
    } else if (response is Map<String, dynamic>) {
      jsonResponse = response;
    } 

    if (jsonResponse["status"] == "valid") {
      print(jsonResponse);
      setState(() {
        pushintoSubcategoriesCustomPlan =
            GetSubcategoriesModelForCustomPlan.fromJson(jsonResponse);
        getSubcategories =
            pushintoSubcategoriesCustomPlan?.subCategory ?? [];
      });
    } else {
      print('Error fetching subcategories: ${jsonResponse["message"] ?? "Unknown error"}');
      setState(() {
        getSubcategories = []; 
      });
    }
  } catch (e) {
    print('Exception fetching subcategories: $e');
    setState(() {
      getSubcategories = [];
    });
  }
}

List<Map<String, dynamic>> _getSelectedServicesForRequest() {
  final List<Map<String, dynamic>> selected = [];

  subCategoryServices.forEach((subId, services) {
    for (final service in services) {
      if (selectedJobs[service.id] == true) {
        selected.add({
          "service_id":service.id??"",
          "service_name" : service.title??"",
          "price": service.servicePrice??"",
          "quantity" : 1
        });
      }
    }
  });

  return selected;
}


// Future<void> _AddSubscriptionServices(List<Map<String, dynamic>> selectedServices) async {
//   bool internet = await UtilClass.checkInternet();
//   if (!internet) {
//     UtilClass.showAlertDialog(context: context, message: "No Internet Connection");
//     return;
//   }
//   try {
//     final requestBody = {
//       'user_id': 4434, // Replace with logged-in user's ID
//       'plan_id': 4, // Replace with dynamic plan ID if available
//       'services': selectedServices,
//     };

//     print("📤 Sending request body: ${jsonEncode(requestBody)}");
//   } catch (e) {
//     print("❌ Error adding subscription services: $e");
//     UtilClass.showAlertDialog(
//       context: context,
//       message: "Something went wrong: $e",
//     );
//   }
// }




  // JSON Data Structure

  @override
  void initState() {
    super.initState();
    _getCustomPlanMainCategories();

    _calculateTotalSelectedJobs(); // Calculate initial count (should be 0)
  }

void toggleSubService(String subServiceId) async {
  final isExpanded = expandedSubServices[subServiceId] ?? false;

  setState(() {
    expandedSubServices[subServiceId] = !isExpanded;
  });

  if (!isExpanded) {
    // Only fetch if expanding
    await _getServicesBySubCategoryId(subServiceId);
  }
}

Future<void> _getServicesBySubCategoryId(String subServiceId) async {
  bool internet = await UtilClass.checkInternet();
  if (!internet) {
    UtilClass.showAlertDialog(context: context, message: "No Internet Connection");
    return;
  }

  setState(() {
    loadingSubCategories.add(subServiceId);
  });

  try {
    final response = await Repository.NewPostApiService(
      EndPoints.getServicesBySubCategoryIdforCustomSubscription,
      {
        'sub_category_id': subServiceId,
          'plan_id' : 4
         
         },
    );

    late Map<String, dynamic> jsonResponse;
    if (response is String) {
      jsonResponse = json.decode(response as String);
    } else if (response is Map<String, dynamic>) {
      jsonResponse = response;
    }

    if (jsonResponse["status"] == "valid") {
      pushintoServicesCustomModel = GetServicesForCustomPlanModel.fromJson(jsonResponse);
      final fetchedServices = pushintoServicesCustomModel?.services ?? [];

      setState(() {
        subCategoryServices[subServiceId] = fetchedServices;
      });
    } else {
     
      UtilClass.showAlertDialog(context: context, message:  "No Services Avaliable");
    }
  } catch (e) {
    UtilClass.showAlertDialog(context: context, message: "No Services found");
  } finally {
    setState(() {
      loadingSubCategories.remove(subServiceId);
    });
  }
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


  void _calculateTotalSelectedJobs() {
    int count = selectedJobs.values.where((isSelected) => isSelected).length;
    if (totalSelectedJobs != count) {
      setState(() {
        totalSelectedJobs = count;
      });
    }
  }

  void toggleJob(String jobId) {
    setState(() {
      // Toggle the selection state
      selectedJobs[jobId] = !(selectedJobs[jobId] ?? false);
      // Recalculate the total count
      _calculateTotalSelectedJobs();
    });
  }

  // New method to get the count of selected jobs for a specific main service
  // int _getMainServiceSelectedJobCount(int mainServiceIndex) {
  //   int count = 0;
  //   final mainService = servicesData[mainServiceIndex];

  //   for (var subService in mainService['subServices']) {
  //     for (var job in subService['jobs']) {
  //       if (selectedJobs[job['id']] == true) {
  //         count++;
  //       }
  //     }
  //   }
  //   return count;
  // }

  // Method to get all selected jobs with their details
  // List<Map<String, dynamic>> _getSelectedJobsWithDetails() {
  //   List<Map<String, dynamic>> selectedJobsList = [];

  //   for (var mainService in servicesData) {
  //     for (var subService in mainService['subServices']) {
  //       for (var job in subService['jobs']) {
  //         if (selectedJobs[job['id']] == true) {
  //           selectedJobsList.add({
  //             'id': job['id'],
  //             'name': job['name'],
  //             'mainService': mainService['name'],
  //             'subService': subService['name'],
  //           });
  //         }
  //       }
  //     }
  //   }
  //   return selectedJobsList;
  // }

  // Method to handle continue button press
  // void _handleContinue() {
  //   // Get all selected jobs with details
  //   final selectedJobsList = _getSelectedJobsWithDetails();

  //   // Print selected jobs and IDs to console
  //   // print('=== SELECTED JOBS ===');
  //   // print('Total Selected: $totalSelectedJobs');
  //   // for (var job in selectedJobsList) {
  //   //   print('ID: ${job['id']}, Name: ${job['name']}, Main Service: ${job['mainService']}, Sub Service: ${job['subService']}');
  //   // }
  //   // print('=====================');

  //   // Navigate to next screen with selected jobs data
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => CustomPackageJobsScreen(
  //         selectedJobs: selectedJobsList,

  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A152),
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(width * 0.02),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              iconSize: width * 0.05,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'Custom Plan',
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.055,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: 
      
    Column(
  children: [
    // Header text
    Container(
      color: Colors.white,
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.025,
      ),
      child: Text(
        'Select your service and create your package',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: width * 0.045,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),

    // Main content row
    Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Main Services
          Container(
            width: width * 0.43,
            color: const Color(0xFFE0F2E3),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: getMainCategories?.length ?? 0,
              itemBuilder: (context, index) {
                final category = getMainCategories![index];
                return _buildMainServiceItem(category, index, width, height);
              },
            ),
          ),

          // Right: Sub Services
          Expanded(
            child: Container(
              color: Color(0xFFebf2e6),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: getSubcategories.length,
                itemBuilder: (context, index) {
                  final subService = getSubcategories[index];
                  return _buildSubServiceItem(subService, width, height);
                },
              ),
            ),
          ),
        ],
      ),
    ),

    // Bottom panel
    if (totalSelectedJobs > 0) _buildBottomPanel(width, height),
  ],
)

    );
  }


Widget _buildMainServiceItem(
    Category getMainCategories, int index, double width, double height) {
  
  final isSelected = selectedMainServiceIndex == index;

  return GestureDetector(
    onTap: () {
      print(getMainCategories.id);
      setState(() {
        // Update the selected index to highlight the tapped card
        selectedMainServiceIndex = index;

        if (getMainCategories.id == null || getMainCategories.id!.isEmpty) {
          print("Sub category Id is Empty");
        } else {
          _getSubCategoriesForCustomPlan(getMainCategories.id ?? "");
        }
      });
    },
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.025,
      ),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              getMainCategories.category ?? "",
              textAlign: TextAlign.left,
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black87,
                fontSize: width * 0.040,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
          SizedBox(width: width * 0.01),
          // Uncomment if you want to show job count
          // if (jobCount > 0)
          //   Text(
          //     jobCount.toString(),
          //     style: TextStyle(
          //       color: const Color(0xFF00A152),
          //       fontSize: width * 0.042,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
        ],
      ),
    ),
  );
}

Widget _buildSubServiceItem(
  SubCategory getSubcategories,
  double width,
  double height,
) {
  final isExpanded = expandedSubServices[getSubcategories.id] ?? false;
  final isLoading = loadingSubCategories.contains(getSubcategories.id);
  final services = subCategoryServices[getSubcategories.id] ?? [];

  return Column(
    children: [
      GestureDetector(
        onTap: () {
          if (getSubcategories.id == null) {
            print("No SubCategoriesFound");
          } else {
            toggleSubService(getSubcategories.id!);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: height * 0.025,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFebf2e6),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  getSubcategories.subCategory ?? "",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: width * 0.037,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.grey[700],
                size: width * 0.06,
              ),
            ],
          ),
        ),
      ),

      // Expanded content
      if (isExpanded)
        Container(
          color: Colors.white,
          child: isLoading
              ? Padding(
                  padding: EdgeInsets.all(height * 0.02),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFF00A152),
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Column(
                  children: services.isNotEmpty
                      ? services
                          .map((service) => _buildServiceItem(service, width, height))
                          .toList()
                      : [
                          Padding(
                            padding: EdgeInsets.all(height * 0.02),
                            child: Text(
                              "No services available",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: width * 0.035,
                              ),
                            ),
                          ),
                        ],
                ),
        ),
    ],
  );
}

Widget _buildServiceItem(Service service, double width, double height) {
  final isSelected = selectedJobs[service.id] ?? false;

  return GestureDetector(
    onTap: () => toggleJob(service.id ?? ""),
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.018,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: width * 0.055,
            height: width * 0.055,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? const Color(0xFF00A152) : Colors.grey.shade400,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
              color: isSelected ? const Color(0xFF00A152) : Colors.white,
            ),
            child: isSelected
                ? Icon(Icons.check, size: width * 0.04, color: Colors.white)
                : null,
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Text(
              service.title ?? "Unnamed Service",
              style: TextStyle(
                color: Colors.black87,
                fontSize: width * 0.038,
              ),
            ),
          ),
        
        ],
      ),
    ),
  );
}


  Widget _buildJobItem(
      Map<String, dynamic> job,
      double width,
      double height,
      ) {
    final isSelected = selectedJobs[job['id']] ?? false;

    return GestureDetector(
      onTap: () => toggleJob(job['id']),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.018, // color: Color(0xFFebf2e6),
        ),
        decoration: BoxDecoration(
          color:Color(0xFFebf2e6),
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: width * 0.055,
              height: width * 0.055,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00A152)
                      : Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
                color: isSelected ? const Color(0xFF00A152) : Colors.white,
              ),
              child: isSelected
                  ? Icon(
                Icons.check,
                size: width * 0.04,
                color: Colors.white,
              )
                  : null,
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Text(
                job['name'],
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: width * 0.038,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method for the persistent bottom sheet/panel
  Widget _buildBottomPanel(double width, double height) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: height * 0.06,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      // Main container is a Row to place the count/text block next to the button
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically in the center
        children: [
          // LEFT SIDE: Stacked Count and Text (achieved with a Column)
          Column(
            mainAxisSize: MainAxisSize.min, // Keep column size minimal
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
            children: [
              Text(
                // Display only the count
                totalSelectedJobs.toString(),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: width * 0.055, // Larger font for the count
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Display 'Selected services' text
              Text(
                'Selected services',
                style: TextStyle(
                  color: Colors.grey[700], // Grey color for the supporting text
                  fontSize: width * 0.038, // Smaller font for the supporting text
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // RIGHT SIDE: Continue Button
          SizedBox(
            width: width * 0.45,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
  final selectedServices = _getSelectedServicesForRequest();
  print(selectedServices);

  if (selectedServices.isEmpty) {
    UtilClass.showAlertDialog(
      context: context,
      message: "Please select at least one service",
    );
    return;
  }

  // 🧮 Calculate totals
  final planTotals = calculateServicesPrice(selectedServices);
  final totalPrice6Months = planTotals["6_months"] ?? 0.0;
  final totalPrice12Months = planTotals["12_months"] ?? 0.0;

  Navigator.pushNamed(
    context,
    Config.custompackagejobs, 
    arguments: {
      "services_data": selectedServices,
      "plan_data": {
        "6_months": totalPrice6Months.toStringAsFixed(2),
        "12_months": totalPrice12Months.toStringAsFixed(2),
       
      },
    },
  );
},
 // Use the new handler method
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A152),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Text(
                'Continue',
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Next Screen to display selected jobs
class SelectedJobsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> selectedJobs;
  final int totalSelectedJobs;

  const SelectedJobsScreen({
    Key? key,
    required this.selectedJobs,
    required this.totalSelectedJobs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A152),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Selected Services ($totalSelectedJobs)',
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.05,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            margin: EdgeInsets.all(width * 0.04),
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF00A152).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Services Selected:',
                  style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  totalSelectedJobs.toString(),
                  style: TextStyle(
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00A152),
                  ),
                ),
              ],
            ),
          ),

          // Selected Jobs List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),
              itemCount: selectedJobs.length,
              itemBuilder: (context, index) {
                final job = selectedJobs[index];
                return Card(
                  margin: EdgeInsets.only(bottom: height * 0.01),
                  elevation: 2,
                  child: ListTile(
                    leading: Container(
                      width: width * 0.1,
                      height: width * 0.1,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A152).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: const Color(0xFF00A152),
                        size: width * 0.06,
                      ),
                    ),
                    title: Text(
                      job['name'],
                      style: TextStyle(
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.005),
                        Text(
                          '${job['mainService']} • ${job['subService']}',
                          style: TextStyle(
                            fontSize: width * 0.035,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: height * 0.003),
                        Text(
                          'ID: ${job['id']}',
                          style: TextStyle(
                            fontSize: width * 0.03,
                            color: Colors.grey[500],
                            fontFamily: 'Monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Continue Button for next step
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.02,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Handle next step logic
                  print('Proceeding with ${selectedJobs.length} selected services');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A152),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Proceed to Next Step',
                  style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}