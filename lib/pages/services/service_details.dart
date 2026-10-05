import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/common/skeleton_loader.dart';
import 'package:gobuddy_customer_app/models/service_overview_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'dart:convert';


import 'add_services_to_cart.dart';
// import 'package:gobuddy_app/constants/ColorConstants.dart';
// import 'package:gobuddy_app/screens/acServices/acSubServices/splitAcStatic.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({super.key,});
  

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}


class _ServiceDetailsScreenState extends State<ServiceDetailsScreen>
    with SingleTickerProviderStateMixin {
      dynamic serviceId;
      String? status;
      ServiceOverviewModel? pushServicesintoModel;
      bool _isLoading = false;

Data? serviceData;
List<Data> servicesData = [];
List<Gallery> gallery = [];
List<Review> reviews = [];




    

  late TabController _tabController;
  int _itemCount = 0;


@override
void didChangeDependencies() {
  super.didChangeDependencies();

  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  
  if (args != null) {
    if (args.containsKey('service_id') && args['service_id'] != null) {
      serviceId = args['service_id'];
    } else if (args.containsKey('serviceData') && args['serviceData'] is Map) {
      final sMap = args['serviceData'] as Map;
      serviceId = sMap['id'] ?? sMap['service_id'];
    }

    // Pre-populate serviceData from arguments if available for instant display
    if (args.containsKey('serviceData') && args['serviceData'] is Map && serviceData == null) {
      final s = args['serviceData'] as Map;
      serviceData = Data(
        id: (s['id'] ?? s['service_id'] ?? serviceId ?? '').toString(),
        subCategoryId: (s['sub_category_id'] ?? '').toString(),
        title: (s['title'] ?? s['name'] ?? 'Service').toString(),
        priceConfiguration: (s['price_configuration'] ?? '').toString(),
        price: (s['price'] ?? s['service_price'] ?? '').toString(),
        extraChargesTitle: (s['extra_charges_title'] ?? '').toString(),
        extraChargesPrice: (s['extra_charges_price'] ?? '').toString(),
        presponsibility: (s['presponsibility'] ?? '').toString(),
        cresponsibility: (s['cresponsibility'] ?? '').toString(),
        note: (s['note'] ?? s['description'] ?? '').toString(),
        serviceImage: (s['image'] ?? s['service_image'] ?? '').toString(),
        averageRating: int.tryParse(s['rating']?.toString() ?? '0') ?? 0,
        totalComments: int.tryParse(s['total_comments']?.toString() ?? '0') ?? 0,
        bookings: int.tryParse(s['bookings']?.toString() ?? '0') ?? 0,
        gallery: [],
        reviews: [],
      );
    }

    if (serviceId != null && serviceId.toString().isNotEmpty) {
      _getServiceOverview();
    }
  }
}

Future<void> _getServiceOverview() async {
  bool hasInternet = await UtilClass.checkInternet();
  
  if (!hasInternet) {
    if (serviceData == null) {
      UtilClass.showAlertDialog(
        context: context,
        message: "No internet connection.",
      );
    }
    return;
  }

  try {
    final response = await Repository.NewPostApiService(
      EndPoints.getServiceOverview,
      {
        "service_id": serviceId ?? "",
      },
    );

    // Decode response based on type
    late Map<String, dynamic> jsonResponse;

    if (response is String) {
      jsonResponse = json.decode(response as String);
    } else if (response is Map<String, dynamic>) {
      jsonResponse = response;
    } 

    // Check status from API response
    if ((jsonResponse["status"]?.toString().toLowerCase() ?? "") == "valid") {
      final overviewModel = ServiceOverviewModel.fromJson(jsonResponse);

      if (overviewModel.data != null) {
        setState(() {
          serviceData = overviewModel.data!;
          gallery = serviceData!.gallery;
          reviews = serviceData!.reviews;
        });

        print("Gallery count: ${gallery.length}");
        print("Reviews count: ${reviews.length}");
      } else {
        print("⚠️ No 'data' available in response.");
        if (serviceData == null) {
          UtilClass.showAlertDialog(
            context: context,
            message: "No service data available.",
          );
        }
      }
    } else {
      // Server responded with error or no overview in database
      final errorMessage = jsonResponse["message"] ?? "Something went wrong.";
      print("❌ Server responded with error: $errorMessage");

      if (serviceData == null) {
        UtilClass.showAlertDialog(
          context: context,
          message: "Service details are currently unavailable for this item.",
        );
      }
    }
  } catch (e, stackTrace) {
    print("❌ Exception during API call: $e");
    print(stackTrace);
    if (serviceData == null) {
      UtilClass.showAlertDialog(
        context: context,
        message: "Unable to load service details at this moment. Please try again.",
      );
    }
  }
}




  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;
    final bool isSmallScreen = width < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
            _buildAppBar(context, width),

            // Service Image
            _buildServiceImage(width, serviceData),

            // Title, Rating and Add Button
            _buildServiceHeader(context,  serviceData),

            const Divider(
              color: Colors.grey,
              thickness: 0.3,
              indent: 17,
              endIndent: 17,
            ),

            // About the service section
           _buildAboutSection(serviceData),


            // What's included section
            _buildIncludedSection(),

            // Please note section
            _buildNotesSection(),

            SizedBox(height: isSmallScreen ? 8 : 10),
            const Divider(
              color: Colors.grey,
              thickness: 0.3,
              indent: 17,
              endIndent: 17,
            ),
            SizedBox(height: isSmallScreen ? 8 : 10),

            // Rating section
            _buildRatingSection(serviceData),

        // Tabs: Photos / Videos
_buildMediaTabsSection(gallery.isNotEmpty ? gallery[0] : null),

// Reviews section
_buildReviewsSection(reviews.isNotEmpty ? reviews[0] : null),

          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, double width) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      decoration: const BoxDecoration(color: MyColors.appThemeLight),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: 13,
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                child: Image.asset(
                  "assets/images/whiteLeftArrow.png",
                  width: 9,
                ),
              ),
            ),
            SizedBox(width: width * 0.25),
            const Text(
              "Details",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildServiceImage(
  double width,
  Data? servicedata, {
  String baseUrl = 'https://dev.gobuddyindia.com/assets/images/',
}) {

  String buildImageUrl(String base, String? imageName) {
    if (imageName == null || imageName.isEmpty) return '';
    base = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    imageName = imageName.startsWith('/') ? imageName.substring(1) : imageName;
    return '$base/$imageName';
  }

  final imageUrl = buildImageUrl(baseUrl, servicedata?.serviceImage);

  return Container(
    margin: EdgeInsets.symmetric(horizontal: width * 0.045, vertical: 14),
    height: 180,
    width: double.infinity,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,

              /// IMAGE LOADING SKELETON
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return const SkeletonLoader(
                  height: 180,
                  width: double.infinity,
                  radius: 16,
                );
              },

              /// IMAGE ERROR FALLBACK
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFE8F5E9),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logoImg.png',
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            )
          : const SkeletonLoader(
              height: 180,
              width: double.infinity,
              radius: 16,
            ),
    ),
  );
}
Widget _buildNoImageFound() {
  return Container(
    color: Colors.grey[300],
    child: Center(
      child: Text(
        'No Image Found',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}



Widget _buildServiceHeader(BuildContext context, Data? servicedata) {
  final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

  /// SHOW SKELETON WHEN DATA IS NULL
  if (servicedata == null) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(height: 18, width: 200),
          SizedBox(height: 10),
          SkeletonLoader(height: 14, width: 120),
          SizedBox(height: 10),
          Row(
            children: [
              SkeletonLoader(height: 12, width: 80),
              SizedBox(width: 12),
              SkeletonLoader(height: 12, width: 100),
            ],
          )
        ],
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              Text(
                servicedata.title ?? "Unknown Title",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 15 : 16,
                ),
              ),

              const SizedBox(height: 6),

              /// RATING
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    servicedata.averageRating?.toString() ?? '0',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              /// DURATION + BOOKINGS
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "Duration",
                    style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.people, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "${servicedata.bookings ?? 0} Bookings",
                    style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    ),
  );
}
Widget _buildAboutSection(Data? servicedata) {

  /// SHOW SKELETON WHEN DATA IS NULL
  if (servicedata == null) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(height: 16, width: 150),
          SizedBox(height: 12),
          SkeletonLoader(height: 12, width: double.infinity),
          SizedBox(height: 8),
          SkeletonLoader(height: 12, width: double.infinity),
          SizedBox(height: 8),
          SkeletonLoader(height: 12, width: 250),
        ],
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          "About the service",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          servicedata.presponsibility ?? "",
          style: const TextStyle(
            color: Colors.black38,
            fontSize: 13,
          ),
        ),
      ),
    ],
  );
}

