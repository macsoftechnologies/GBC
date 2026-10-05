// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:gobuddy_customer_app/models/best_provider_model.dart';
// import 'package:gobuddy_customer_app/models/getproviders_model.dart';
// import 'package:intl/intl.dart';
// import 'package:gobuddy_customer_app/services/end_points.dart';
// import 'package:gobuddy_customer_app/services/repository.dart';
// import 'package:gobuddy_customer_app/utils/my_colors.dart';
// import 'package:gobuddy_customer_app/utils/util_class.dart';
// import '../../utils/config.dart';

// class SelectProviderScreen extends StatefulWidget {
//   const SelectProviderScreen({super.key});

//   @override
//   State<SelectProviderScreen> createState() => _SelectProviderScreenState();
// }

// class _SelectProviderScreenState extends State<SelectProviderScreen> {
//   List<dynamic> getServices = [];
//   Map<String, dynamic> serviceQuantities = {};
//   List<int> serviceIds = [];
//   String? date;
//   String? time;
//  String? formattedTime;
//  GetProvidersModel?pushProvidersModel;
// List<Data>? providersList;
//  Services?providerServicesData;
//  Data? selectedProvider;
//  String? userId;
//  String?MaincategoryId;

//  ProviderAutoSelectModel? providerAutoSelectModel;
//  ProviderData? getProviderData;
//  ProviderServices? getProviderServices;

//   String? get shortDate {
//   if (date == null) return null;
//   try {
//     final parsed = DateTime.parse(date!);
//     return DateFormat('yyyy-MM-dd').format(parsed);
//   } catch (e) {
//     return date;
//   }
// }

//   /// Lifecycle
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     final args =
//         ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

//     if (args != null &&
//         args.containsKey('services') &&
//         args.containsKey('date') &&
//         args.containsKey('user_id') &&
//         args.containsKey('time')) {
//       final servicesMap = args['services'] as Map<String, dynamic>;
//       final sendingServices = servicesMap['sendingServices'] as List<dynamic>;

//       date = args['date'] as String?;
//       time = args['time'] as String?;
//       userId  = args['user_id'] as String;
//        MaincategoryId = args['main_category_id']?.toString();

//       setState(() {
//         getServices = sendingServices;
//         serviceIds = getServices.map<int>((service) {
//           if (service is Map<String, dynamic>) {
//             final id = service['id'];
//             if (id is int) return id;
//             if (id is String) return int.tryParse(id) ?? 0;
//           }
//           return 0;
//         }).where((id) => id != 0).toList();
//       });

//       print("MaincategoryId received: $MaincategoryId");
//       print("serviceIds built: $serviceIds");

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _getProviders();
//       });
//     }
//   }

// Future<void> _fliterProviders() async {
//   bool internet = await UtilClass.checkInternet();
//   if (!internet) {
//     UtilClass.showAlertDialog(context: context, message: "No Internet Connection");
//     return;
//   }

//   // 🕒 Format schedule_time ("11:00 AM" → "11:00:00")
//   String? formattedTime;
//   try {
//     if (time != null && time!.isNotEmpty) {
//       final parsedTime = DateFormat('hh:mm a').parse(time!);
//       formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
//     }
//   } catch (e) {
//     print("⚠️ Time parsing failed: $e");
//     formattedTime = null;
//   }

//   // 📅 Format schedule_date ("2025-10-23 15:58:01.315883" → "2025-10-23")
//   String? formattedDate;
//   try {
//     if (date != null && date!.isNotEmpty) {
//       final parsedDate = DateTime.parse(date!);
//       formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
//     }
//   } catch (e) {
//     print("⚠️ Date parsing failed: $e");
//     formattedDate = shortDate; // fallback or default
//   }

//   if (formattedDate == null || formattedDate.isEmpty) {
//     print("❌ schedule_date is null or empty!");
//     return;
//   }
//   if (formattedTime == null || formattedTime.isEmpty) {
//     print("❌ schedule_time is null or empty!");
//     return;
//   }

//   // Determine sort params based on selectedSortOption
//   String priceOrder = "";
//   String ratingOrder = "";

//   switch (selectedSortOption) {
//     case 'Price -- Low to High':
//       priceOrder = "asc";
//       ratingOrder = "";
//       break;
//     case 'Price -- High to low':
//       priceOrder = "desc";
//       ratingOrder = "";
//       break;
//     case 'Rating high to low':
//       priceOrder = "";
//       ratingOrder = "desc";
//       break;
//     case 'Near by me':
//       // Assuming no price or rating order sorting for Nearby; maybe handle distance in API or client-side
//       priceOrder = "";
//       ratingOrder = "";
//       break;
//     default:
//       priceOrder = "";
//       ratingOrder = "";
//   }

//   final Map<String, dynamic> body = {
//     "category_id": int.tryParse(MaincategoryId ?? "") ?? 0,
//     "schedule_date": formattedDate,
//     "schedule_time": formattedTime,
//     "service_ids": serviceIds,
//     // "price_order": priceOrder,
//     // "rating_order": ratingOrder,
//   };

//   print("Filter Providers Request body: $body");

//   try {
//     final response = await Repository.postApiRawService(
//       EndPoints.getProviderAPi,
//       body,
//     );

//     print("Filtered Providers Response: $response");

//     late Map<String, dynamic> jsonResponse;
//     if (response is String) {
//       jsonResponse = json.decode(response as String);
//     } else if (response is Map<String, dynamic>) {
//       jsonResponse = response;
//     }
//     if (jsonResponse["status"] == "valid") {
//       setState(() {
//         pushProvidersModel = GetProvidersModel.fromJson(jsonResponse);
//         providersList = pushProvidersModel?.data;
//       });
//     } else {
//       print("❌ Invalid status: ${jsonResponse["status"]}");
//       print("🪪 Message: ${jsonResponse["message"]}");
//     }
//   } catch (e, stack) {
//     print("🔥 Error in _fliterProviders: $e");
//     print(stack);
//   }
// }

