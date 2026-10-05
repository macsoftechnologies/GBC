import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/models/add_tocart_service_model.dart';
import 'package:gobuddy_customer_app/models/home_userDetails_model.dart';
import 'package:gobuddy_customer_app/models/serice_user_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import '../../utils/config.dart'; // Make sure this has image base URL
class AddServicesScreen extends StatefulWidget {
  const AddServicesScreen({super.key});

  @override
  State<AddServicesScreen> createState() => _AddServicesScreenState();
}

class _AddServicesScreenState extends State<AddServicesScreen> {
  List<Map<String, dynamic>> _services = [];
  GetServicesModel? pushServicesintoModel;
  String? subCategoryIdData;
  String? serviceTitle;
  String? serviceId;
ServicesBannerModel? pushserviceBannermodel;
ServicePanelData? endPanelData;
String?subcatIdStorage;
String?MainCategoryId;
String?userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
   

   if (subCategoryIdData == null) {
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  if (args != null && args.containsKey('subcat_id')) {
    subCategoryIdData = args['subcat_id'] ?? "";
    serviceTitle = args['sub_category_name'] ?? "";
   subcatIdStorage = args['subcat_id']??"";
   MainCategoryId = args['main_category_id']??"";
  userId = args['user_id']??"";
  print("User Id Came in Add to Cart $userId");
    _getServicesByCategoryId(); 
    getDetailsBannerForServices();
   
  }
}
 }




Future<void> getDetailsBannerForServices() async {
  bool internet = await UtilClass.checkInternet();
  if (!internet) {
    UtilClass.showAlertDialog(context: context, message: "No Internet Connection");
    return;
  }

  try {
    print("Sending Sub Category Id: $subCategoryIdData");

    final response = await Repository.NewPostApiService(
      EndPoints.getserviceBannerdetails,
      {
        "sub_category_id": subCategoryIdData??""
      },
    );

    Map<String, dynamic> jsonResponse;
    if (response is String) {
      jsonResponse = json.decode(response as String);
    } else if (response is Map<String, dynamic>) {
      jsonResponse = response;
    } 

    print("Decoded Response: $jsonResponse");

    if (jsonResponse["status"] == "valid") {
      pushserviceBannermodel = ServicesBannerModel.fromJson(jsonResponse);

      if (pushserviceBannermodel!.data != null) {
        setState(() {
          endPanelData = pushserviceBannermodel!.data!;
        });

        print("End Panel Data: $endPanelData");
      } else {
        UtilClass.showAlertDialog(context: context, message: "No Service Panel Details Available");
      }
    }
  } catch (e) {
    UtilClass.showAlertDialog(context: context, message: "$e");
  }
}




  Future<void> _getServicesByCategoryId() async {
    bool internet = await UtilClass.checkInternet();
    if (!internet) {
      UtilClass.showAlertDialog(context: context, message: "No Internet Connection!");
      return;
    }

    try {
      final response = await Repository.NewPostApiService(
        EndPoints.getServicesBySubCategoryId,
        {"sub_category_id": subCategoryIdData??""},
      );

      if (response['status'] == 'valid') {
        pushServicesintoModel = GetServicesModel.fromJson(response);

       final servicesList = pushServicesintoModel?.services;
if (servicesList != null && servicesList.isNotEmpty) {
  _services = servicesList.map((service) {
    return {
      "id": service.id,
      "title": service.title,
       "time" : service.time,
       "service_image": "https://dev.gobuddyindia.com/assets/images/${service.serviceImage}",
       "average_rating" : service.averageRating,
       "total_reviews" : service.totalReviews,
       "bookings" : service.bookings,
       "service_price" : service.price,
      "quantity": 0,
      "main_category_id" : MainCategoryId
    };
  }).toList();
}


        setState(() {});
      } 
    } catch (e) {
      print(e);
      UtilClass.showAlertDialog(
        context: context,
        message: "Something went wrong. Please try again.",
      );
    }
  }

  void updateServiceQuantity(String id, int newQuantity) {
    setState(() {
      for (var service in _services) {
        if (service['id'] == id) {
          service['quantity'] = newQuantity;
          break;
        }
      }
    });
  }

  void incrementQuantity(String id) {
    for (var service in _services) {
      if (service['id'] == id) {
        int currentQty = service['quantity'] ?? 0;
        updateServiceQuantity(id, currentQty + 1);
        break;
      }
    }
  }

  void decrementQuantity(String id) {
    for (var service in _services) {
      if (service['id'] == id) {
        int currentQty = service['quantity'] ?? 0;
        if (currentQty > 0) {
          updateServiceQuantity(id, currentQty - 1);
        }
        break;
      }
    }
  }

  List<Map<String, dynamic>> getSelectedServices() {
    return _services.where((service) => service['quantity'] > 0).toList();
  }