Widget _buildIncludedSection() {
  final List<String> fallbackItems = [
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
  ];

  // Safely parse cresponsibility string into list items
  final List<String> includedItems = (serviceData?.cresponsibility?.isNotEmpty ?? false)
      ? serviceData!.cresponsibility!
          .split(RegExp(r'[\n•\-•]+')) // Split on newlines or bullet-like characters
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList()
      : fallbackItems;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          "What's included",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      ...includedItems.map(
        (item) => _buildInfoRow(Icons.check_circle, Colors.green, item),
      ),
    ],
  );
}


Widget _buildNotesSection() {

  /// SHOW SKELETON WHILE API IS LOADING
  if (serviceData == null) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(height: 16, width: 120),
          SizedBox(height: 12),
          SkeletonLoader(height: 12, width: double.infinity),
          SizedBox(height: 8),
          SkeletonLoader(height: 12, width: double.infinity),
          SizedBox(height: 8),
          SkeletonLoader(height: 12, width: 250),
        ],
      ),
    );
  }

  List<String> notes;

  if (serviceData?.note == null || serviceData!.note.trim().isEmpty) {
    notes = ["No NOTE AVAILABLE"];
  } else {
    notes = (serviceData!.note)
        .split(RegExp(r'[\n•\-]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Notes",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 10),

        /// NOTES LIST
        ...notes.map(
          (note) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ",
                    style: TextStyle(fontSize: 14, color: Colors.black87)),
                Expanded(
                  child: Text(
                    note,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildInfoRow(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black38),
            ),
          ),
        ],
      ),
    );
  }