// Future<void> _getProviders() async {
//   bool internet = await UtilClass.checkInternet();
//   if (!internet) {
//     UtilClass.showAlertDialog(
//       context: context,
//       message: "No Internet Connection!",
//     );
//     return;
//   }
//   String? formattedTime;
//   try {
//     if (time != null && time!.isNotEmpty) {
//       final parsedTime = DateFormat('hh:mm a').parse(time!);
//       formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
//     }
//   } catch (e) {
//     print("⚠️ Time parsing failed: $e");
//     formattedTime = null;
//   }

//   String? formattedDate;
//   try {
//     if (date != null && date!.isNotEmpty) {
//       final parsedDate = DateTime.parse(date!);
//       formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
//     }
//   } catch (e) {
//     print("⚠️ Date parsing failed: $e");
//     formattedDate = shortDate;
//   }

//   if (formattedDate == null || formattedDate.isEmpty) {
//     print("❌ schedule_date is null or empty!");
//     return;
//   }
//   if (formattedTime == null || formattedTime.isEmpty) {
//     print("❌ schedule_time is null or empty!");
//     return;
//   }

//   // Build request body
//   final Map<String, dynamic> body = {
//     "category_id": int.tryParse(MaincategoryId ?? "") ?? 0,
//     "schedule_date": formattedDate,
//     "schedule_time": formattedTime,
//     "service_ids": serviceIds,
//     "price_order": "",
//     "rating_order": "",
//   };

//   print("Get Providers Request body: $body");

//   try {

//     final response = await Repository.FlexiblePostApi(
//       EndPoints.getProviderAPi,
//       body,
//     );

//     print("This is Raw Response $response");

//     late Map<String, dynamic> jsonResponse;
//     if (response is String) {
//       jsonResponse = json.decode(response as String);
//     } else if (response is Map<String, dynamic>) {
//       jsonResponse = response;
//     }

//     if (jsonResponse["status"] == "valid") {
//       pushProvidersModel = GetProvidersModel.fromJson(jsonResponse);

//       if (pushProvidersModel?.data != null &&
//           pushProvidersModel!.data!.isNotEmpty) {
//         setState(() {
//          providersList = pushProvidersModel!.data!;
//         });
//       }
//     } else {
//       print("🪪 Message: ${jsonResponse["message"]}");
//     }
//   } catch (e, stack) {
//     print("🔥 Error in _getProviders: $e");
//     print(stack);
//   }
// }

// Future<void> _getBestProvider() async {
//   bool internet  = await UtilClass.checkInternet();
//   if(!internet){
//     UtilClass.showAlertDialog(context: context, message: "No Internet Connection");
//     return;
//   }

//   try {
//     final response = await Repository.postApiRawService(
//       EndPoints.AssignbestProvider,
//       {
//         "category_id": int.tryParse(MaincategoryId ?? "") ?? 0,
//         "schedule_date": shortDate,
//         "schedule_time": formattedTime,
//         "service_ids": serviceIds,
//       },

//     );

//     Map<String, dynamic>jsonResponse;
//     if(response is String){
//       jsonResponse = json.decode(response as String);
//     } else if(response is Map<String, dynamic>){
//       jsonResponse = response;
//     }

//     if(jsonResponse["status"]==="valid"){
//       setState(() {
//         providerAutoSelectModel = ProviderAutoSelectModel.fromJson(jsonResponse);
//         getProviderData = providerAutoSelectModel?.data;
//         getProviderServices = providerAutoSelectModel?.data?.services?.isNotEmpty == true
//             ? providerAutoSelectModel?.data?.services
//             : null;
//       });
//     } else {
//       print("🪪 Message: ${jsonResponse["message"]}");
//     }
//   } catch (e) {
//     print("🔥 Error in _getBestProvider: $e");
//   }
// }

//   int quantity = 1;

//   String? selectedSortOption;

//     void _showSortBottomSheet() {
//       showModalBottomSheet(
//         context: context,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         builder: (BuildContext context) {
//           return StatefulBuilder(
//             builder: (BuildContext context, StateSetter modalSetState) {
//               return Container(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Sort by',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),
//                     _buildSortOption(modalSetState, 'Price -- Low to High'),
//                     _buildSortOption(modalSetState, 'Price -- High to low'),
//                     _buildSortOption(modalSetState, 'Rating high to low'),
//                     _buildSortOption(modalSetState, 'Near by me'),
//                     const SizedBox(height: 50),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child:

//                      ElevatedButton(
//   onPressed: selectedSortOption != null
//       ? () async {
//           Navigator.pop(context); // Close the bottom sheet
//           await _fliterProviders();
//           setState(() {
//             // Update UI if needed here after filtering
//           });
//         }
//       : null,
//   style: ElevatedButton.styleFrom(
//     backgroundColor: selectedSortOption != null
//         ? MyColors.appThemeLight
//         : Colors.grey,
//     foregroundColor: Colors.white,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(10),
//     ),
//   ),
//   child: const Text('Select'),
// ),

//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       );
//     }

//   Widget _buildSortOption(StateSetter modalSetState, String title) {
//     return InkWell(
//       onTap: () {
//         modalSetState(() {
//           selectedSortOption = title;
//         });
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 2),
//         child: Row(
//           children: [
//             Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
//             Radio<String>(
//               value: title,
//               groupValue: selectedSortOption,
//               onChanged: (String? value) {
//                 modalSetState(() {
//                   selectedSortOption = value;
//                 });
//               },
//               activeColor: MyColors.appThemeLight,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Bottom Sheet for Selected Provider
// void _showSelectedProviderBottomSheet(Data provider) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (BuildContext context) {
//       // Calculate total quantity dynamically
//   int totalQuantity = getServices.fold(0, (sum, item) {
//   final q = item['quantity'];
//   int qty = 1;
//   if (q != null) {
//     if (q is int) qty = q;
//     else if (q is String) qty = int.tryParse(q) ?? 1;
//     else if (q is num) qty = q.toInt();
//   }
//   return sum + qty;
// });