Widget _buildHeader(BuildContext context) {
    return Container(
      color: MyColors.appThemeLight,
      
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white24,
              child: Image.asset(
                "assets/images/whiteLeftArrow.png",
                width: 9,
              ),
            ),
          ),
          SizedBox(width: 10,),
          
           Text(
                serviceTitle??"",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    
                ),
              ),
         
        ],
      ),
    );
  }
 
 
  Widget _buildStatsRow(bool isSmallScreen) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: isSmallScreen ? 8 : 16),
      child:Column(
        children: [
         
                 Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      
        children: [
          Text("${_services.length} Services",
              style: TextStyle(color: Colors.black54, fontSize: isSmallScreen ? 12 : 14)),
              SizedBox(width: 20,),
          Row(
            children: [
              Icon(Icons.people, size: isSmallScreen ? 14 : 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                 endPanelData?.providers??"No",
                  style: TextStyle(color: Colors.black54, fontSize: isSmallScreen ? 12 : 14)),
            ],
          ),
          SizedBox(width: 30,),
          Flexible(
            child: Row(
              children: [
                Icon(Icons.star, size: isSmallScreen ? 14 : 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text(
                  endPanelData?.bookings??"",
                  style: TextStyle(color: Colors.black54, fontSize: isSmallScreen ? 10 : 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
     
     
      ),
        ],
      )
        



    );
  }

  Widget _buildNoServicesAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build_circle_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No services available",
            style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final double cardAspectRatio = isSmallScreen ? 0.6 : 0.65;
    final double imageHeight = isSmallScreen ? 90 : 100;
    final selectedServices = getSelectedServices();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      appBar: AppBar(
        toolbarHeight: screenSize.aspectRatio,
        backgroundColor:  MyColors.appThemeLight,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            SizedBox(height: 10,),
            _buildStatsRow(isSmallScreen),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: _services.isEmpty
                    ? _buildNoServicesAvailable()
                    : GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 14,
                        childAspectRatio: cardAspectRatio,
                        children: _services.map((service) {
                          return _buildServiceCard(
                            context: context,
                            service: service,
                            imageHeight: imageHeight,
                            onIncrement: () => incrementQuantity(service['id']),
                            onDecrement: () => decrementQuantity(service['id']),
                          );
                        }).toList(),
                      ),
              ),
            ),
            if (selectedServices.isNotEmpty) _buildBottomBar(context, selectedServices),
          ],
        ),
      ),
    );
  }


Widget _buildServiceCard({
  required BuildContext context,
  required Map<String, dynamic> service,
  required double imageHeight,
  required VoidCallback onIncrement,
  required VoidCallback onDecrement,
}) {
  final bool isSmallScreen = MediaQuery.of(context).size.width < 360;
  final int quantity = service['quantity'] ?? 0;
  final bool isAdded = quantity > 0;

  final String imagePath = service['service_image'] ?? '';
  final String imageUrl = imagePath.startsWith('http')
      ? imagePath
      : "https://dev.gobuddyindia.com/assets/images/$imagePath";

  final String title = service['title'] ?? 'No Title';
  final String reviews = service['total_reviews']?.toString() ?? '10k reviews';
  final String averageRating = service['average_rating']?.toString() ?? '5.0';
  final String timeDuration = service['time']?.toString() ?? '2h 30min';

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    child: Transform.scale(
      scale: isAdded ? 1.05 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: isAdded ? 14 : 8,
              spreadRadius: isAdded ? 1 : 0,
              offset: const Offset(0, 6),
            ),
          ],
        ), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// IMAGE SECTION
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: imageHeight + 10,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: imageHeight + 10,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: imageHeight + 10,
                      color: const Color(0xFFE8F5E9),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/logoImg.png',
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  /// Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// TITLE
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 11 : 13,
                ),
              ),
            ),

            /// RATING
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Icon(Icons.star,
                      color: Colors.orange, size: 14),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      "$averageRating ($reviews)",
                      style:
                          TextStyle(fontSize: isSmallScreen ? 10 : 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            /// TIME
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.schedule,
                      color: Colors.grey, size: 13),
                  const SizedBox(width: 3),
                  Text(
                    timeDuration,
                    style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.grey),
                  ),
                ],
              ),
            ),

            /// VIEW DETAILS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: () {
                  final serviceId = service['id'];

                  Navigator.pushNamed(
                    context,
                    Config.serviceDetailsRouteName,
                    arguments: {
                      'service_id': serviceId
                    },
                  );
                },
                child: Text(
                  "View Details",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                ),
              ),
            ),

            const Spacer(),

            /// ADD BUTTON
            Center(
              child: GestureDetector(
                onTap: () {
                  if (!isAdded) {
                    onIncrement();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 10),
                  width: 90,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF1EB35B)),
                    borderRadius: BorderRadius.circular(20),
                    color: isAdded
                        ? const Color(0xFF1EB35B)
                        : Colors.white,
                  ),
                  child: Center(
                    child: isAdded
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: onDecrement,
                                child: const Icon(Icons.remove,
                                    size: 18, color: Colors.white),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "$quantity",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: onIncrement,
                                child: const Icon(Icons.add,
                                    size: 18, color: Colors.white),
                              ),
                            ],
                          )
                        : Text(
                            "Add",
                            style: TextStyle(
                                color: MyColors.appThemeLight,
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    isSmallScreen ? 12 : 14),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildBottomBar(BuildContext context, List<Map<String, dynamic>> selectedServices) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show all selected services with their quantities
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: selectedServices.map((service) {
              return Text(
                "${service['title']} (${service['quantity']})",
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: Colors.grey),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.appThemeLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                   Navigator.pushNamed(
                    context,
                    arguments: {
                         'sendingServices'  :selectedServices,
                         'user_id' : userId??""
                    } ,
                    Config.serviceDateandTimeScreen
                     );
              },
              child: const Text(
                "Pick a Schedule",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Include your existing _buildServiceCard() and _buildBottomBar() methods without changes
}