Widget _buildRatingSection(Data? serviceData) {
  final num rating = serviceData?.averageRating ?? 4.8;

  return Column(
    children: [
      // Rating Large
      Center(
        child: Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),

      const SizedBox(height: 4),

      // Stars
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return const Icon(Icons.star, color: Colors.orange, size: 24);
            } else if (index < rating) {
              return const Icon(Icons.star_half, color: Colors.orange, size: 24);
            } else {
              return const Icon(Icons.star_border, color: Colors.orange, size: 24);
            }
          }),
        ),
      ),

      const SizedBox(height: 6),

      // Uncomment and customize this if you want to show review count later
      /*
      Center(
        child: Text(
          "Based on all reviews (${_formatNumber(reviewCount)} Reviews)",
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
      */
    ],
  );
}

Widget _buildMediaTabsSection(Gallery? gallery) {
  if (gallery == null) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          "No images or videos available",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  final bool hasPhoto = gallery.image != null && gallery.image!.isNotEmpty;
  // final bool hasVideo = gallery.videos != null && gallery.videos!.isNotEmpty;

  // if (!hasPhoto && !hasVideo) {
  //   return const Padding(
  //     padding: EdgeInsets.all(16),
  //     child: Center(
  //       child: Text(
  //         "No images or videos available",
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  //       ),
  //     ),
  //   );
  // }

  return Column(
    children: [
      const SizedBox(height: 16),

      TabBar(
        controller: _tabController,
        labelColor: MyColors.appThemeLight,
        unselectedLabelColor: Colors.black45,
        indicatorColor: MyColors.appThemeLight,
        tabs: const [
          Tab(text: "Photos"),
          Tab(text: "Videos"),
        ],
      ),

      SizedBox(
        height: 100,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Photos tab
            hasPhoto
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.network(
                      gallery.image!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        color: const Color(0xFFE8F5E9),
                        child: const Icon(Icons.cleaning_services,
                            size: 40, color: Color(0xFF19a64b)),
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      "No images available",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),

            // Videos tab
            // hasVideo
            //     ? Padding(
            //         padding: const EdgeInsets.all(8),
            //         child: Image.network(
            //           gallery.videos!,
            //           width: 100,
            //           height: 100,
            //           fit: BoxFit.cover,
            //           errorBuilder: (context, error, stackTrace) =>
            //               const Icon(Icons.broken_image, size: 100),
            //         ),
            //       )
            //     : const Center(
            //         child: Text(
            //           "No videos available",
            //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            //         ),
            //       ),
          ],
        ),
      ),
    ],
  );
}