//       return Container(
//         height: MediaQuery.of(context).size.height * 0.3,
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(provider.name ?? '',
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Text(
//                   '₹ ${provider.totalOriginalPrice ?? ''}',
//                   style: const TextStyle(
//                       decoration: TextDecoration.lineThrough,
//                       color: Colors.grey,
//                       fontSize: 12),
//                 ),
//                 const SizedBox(width: 10),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.shade100,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     '${provider.discountPercentage ?? 0} % Off',
//                     style: const TextStyle(
//                         color: Colors.orange,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Text(
//               '₹ ${provider.finalPrice ?? ''}   ($totalQuantity)', // <-- updated
//               style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               height: 45,
//               child: ElevatedButton(
//                 onPressed: () {

//                   Navigator.pushNamed(
//                     context,
//                     arguments: {
//                       'provider_name': provider.name ?? "",
//                       'provider_total_orignal_price' : provider.totalOriginalPrice??"",
//                       'provider_discount_price' : provider.totalDiscountAmount??"",
//                       'provider_id': provider.providerId ?? "",
//                       'date': date ?? "",
//                       'time': time ?? "",
//                       'sub_category': getServices,
//                       'user_id' : userId,
//                       'main_category_id' : MaincategoryId??""

//                       // ✅ will include updated quantities
//                     },
//                     Config.serviceOrderSummaryRouteName,
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: MyColors.appThemeLight,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                 ),
//                 child: const Text("View Summary",
//                     style: TextStyle(color: Colors.white)),
//               ),
//             )
//           ],
//         ),
//       );
//     },
//   );
// }

//   /// UI BUILD
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: const BoxDecoration(
//                           color: Colors.white, shape: BoxShape.circle),
//                       child: Center(
//                         child: Image.asset(
//                           "assets/images/whiteLeftArrow.png",
//                           width: 9,
//                           color: const Color(0xFF19a64b),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const Text('Select Provider',
//                       style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black)),
//                   const SizedBox(width: 48),
//                 ],
//               ),
//               const SizedBox(height: 24),

//               /// Services List
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: getServices.map((item) {
//                       final id = item['id'];
//                       final name = item['title'];
//                       final type = item['type'] ?? '';
//                       final quantity = item['quantity'] ?? 1;
//                       final price = item['price'];

//                       return Column(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(name,
//                                           style: const TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 13,
//                                               color: Colors.black)),
//                                       const SizedBox(height: 1),
//                                       Text(type,
//                                           style: const TextStyle(
//                                               color: Colors.grey,
//                                               fontSize: 10)),
//                                     ],
//                                   ),
//                                 ),
//                                 Container(
//                                   height: 35,
//                                   width: 110,
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                         color: Colors.green, width: 2),
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceEvenly,
//                                     children: [
//                                       IconButton(
//                                         icon: const Icon(Icons.remove,
//                                             color: Colors.green, size: 16),
//                                          onPressed: () {
//     setState(() {
//       final currentQuantity = item['quantity'] ?? 1;
//       if (currentQuantity > 1) {
//         item['quantity'] = currentQuantity - 1;
//       }
//     });
//   },
//                                         constraints: const BoxConstraints(
//                                             minWidth: 26, minHeight: 26),
//                                         padding: EdgeInsets.zero,
//                                       ),
//                                       Text('$quantity',
//                                           style: const TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w600,
//                                               color: MyColors.appThemeLight)),
//                                       IconButton(
//                                         icon: const Icon(Icons.add,
//                                             color: Colors.green, size: 16),
//                                         onPressed: () {
//     setState(() {
//       final currentQuantity = item['quantity'] ?? 1;
//       item['quantity'] = currentQuantity + 1;
//     });
//   },
//                                         constraints: const BoxConstraints(
//                                             minWidth: 26, minHeight: 26),
//                                         padding: EdgeInsets.zero,
//                                       ),

//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),

//               /// Skip Provider
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE8F5E8),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.green.shade100,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Icon(Icons.settings,
//                           size: 20, color: Colors.green),
//                     ),
//                     const SizedBox(width: 12),
//                     const Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Save time & Skip Provider Selection',
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 13,
//                                   color: Colors.black)),
//                           Text('(We will pick best provider)',
//                               style:
//                                   TextStyle(color: Colors.grey, fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                     const Icon(Icons.arrow_forward_ios,
//                         size: 16, color: Colors.green),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('Service Providers',
//                       style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black)),
//                   Container(
//                     height: 45,
//                     width: 45,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(22),
//                     ),
//                     child: IconButton(
//                       onPressed: _showSortBottomSheet,
//                       icon: const Icon(Icons.tune, color: Colors.black),
//                       iconSize: 24,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),

//            Expanded(
//   child: ListView.builder(
//     itemCount: providersList?.length ?? 0,
//     itemBuilder: (context, index) {
//       final provider = providersList![index];
//       return Container(
//         margin: const EdgeInsets.only(bottom: 14),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//   backgroundImage: NetworkImage(
//     provider.profile != null
//       ? 'https://dev.gobuddyindia.com/${provider.profile?.replaceAll(r'\', '/')}'
//       : 'https://dev.gobuddyindia.com/assets/images/default_profile.png',
//   ),
//   radius: 24,
//   onBackgroundImageError: (error, stackTrace) {
//     debugPrint('Image failed to load');
//   },
// ),

//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         provider.name ?? "",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 15,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           const Icon(Icons.star, color: Colors.orange, size: 16),
//                           const SizedBox(width: 4),
//                           Text(
//                             provider.averageRating != null
//                                 ? provider.averageRating!.toStringAsFixed(1)
//                                 : 'N/A',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 14,
//                             ),
//                           ),
//                           Text(
//                             '  (${provider.reviewCount ?? "0"} reviews)',
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           const Icon(Icons.location_on, size: 14, color: Colors.grey),
//                           const SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               provider.landmark ?? "",
//                               style: const TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 12,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           // If you have distance in provider, use it; else remove this Text widget
//                           // Text('  (${provider.distance ?? ""})',
//                           //     style: const TextStyle(color: Colors.grey, fontSize: 12)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Row(
//               children: [
//                 Text(
//                   '₹ ${provider.totalOriginalPrice ?? ""}',
//                   style: const TextStyle(
//                     decoration: TextDecoration.lineThrough,
//                     color: Colors.grey,
//                     fontSize: 12,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.shade100,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     '${provider.discountPercentage ?? 0} % Off',
//                     style: const TextStyle(
//                       color: Colors.orange,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     '₹ ${provider.finalPrice ?? ""}   ($quantity)',
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//                  OutlinedButton(
//                   onPressed: () {
//                      Navigator.pushNamed(
//                       context,
//                        Config.providerOverviewScreen,
//                        arguments: {
//                           "provider_id" : provider.providerId??""
//                        }
//                       );
//                   },
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.grey),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20)),
//                     minimumSize: const Size(40, 30),
//                   ),
//                   child: Text(
//                     'view Profile',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: selectedProvider == provider
//                           ? Colors.green
//                           : MyColors.appThemeLight,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10,),
//                 OutlinedButton(
//                   onPressed: () {
//                     setState(() {
//                        selectedProvider = provider;
//                     });
//                     _showSelectedProviderBottomSheet(provider);
//                   },
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.grey),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20)),
//                     minimumSize: const Size(80, 30),
//                   ),
//                   child: Text(
//                     selectedProvider == provider ? 'Selected' : 'Select',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: selectedProvider == provider
//                           ? Colors.green
//                           : MyColors.appThemeLight,
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       );
//     },
//   ),
// ),

//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gobuddy_customer_app/models/best_provider_model.dart';
import 'package:gobuddy_customer_app/models/getproviders_model.dart';
import 'package:intl/intl.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/config.dart';

class SelectProviderScreen extends StatefulWidget {
  const SelectProviderScreen({super.key});

  @override
  State<SelectProviderScreen> createState() => _SelectProviderScreenState();
}

class _SelectProviderScreenState extends State<SelectProviderScreen> {
  List<dynamic> getServices = [];
  Map<String, dynamic> serviceQuantities = {};
  List<int> serviceIds = [];
  String? date;
  String? time;
  String? formattedTime;
  GetProvidersModel? pushProvidersModel;
  List<Data>? providersList;
  Services? providerServicesData;
  Data? selectedProvider;
  String? userId;
  String? MaincategoryId;

  ProviderAutoSelectModel? providerAutoSelectModel;
  ProviderData? getProviderData;
  List<ProviderServices>? services;

  /// Raw JSON data from the "best provider" (skip selection) response.
  /// Used directly for navigation args so we don't depend on model field names.
  Map<String, dynamic>? bestProviderRawData;

  /// Loading flag for the "Save time & Skip Provider Selection" tap
  bool isFetchingBestProvider = false;

  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userLat = prefs.getDouble('user_lat');
      _userLng = prefs.getDouble('user_lng');
      if (_userLat == null || _userLng == null) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
          );
          _userLat = pos.latitude;
          _userLng = pos.longitude;
        } else {
          // Standard city center coordinates fallback so distance is always computable
          _userLat = 17.6868;
          _userLng = 83.2185;
        }
      }
      if (mounted) setState(() {});
    } catch (_) {
      _userLat ??= 17.6868;
      _userLng ??= 83.2185;
    }
  }

  void _applySorting() {
    if (providersList == null || providersList!.isEmpty) return;
    if (selectedSortOption == 'Near by me') {
      providersList!.sort(
        (a, b) => _calculateDistance(a).compareTo(_calculateDistance(b)),
      );
    } else if (selectedSortOption == 'Price -- Low to High') {
      providersList!.sort((a, b) {
        double pA =
            double.tryParse(
              a.finalPrice?.toString().replaceAll(',', '') ?? '0',
            ) ??
            0;
        double pB =
            double.tryParse(
              b.finalPrice?.toString().replaceAll(',', '') ?? '0',
            ) ??
            0;
        return pA.compareTo(pB);
      });
    } else if (selectedSortOption == 'Price -- High to low') {
      providersList!.sort((a, b) {
        double pA =
            double.tryParse(
              a.finalPrice?.toString().replaceAll(',', '') ?? '0',
            ) ??
            0;
        double pB =
            double.tryParse(
              b.finalPrice?.toString().replaceAll(',', '') ?? '0',
            ) ??
            0;
        return pB.compareTo(pA);
      });
    } else if (selectedSortOption == 'Rating high to low') {
      providersList!.sort(
        (a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0),
      );
    }
  }

  double _calculateDistance(Data provider) {
    if (_userLat == null ||
        _userLng == null ||
        provider.latitude == null ||
        provider.longitude == null) {
      return 999999.0;
    }
    final pLat = double.tryParse(provider.latitude.toString());
    final pLng = double.tryParse(provider.longitude.toString());
    if (pLat == null || pLng == null) return 999999.0;
    return Geolocator.distanceBetween(_userLat!, _userLng!, pLat, pLng) /
        1000.0;
  }

  bool _isProviderAvailable(Data provider) {
    // 1. Distance filter (standard 20km radius)
    if (_calculateDistance(provider) > 20.0) {
      return false;
    }

    // 2. Vacation mode / on holiday
    if (provider.vacationMode == '1' ||
        provider.vacationMode?.toLowerCase() == 'yes' ||
        provider.vacationMode?.toLowerCase() == 'true') {
      return false;
    }

    // 3. Holiday / on leave
    if (provider.isHoliday == '1' ||
        provider.isHoliday?.toLowerCase() == 'yes' ||
        provider.isHoliday?.toLowerCase() == 'true') {
      return false;
    }

    // 4. Availability flag if explicitly marked unavailable
    if (provider.isAvailable == '0' ||
        provider.isAvailable?.toLowerCase() == 'no' ||
        provider.isAvailable?.toLowerCase() == 'false') {
      return false;
    }

    // 5. Inactive provider status
    if (provider.status == '0' ||
        provider.status?.toLowerCase() == 'inactive') {
      return false;
    }

    return true;
  }

  String? get shortDate {
    if (date == null) return null;
    try {
      final parsed = DateTime.parse(date!);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (e) {
      return date;
    }
  }

  /// Lifecycle
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null &&
        args.containsKey('services') &&
        args.containsKey('date') &&
        args.containsKey('user_id') &&
        args.containsKey('time')) {
      final servicesMap = args['services'] as Map<String, dynamic>;
      final sendingServices = servicesMap['sendingServices'] as List<dynamic>;

      date = args['date'] as String?;
      time = args['time'] as String?;
      userId = args['user_id'] as String;
      MaincategoryId = args['main_category_id']?.toString();

      setState(() {
        getServices = sendingServices;
        serviceIds = getServices
            .map<int>((service) {
              if (service is Map<String, dynamic>) {
                final id = service['id'];
                if (id is int) return id;
                if (id is String) return int.tryParse(id) ?? 0;
              }
              return 0;
            })
            .where((id) => id != 0)
            .toList();
      });

      print("MaincategoryId received: $MaincategoryId");
      print("serviceIds built: $serviceIds");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getProviders();
      });
    }
  }

  Future<void> _fliterProviders() async {
    bool internet = await UtilClass.checkInternet();
    if (!internet) {
      UtilClass.showAlertDialog(
        context: context,
        message: "No Internet Connection",
      );
      return;
    }

    // 🕒 Format schedule_time ("11:00 AM" → "11:00:00")
    String? formattedTime;
    try {
      if (time != null && time!.isNotEmpty) {
        final parsedTime = DateFormat('hh:mm a').parse(time!);
        formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
      }
    } catch (e) {
      print("⚠️ Time parsing failed: $e");
      formattedTime = null;
    }

    // 📅 Format schedule_date ("2025-10-23 15:58:01.315883" → "2025-10-23")
    String? formattedDate;
    try {
      if (date != null && date!.isNotEmpty) {
        final parsedDate = DateTime.parse(date!);
        formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      }
    } catch (e) {
      print("⚠️ Date parsing failed: $e");
      formattedDate = shortDate; // fallback or default
    }

    if (formattedDate == null || formattedDate.isEmpty) {
      print("❌ schedule_date is null or empty!");
      return;
    }
    if (formattedTime == null || formattedTime.isEmpty) {
      print("❌ schedule_time is null or empty!");
      return;
    }

    // Determine sort params based on selectedSortOption
    String priceOrder = "";
    String ratingOrder = "";

    switch (selectedSortOption) {
      case 'Price -- Low to High':
        priceOrder = "asc";
        ratingOrder = "";
        break;
      case 'Price -- High to low':
        priceOrder = "desc";
        ratingOrder = "";
        break;
      case 'Rating high to low':
        priceOrder = "";
        ratingOrder = "desc";
        break;
      case 'Near by me':
        priceOrder = "";
        ratingOrder = "";
        break;
      default:
        priceOrder = "";
        ratingOrder = "";
    }

    final Map<String, dynamic> body = {
      "category_id": int.tryParse(MaincategoryId ?? "") ?? 0,
      "schedule_date": formattedDate,
      "schedule_time": formattedTime,
      "service_ids": serviceIds,
      "price_order": priceOrder,
      "rating_order": ratingOrder,
    };

    print("Filter Providers Request body: $body");

    try {
      final response = await Repository.postApiRawService(
        EndPoints.getProviderAPi,
        body,
      );

      print("Filtered Providers Response: $response");

      late Map<String, dynamic> jsonResponse;
      if (response is String) {
        jsonResponse = json.decode(response as String);
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      }
      if (jsonResponse["status"] == "valid") {
        setState(() {
          pushProvidersModel = GetProvidersModel.fromJson(jsonResponse);
          final all = pushProvidersModel?.data ?? [];
          final available = all.where(_isProviderAvailable).toList();
          providersList = available;
          _applySorting();
        });
      } else {
        print("❌ Invalid status: ${jsonResponse["status"]}");
        print("🪪 Message: ${jsonResponse["message"]}");
      }
    } catch (e, stack) {
      print("🔥 Error in _fliterProviders: $e");
      print(stack);
    }
  }

  Future<void> _getProviders() async {
    bool internet = await UtilClass.checkInternet();
    if (!internet) {
      UtilClass.showAlertDialog(
        context: context,
        message: "No Internet Connection!",
      );
      return;
    }
    String? formattedTime;
    try {
      if (time != null && time!.isNotEmpty) {
        final parsedTime = DateFormat('hh:mm a').parse(time!);
        formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
      }
    } catch (e) {
      print("⚠️ Time parsing failed: $e");
      formattedTime = null;
    }

    String? formattedDate;
    try {
      if (date != null && date!.isNotEmpty) {
        final parsedDate = DateTime.parse(date!);
        formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      }
    } catch (e) {
      print("⚠️ Date parsing failed: $e");
      formattedDate = shortDate;
    }

    if (formattedDate == null || formattedDate.isEmpty) {
      print("❌ schedule_date is null or empty!");
      return;
    }
    if (formattedTime == null || formattedTime.isEmpty) {
      print("❌ schedule_time is null or empty!");
      return;
    }

    // Build request body
    final Map<String, dynamic> body = {
      "category_id": int.tryParse(MaincategoryId ?? "") ?? 0,
      "schedule_date": formattedDate,
      "schedule_time": formattedTime,
      "service_ids": serviceIds,
      "price_order": "",
      "rating_order": "",
    };

    print("Get Providers Request body: $body");

    try {
      final response = await Repository.FlexiblePostApi(
        EndPoints.getProviderAPi,
        body,
      );

      print("This is Raw Response $response");

      late Map<String, dynamic> jsonResponse;
      if (response is String) {
        jsonResponse = json.decode(response as String);
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      }

      if (jsonResponse["status"] == "valid") {
        pushProvidersModel = GetProvidersModel.fromJson(jsonResponse);

        if (pushProvidersModel?.data != null &&
            pushProvidersModel!.data!.isNotEmpty) {
          setState(() {
            final all = pushProvidersModel!.data!;
            final available = all.where(_isProviderAvailable).toList();
            providersList = available;
            _applySorting();
          });
        }
      } else {
        print("🪪 Message: ${jsonResponse["message"]}");
      }
    } catch (e, stack) {
      print("🔥 Error in _getProviders: $e");
      print(stack);
    }
  }

  /// Called when the user taps "Save time & Skip Provider Selection".
  /// Fetches the auto-assigned best provider and, on success, navigates
  /// straight to the order summary screen using that provider's details.
  Future<void> _onSkipProviderTap() async {
    if (isFetchingBestProvider) return; // prevent double taps

    setState(() {
      isFetchingBestProvider = true;
    });

    await _getBestProvider();

    if (mounted) {
      setState(() {
        isFetchingBestProvider = false;
      });
    }
  }

  Future<void> _getBestProvider() async {
    bool internet = await UtilClass.checkInternet();
    if (!internet) {
      UtilClass.showAlertDialog(
        context: context,
        message: "No Internet Connection",
      );
      return;
    }

    // 🕒 Format schedule_time the same way the other calls do.
    // (Previously this used the never-set class-level `formattedTime` field,
    // which was always null.)
    String? formattedTimeLocal;
    try {
      if (time != null && time!.isNotEmpty) {
        final parsedTime = DateFormat('hh:mm a').parse(time!);
        formattedTimeLocal = DateFormat('HH:mm:ss').format(parsedTime);
      }
    } catch (e) {
      print("⚠️ Time parsing failed: $e");
      formattedTimeLocal = null;
    }

    // 📅 Format schedule_date the same way the other calls do.
    String? formattedDateLocal;
    try {
      if (date != null && date!.isNotEmpty) {
        final parsedDate = DateTime.parse(date!);
        formattedDateLocal = DateFormat('yyyy-MM-dd').format(parsedDate);
      }
    } catch (e) {
      print("⚠️ Date parsing failed: $e");
      formattedDateLocal = shortDate;
    }

    if (formattedDateLocal == null || formattedDateLocal.isEmpty) {
      print("❌ schedule_date is null or empty!");
      UtilClass.showAlertDialog(
        context: context,
        message: "Please select a valid date",
      );
      return;
    }
    if (formattedTimeLocal == null || formattedTimeLocal.isEmpty) {
      print("❌ schedule_time is null or empty!");
      UtilClass.showAlertDialog(
        context: context,
        message: "Please select a valid time",
      );
      return;
    }

    try {
      final response =
          await Repository.postApiRawService(EndPoints.AssignbestProvider, {
            "category_id": int.tryParse(MaincategoryId ?? "") ?? 0,
            "schedule_date": formattedDateLocal,
            "schedule_time": formattedTimeLocal,
            "service_ids": serviceIds,
          });

      Map<String, dynamic> jsonResponse;
      if (response is String) {
        jsonResponse = json.decode(response as String);
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      } else {
        print(
          "🔥 Unexpected response type in _getBestProvider: ${response.runtimeType}",
        );
        UtilClass.showAlertDialog(
          context: context,
          message: "Something went wrong. Please try again.",
        );
        return;
      }

      // Fixed: was `===` which is not valid Dart syntax
      if (jsonResponse["status"] == "valid") {
        final data = jsonResponse["data"] as Map<String, dynamic>?;

        setState(() {
          providerAutoSelectModel = ProviderAutoSelectModel.fromJson(
            jsonResponse,
          );
          getProviderData = providerAutoSelectModel?.data;
          services = providerAutoSelectModel?.data?.services;
          bestProviderRawData = data;
        });

        if (data == null) {
          UtilClass.showAlertDialog(
            context: context,
            message: "No provider available for this slot",
          );
          return;
        }

        _navigateWithBestProvider(data);
      } else {
        print("🪪 Message: ${jsonResponse["message"]}");
        UtilClass.showAlertDialog(
          context: context,
          message:
              jsonResponse["message"]?.toString() ??
              "No provider available for this slot",
        );
      }
    } catch (e, stack) {
      print("🔥 Error in _getBestProvider: $e");
      print(stack);
      UtilClass.showAlertDialog(
        context: context,
        message: "Something went wrong. Please try again.",
      );
    }
  }

  /// Navigates to the order summary screen using the auto-assigned
  /// best-provider data, following the same arguments contract as
  /// the manual "Select" flow in `_showSelectedProviderBottomSheet`.
  int get _totalSelectedQuantity {
    return getServices.fold(0, (sum, item) {
      if (item is Map<String, dynamic>) {
        final q = item['quantity'];
        int qty = 1;
        if (q is int) {
          qty = q;
        } else if (q is String) {
          qty = int.tryParse(q) ?? 1;
        } else if (q is num) {
          qty = q.toInt();
        }
        return sum + (qty > 0 ? qty : 1);
      }
      return sum + 1;
    });
  }

  Map<String, double> _calculateProviderPrices(Data provider) {
    double origTotal = 0.0;
    double discTotal = 0.0;
    double finalTotal = 0.0;

    final pServices = provider.services;
    int totalQty = _totalSelectedQuantity;

    if (pServices != null && pServices.isNotEmpty) {
      for (var s in getServices) {
        if (s is Map<String, dynamic>) {
          final sid = s['id']?.toString();
          final qVal = s['quantity'];
          int qty = 1;
          if (qVal is int) {
            qty = qVal;
          } else if (qVal is String) {
            qty = int.tryParse(qVal) ?? 1;
          }
          if (qty <= 0) qty = 1;

          Services? matching;
          for (var ps in pServices) {
            if (ps.serviceId?.toString() == sid) {
              matching = ps;
              break;
            }
          }

          double p =
              double.tryParse(
                matching?.price?.toString().replaceAll(',', '') ?? '',
              ) ??
              ((double.tryParse(
                        provider.totalOriginalPrice?.toString().replaceAll(
                              ',',
                              '',
                            ) ??
                            '',
                      ) ??
                      0.0) /
                  (getServices.isNotEmpty ? getServices.length : 1));
          double d =
              double.tryParse(
                matching?.discountAmount?.toString().replaceAll(',', '') ?? '',
              ) ??
              ((double.tryParse(
                        provider.totalDiscountAmount?.toString().replaceAll(
                              ',',
                              '',
                            ) ??
                            '',
                      ) ??
                      0.0) /
                  (getServices.isNotEmpty ? getServices.length : 1));
          double f =
              double.tryParse(
                matching?.finalPrice?.toString().replaceAll(',', '') ?? '',
              ) ??
              (p - d);

          origTotal += p * qty;
          discTotal += d * qty;
          finalTotal += f * qty;
        }
      }
    } else {
      double p =
          double.tryParse(
            provider.totalOriginalPrice?.toString().replaceAll(',', '') ?? '0',
          ) ??
          0.0;
      double d =
          double.tryParse(
            provider.totalDiscountAmount?.toString().replaceAll(',', '') ?? '0',
          ) ??
          0.0;
      double f =
          double.tryParse(
            provider.finalPrice?.toString().replaceAll(',', '') ?? '0',
          ) ??
          (p - d);

      origTotal = p * totalQty;
      discTotal = d * totalQty;
      finalTotal = f * totalQty;
    }

    return {
      'orig': origTotal > 0
          ? origTotal
          : (double.tryParse(
                  provider.totalOriginalPrice?.toString().replaceAll(',', '') ??
                      '0',
                ) ??
                0.0),
      'disc': discTotal,
      'final': finalTotal > 0
          ? finalTotal
          : (double.tryParse(
                  provider.finalPrice?.toString().replaceAll(',', '') ?? '0',
                ) ??
                0.0),
    };
  }

  void _attachUnitPricesToServices(Data provider) {
    final pServices = provider.services;
    for (var s in getServices) {
      if (s is Map<String, dynamic>) {
        final sid = s['id']?.toString();
        Services? matching;
        if (pServices != null) {
          for (var ps in pServices) {
            if (ps.serviceId?.toString() == sid) {
              matching = ps;
              break;
            }
          }
        }
        double unitP =
            double.tryParse(
              matching?.price?.toString().replaceAll(',', '') ?? '',
            ) ??
            ((double.tryParse(
                      provider.totalOriginalPrice?.toString().replaceAll(
                            ',',
                            '',
                          ) ??
                          '',
                    ) ??
                    0.0) /
                (getServices.isNotEmpty ? getServices.length : 1));
        double unitD =
            double.tryParse(
              matching?.discountAmount?.toString().replaceAll(',', '') ?? '',
            ) ??
            ((double.tryParse(
                      provider.totalDiscountAmount?.toString().replaceAll(
                            ',',
                            '',
                          ) ??
                          '',
                    ) ??
                    0.0) /
                (getServices.isNotEmpty ? getServices.length : 1));
        double unitF =
            double.tryParse(
              matching?.finalPrice?.toString().replaceAll(',', '') ?? '',
            ) ??
            (unitP - unitD);

        s['unit_price'] = unitP;
        s['unit_discount'] = unitD;
        s['unit_final_price'] = unitF;
      }
    }
  }

  /// Navigates to the order summary screen using the auto-assigned
  /// best-provider data, following the same arguments contract as
  /// the manual "Select" flow in `_showSelectedProviderBottomSheet`.
  void _navigateWithBestProvider(Map<String, dynamic> data) {
    double calculatedOriginal = 0.0;
    double calculatedDiscount = 0.0;

    final servicesList = data['services'] as List<dynamic>?;
    if (servicesList != null && servicesList.isNotEmpty) {
      for (var s in servicesList) {
        if (s is Map<String, dynamic>) {
          double p =
              double.tryParse(
                s['price']?.toString().replaceAll(',', '') ?? '0',
              ) ??
              0.0;
          double d =
              double.tryParse(
                s['discount_amount']?.toString().replaceAll(',', '') ?? '0',
              ) ??
              0.0;
          final sid = s['service_id']?.toString();
          int qty = 1;
          for (var gs in getServices) {
            if (gs is Map<String, dynamic> && gs['id']?.toString() == sid) {
              final q = gs['quantity'];
              if (q is int) {
                qty = q;
              } else if (q is String) {
                qty = int.tryParse(q) ?? 1;
              }
              gs['unit_price'] = p;
              gs['unit_discount'] = d;
              gs['unit_final_price'] = p - d;
              break;
            }
          }
          calculatedOriginal += p * qty;
          calculatedDiscount += d * qty;
        }
      }
    }

    String origPrice = calculatedOriginal > 0
        ? calculatedOriginal.toStringAsFixed(2)
        : (data['total_original_price']?.toString() ?? "");

    String discPrice = calculatedDiscount > 0
        ? calculatedDiscount.toStringAsFixed(2)
        : (data['total_discount_amount']?.toString() ?? "0");

    Navigator.pushNamed(
      context,
      Config.serviceOrderSummaryRouteName,
      arguments: {
        'provider_name': data['name'] ?? "",
        'provider_total_orignal_price': origPrice,
        'provider_discount_price': discPrice,
        'provider_id': data['provider_id'] ?? "",
        'date': date ?? "",
        'time': time ?? "",
        'sub_category': getServices,
        'user_id': userId,
        'main_category_id': MaincategoryId ?? "",
      },
    );
  }

  int quantity = 1;

  String? selectedSortOption;

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort by',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildSortOption(modalSetState, 'Price -- Low to High'),
                  _buildSortOption(modalSetState, 'Price -- High to low'),
                  _buildSortOption(modalSetState, 'Rating high to low'),
                  _buildSortOption(modalSetState, 'Near by me'),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: selectedSortOption != null
                          ? () async {
                              Navigator.pop(context); // Close the bottom sheet
                              setState(() {
                                _applySorting();
                              });
                              await _fliterProviders();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedSortOption != null
                            ? MyColors.appThemeLight
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Select'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(StateSetter modalSetState, String title) {
    return InkWell(
      onTap: () {
        modalSetState(() {
          selectedSortOption = title;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            Radio<String>(
              value: title,
              groupValue: selectedSortOption,
              onChanged: (String? value) {
                modalSetState(() {
                  selectedSortOption = value;
                });
              },
              activeColor: MyColors.appThemeLight,
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Sheet for Selected Provider
  void _showSelectedProviderBottomSheet(Data provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final prices = _calculateProviderPrices(provider);
        int totalQuantity = _totalSelectedQuantity;

        return Container(
          height: MediaQuery.of(context).size.height * 0.3,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.name ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '₹ ${prices['orig']!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${provider.discountPercentage ?? 0} % Off',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '₹ ${prices['final']!.toStringAsFixed(2)}   ($totalQuantity)',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    _attachUnitPricesToServices(provider);
                    Navigator.pushNamed(
                      context,
                      arguments: {
                        'provider_name': provider.name ?? "",
                        'provider_total_orignal_price': prices['orig']!
                            .toStringAsFixed(2),
                        'provider_discount_price': prices['disc']!
                            .toStringAsFixed(2),
                        'provider_id': provider.providerId ?? "",
                        'date': date ?? "",
                        'time': time ?? "",
                        'sub_category': getServices,
                        'user_id': userId,
                        'main_category_id': MaincategoryId ?? "",
                      },
                      Config.serviceOrderSummaryRouteName,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.appThemeLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "View Summary",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// UI BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
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
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/images/whiteLeftArrow.png",
                          width: 9,
                          color: const Color(0xFF19a64b),
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Select Provider',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),

              /// Services List
              Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: getServices.map((item) {
                      final id = item['id'];
                      final name = item['title'];
                      final type = item['type'] ?? '';
                      final quantity = item['quantity'] ?? 1;
                      final price = item['price'];

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        type,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 35,
                                  width: 110,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.green,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            final currentQuantity =
                                                item['quantity'] ?? 1;
                                            if (currentQuantity > 1) {
                                              item['quantity'] =
                                                  currentQuantity - 1;
                                            }
                                          });
                                        },
                                        constraints: const BoxConstraints(
                                          minWidth: 26,
                                          minHeight: 26,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: MyColors.appThemeLight,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            final currentQuantity =
                                                item['quantity'] ?? 1;
                                            item['quantity'] =
                                                currentQuantity + 1;
                                          });
                                        },
                                        constraints: const BoxConstraints(
                                          minWidth: 26,
                                          minHeight: 26,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              /// Skip Provider — now wired to _onSkipProviderTap
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isFetchingBestProvider ? null : _onSkipProviderTap,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.settings,
                          size: 20,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Save time & Skip Provider Selection',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '(We will pick best provider)',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      isFetchingBestProvider
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.green,
                              ),
                            )
                          : const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.green,
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Service Providers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: IconButton(
                      onPressed: _showSortBottomSheet,
                      icon: const Icon(Icons.tune, color: Colors.black),
                      iconSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Expanded(
                child: providersList == null
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      )
                    : (providersList!.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text(
                                  "No providers available in your area",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: providersList!.length,
                              itemBuilder: (context, index) {
                                final provider = providersList![index];
                                final dist = _calculateDistance(provider);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              provider.profile != null
                                                  ? 'https://dev.gobuddyindia.com/${provider.profile?.replaceAll(r'\', '/')}'
                                                  : 'https://dev.gobuddyindia.com/assets/images/default_profile.png',
                                            ),
                                            radius: 24,
                                            onBackgroundImageError:
                                                (error, stackTrace) {
                                                  debugPrint(
                                                    'Image failed to load',
                                                  );
                                                },
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  provider.name ?? "",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      color: Colors.orange,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      provider.averageRating !=
                                                              null
                                                          ? provider
                                                                .averageRating!
                                                                .toStringAsFixed(
                                                                  1,
                                                                )
                                                          : 'N/A',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    Text(
                                                      '  (${provider.reviewCount ?? "0"} reviews)',
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      size: 14,
                                                      color: Colors.grey,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        provider.landmark ?? "",
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    if (dist < 99999) ...[
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        "${dist.toStringAsFixed(1)} km",
                                                        style: TextStyle(
                                                          color: dist > 20
                                                              ? Colors.red
                                                              : const Color(
                                                                  0xFF2E7D32,
                                                                ),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                if (dist <= 20 &&
                                                    dist < 99999) ...[
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFE8F5E9,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors
                                                            .green
                                                            .shade200,
                                                        width: 0.5,
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      "Within 20 km",
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF2E7D32,
                                                        ),
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ] else if (dist > 20 &&
                                                    dist < 99999) ...[
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            Colors.red.shade200,
                                                        width: 0.5,
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      "Outside standard 20 km radius",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Builder(
                                        builder: (context) {
                                          final cardPrices =
                                              _calculateProviderPrices(
                                                provider,
                                              );
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Text(
                                                    '₹ ${cardPrices['orig']!.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .orange
                                                          .shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '${provider.discountPercentage ?? 0} % Off',
                                                      style: const TextStyle(
                                                        color: Colors.orange,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '₹ ${cardPrices['final']!.toStringAsFixed(2)}   ($_totalSelectedQuantity)',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  OutlinedButton(
                                                    onPressed: () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        Config
                                                            .providerOverviewScreen,
                                                        arguments: {
                                                          "provider_id":
                                                              provider
                                                                  .providerId ??
                                                              "",
                                                          "provider_name":
                                                              provider.name ??
                                                              "",
                                                          "provider_profile":
                                                              provider
                                                                  .profile ??
                                                              "",
                                                          "provider_category":
                                                              provider
                                                                  .category ??
                                                              "",
                                                          "provider_rating":
                                                              provider
                                                                  .averageRating ??
                                                              0.0,
                                                          "provider_reviews":
                                                              provider
                                                                  .reviewCount ??
                                                              "0",
                                                          "provider_bookings":
                                                              provider
                                                                  .bookings ??
                                                              "0",
                                                          "provider_landmark":
                                                              provider
                                                                  .landmark ??
                                                              "",
                                                          "provider_price":
                                                              provider
                                                                  .finalPrice ??
                                                              "",
                                                          "distance":
                                                              dist < 99999
                                                              ? "${dist.toStringAsFixed(1)} KM"
                                                              : "",
                                                        },
                                                      );
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                      side: const BorderSide(
                                                        color: Colors.grey,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      minimumSize: const Size(
                                                        40,
                                                        30,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'view Profile',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            selectedProvider ==
                                                                provider
                                                            ? Colors.green
                                                            : MyColors
                                                                  .appThemeLight,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  OutlinedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        selectedProvider =
                                                            provider;
                                                      });
                                                      _showSelectedProviderBottomSheet(
                                                        provider,
                                                      );
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                      side: const BorderSide(
                                                        color: Colors.grey,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      minimumSize: const Size(
                                                        80,
                                                        30,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      selectedProvider ==
                                                              provider
                                                          ? 'Selected'
                                                          : 'Select',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            selectedProvider ==
                                                                provider
                                                            ? Colors.green
                                                            : MyColors
                                                                  .appThemeLight,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