// Widget _buildMediaTabsSection(Gallery? gallery) {
//   if (gallery == null) {
//     return const Padding(
//       padding: EdgeInsets.all(16),
//       child: Center(
//         child: Text(
//           "No images or videos available",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//         ),
//       ),
//     );
//   }

//   // photos as list - handle if gallery.image is null or empty string
//   final List<String> photos = (gallery.image != null && gallery.image!.isNotEmpty)
//       ? [gallery.image!]
//       : [];

//   // Assume videos could be null or empty; replace with real data if you have it
//   // final List<String> videos = (gallery.videos != null && gallery.videos!.isNotEmpty)
//   //     ? List<String>.from(gallery.videos!)
//   //     : [];

//   final bool hasPhotos = photos.isNotEmpty;
//   // final bool hasVideos = videos.isNotEmpty;

//   // if (!hasPhotos && !hasVideos) {
//   //   return const Padding(
//   //     padding: EdgeInsets.all(16),
//   //     child: Center(
//   //       child: Text(
//   //         "No images or videos available",
//   //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//   //       ),
//   //     ),
//   //   );
//   // }

//   return Column(
//     children: [
//       const SizedBox(height: 16),

//       // Tabs: Photos / Videos
//       TabBar(
//         controller: _tabController,
//         labelColor: MyColors.appThemeLight,
//         unselectedLabelColor: Colors.black45,
//         indicatorColor: MyColors.appThemeLight,
//         tabs: const [
//           Tab(text: "Photos"),
//           Tab(text: "Videos"),
//         ],
//       ),

//       SizedBox(
//         height: 100,
//         child: TabBarView(
//           controller: _tabController,
//           children: [
//             // Photos Tab
//             hasPhotos
//                 ? ListView(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.all(8),
//                     children: photos.map((photo) {
//                       return Container(
//                         margin: const EdgeInsets.only(right: 8),
//                         child: Image.network(
//                           photo,
//                           width: 100,
//                           height: 100,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               const Icon(Icons.broken_image, size: 100),
//                         ),
//                       );
//                     }).toList(),
//                   )
//                 : const Center(child: Text("No photos available")),

//             // Videos Tab
//             hasVideos
//                 ? ListView(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.all(8),
//                     children: videos.map((video) {
//                       return Container(
//                         margin: const EdgeInsets.only(right: 8),
//                         child: Image.network(
//                           video,
//                           width: 100,
//                           height: 100,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               const Icon(Icons.broken_image, size: 100),
//                         ),
//                       );
//                     }).toList(),
//                   )
//                 : const Center(child: Text("No videos available")),
//           ],
//         ),
//       ),
//     ],
//   );
// }
Widget _buildReviewsSection(Review? review) {
  // If reviews list is null or empty, show message
  if (reviews.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          "No reviews available",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          "Reviews",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),

      ...reviews.map((r) {
        // Defensive checks
        final String name = r.userName ?? 'Anonymous';
        final String time = r.userId ?? 'Some time ago';
        final double rating = (r.rating != null)
            ? double.tryParse(r.rating.toString()) ?? 4.0
            : 4.0;
        final String comment = r.comments ?? 'No comments Avaliable';
        final String image = (r.profile != null && r.profile!.isNotEmpty)
            ? r.profile
            : 'https://dev.gobuddyindia.com/assets/images/default_profile.png';

        return Column(
          children: [
            _buildReviewTile(
              name: name,
              time: time,
              rating: rating,
              image: image,
              comment: comment,
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.3,
              indent: 17,
              endIndent: 17,
            ),
          ],
        );
      }).toList(),
    ],
  );
}
Widget _buildReviewTile({
  required String name,
  required String time,
  required double rating,
  required String image,
  required String comment,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(image),
          onBackgroundImageError: (_, __) {},
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    if (index < rating.floor()) {
                      return const Icon(Icons.star, size: 16, color: Colors.orange);
                    } else if (index < rating) {
                      return const Icon(Icons.star_half, size: 16, color: Colors.orange);
                    } else {
                      return const Icon(Icons.star_border, size: 16, color: Colors.orange);
                    }
                  }),
                  const SizedBox(width: 6),
                  Text("($rating)", style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment,
                style: const TextStyle(fontSize: 13),
              )
            ],
          ),
        )
      ],
    ),
  );
}

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }


}