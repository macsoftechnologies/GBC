import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/common/skeleton_loader.dart';
import 'package:gobuddy_customer_app/models/provider_overview_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';


class ProviderReviewDetails extends StatefulWidget {


  const ProviderReviewDetails({super.key});

  @override
  State<ProviderReviewDetails> createState() => _ProviderReviewDetailsState();
}

class _ProviderReviewDetailsState extends State<ProviderReviewDetails> {
  int selectedIndex = 1; 
  int galleryTabIndex = 0; 
  String? providerId;
  String? passedDistance;
  String? passedName;
  String? passedProfile;
  String? passedCategory;
  double? passedRating;
  String? passedReviews;
  String? passedBookings;
  String? passedLandmark;
  String? passedPrice;

  ProviderDetails? pushproviderDetails;
  ProviderDetails? onlyproviderDetails;
  List<About> pushAbout = [];
  List<GalleryItem> pushGallery = [];
  List<Review> pushReviews = [];



@override
void didChangeDependencies() {
  super.didChangeDependencies();

  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

  if (args != null) {
    providerId = args['provider_id']?.toString();
    passedDistance = args['distance']?.toString() ?? "";
    passedName = args['provider_name']?.toString();
    passedProfile = args['provider_profile']?.toString();
    passedCategory = args['provider_category']?.toString();
    if (args['provider_rating'] is num) {
      passedRating = (args['provider_rating'] as num).toDouble();
    } else if (args['provider_rating'] != null) {
      passedRating = double.tryParse(args['provider_rating'].toString());
    }
    passedReviews = args['provider_reviews']?.toString();
    passedBookings = args['provider_bookings']?.toString();
    passedLandmark = args['provider_landmark']?.toString();
    passedPrice = args['provider_price']?.toString();

    if (providerId != null && providerId!.isNotEmpty) {
      _getProviderOverview();
    }
  }
}


Future<void> _getProviderOverview() async {
  final bool internet = await UtilClass.checkInternet();
  if (!internet) {
    UtilClass.showAlertDialog(
      context: context,
      message: "No Internet Connection",
    );
    return;
  }

        UtilClass.showProgress(context: context);

  try {
    final response = await Repository.NewPostApiService(
      EndPoints.getProviderOverview,
      {"id": providerId ?? ""},
    );

     UtilClass.hideProgress();

    print("Raw response: $response");

    Map<String, dynamic>? jsonResponse;

    if (response is String) {
      jsonResponse = json.decode(response as String);
    } else if (response is Map<String, dynamic>) {
      jsonResponse = response;
    }

    if (jsonResponse == null) {
      print("Invalid response format");
      return;
    }

    if (jsonResponse["status"] == "valid") {
      final providerData = jsonResponse["provider_details"];
      if (providerData != null && providerData is Map<String, dynamic>) {
        setState(() {
          // Use the fromJson constructor to parse typed lists
          onlyproviderDetails = ProviderDetails.fromJson(providerData);

          pushproviderDetails = onlyproviderDetails;
          pushAbout = onlyproviderDetails?.about ?? [];
          pushGallery = onlyproviderDetails?.gallery ?? [];
          pushReviews = onlyproviderDetails?.reviews ?? [];
        });
      } else {
        print("No provider data found in response");
      }
    } else {
      final message = jsonResponse["message"] ?? "Error fetching Provider Overview";
      print("Error: $message");
    }
  } catch (e, stack) {
     UtilClass.hideProgress();
    print("Exception in _getProviderOverview: $e");
    print(stack);
   
  }
}

  // Sample JSON data structure
  final Map<String, dynamic> serviceProviderData = {
    "id": "1",
    "name": "Srinivasarao Damana",
    "profession": "AC Technician, Plumber",
    "rating": 4.8,
    "reviewCount": 120000,
    "bookingCount": 100000,
    "location": "Madhurawada, Vizag.",
    "distance": "2.5 KM",
    "profileImage": "assets/images/man.jpg",
    "isVerified": true,
    "about": "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
        "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, "
        "when an unknown printer took a galley of type and scrambled it to make a type specimen book. "
        "It has survived not only five centuries,",
    "photos": [
      "assets/images/ACInstallation.jpg",
      "assets/images/ACJetServicing.jpg",
      "assets/images/DryAcCleaning.jpg",
      "assets/images/AcUninstall.png",
      "assets/images/acRepair.png",
      "assets/images/ACJetServicing.jpg",
    ],
    "videos": [],
    "reviews": [
      {
        "id": "1",
        "userName": "Viswak Varma",
        "userImage": "assets/images/man.jpg",
        "rating": 4.5,
        "timeAgo": "2 days ago",
        "comment": "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s."
      },
      {
        "id": "2",
        "userName": "Pradeep ranga",
        "userImage": "assets/images/man.jpg",
        "rating": 4.5,
        "timeAgo": "3 days ago",
        "comment": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
      }
    ],
    "ratingDistribution": {
      "excellent": 0.9,
      "good": 0.6,
      "average": 0.3,
      "belowAverage": 0.15,
      "poor": 0.1
    }
  };

  final List<String> tabs = ['About', 'Gallery', 'Reviews'];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;
    final bool isSmallScreen = width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF7),
      body: Column(
        children: [
          // Green App Bar
          _buildAppBar(context, width),

          // Profile Section
          _buildProfileSection(),

          // Tabs
          _buildTabsSection(width),

          const SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildTabContent(),
            ),
          ),
        ],
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
          vertical: 15,
        ),
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
            SizedBox(width: width * 0.2),
            const Text(
              "View Profile",
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

Widget _buildProfileSection() {

  /// SHOW SKELETON WHILE API IS LOADING
  if (onlyproviderDetails == null) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Profile Image Skeleton
          SkeletonLoader(
            height: 60,
            width: 60,
            radius: 12,
          ),

          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SkeletonLoader(height: 16, width: 150),
                SizedBox(height: 6),

                SkeletonLoader(height: 14, width: 200),
                SizedBox(height: 8),

                SkeletonLoader(height: 12, width: 120),
                SizedBox(height: 6),

                SkeletonLoader(height: 12, width: 140),
                SizedBox(height: 8),

                SkeletonLoader(height: 12, width: double.infinity),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// NORMAL UI AFTER DATA LOADS
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Profile Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            onlyproviderDetails?.profile ?? "",
            height: 60,
            width: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 60,
                width: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.grey),
              );
            },
          ),
        ),

        const SizedBox(width: 16),

        /// Profile Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// NAME + VERIFIED + DISTANCE
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  /// Name + Verified badge
                  Expanded(
                    child: Row(
                      children: [

                        Flexible(
                          child: Text(
                            onlyproviderDetails?.name ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 6),

                        if (serviceProviderData['isVerified'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  "Verified",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  /// Distance (Top Right)
                  if ((passedDistance != null && passedDistance!.isNotEmpty) || (onlyproviderDetails?.landmark != null && onlyproviderDetails!.landmark!.isNotEmpty))
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          passedDistance?.isNotEmpty == true ? "$passedDistance KM" : (onlyproviderDetails?.landmark ?? ""),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 4),

              /// Email
              if (onlyproviderDetails?.email != null && onlyproviderDetails!.email!.isNotEmpty) ...[
                Text(
                  onlyproviderDetails!.email!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
              ],

              /// Rating & Reviews
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${onlyproviderDetails?.rating ?? passedRating ?? 0.0}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "(${onlyproviderDetails?.reviewCount ?? passedReviews ?? 0} Reviews)",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '• ${passedBookings?.isNotEmpty == true ? passedBookings : "0"} Bookings',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              /// Price (if passed)
              if (passedPrice != null && passedPrice!.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.currency_rupee,
                        size: 15, color: Colors.green),
                    const SizedBox(width: 2),
                    Text(
                      "₹ $passedPrice",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],

              /// Location
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),

                  Expanded(
                    child: Text(
                      onlyproviderDetails?.location?.isNotEmpty == true
                          ? onlyproviderDetails!.location!
                          : (passedLandmark ?? ""),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    ),
  );
}
 
  Widget _buildTabsSection(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFDFF2E1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedIndex) {
      case 0:
        return _buildAboutTab(pushAbout);
      case 1:
        return _buildGalleryTab(pushGallery);
      case 2:
        return _buildReviewsTab(pushReviews);
      default:
        return _buildAboutTab(pushAbout);
    }
  }

Widget _buildAboutTab(List<About>? pushAbout) {

  /// SHOW SKELETON WHILE API IS LOADING
  if (pushAbout == null) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(height: 14, width: double.infinity),
          SizedBox(height: 10),
          SkeletonLoader(height: 14, width: double.infinity),
          SizedBox(height: 10),
          SkeletonLoader(height: 14, width: 250),
          SizedBox(height: 10),
          SkeletonLoader(height: 14, width: double.infinity),
        ],
      ),
    );
  }

  /// SHOW MESSAGE IF EMPTY
  if (pushAbout.isEmpty) {
    return const Center(
      child: Text(
        "No information available",
        style: TextStyle(fontSize: 14, color: Colors.black54),
      ),
    );
  }

  /// SHOW REAL DATA
  return SingleChildScrollView(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pushAbout.map((aboutItem) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            aboutItem.description ?? "",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        );
      }).toList(),
    ),
  );
}


Widget _buildGalleryTab(List<GalleryItem>? gallery) {

  /// SHOW SKELETON WHILE API IS LOADING
  if (gallery == null) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          /// Tabs Skeleton
          const Row(
            children: [
              Expanded(child: SkeletonLoader(height: 18, width: 80)),
              Expanded(child: SkeletonLoader(height: 18, width: 80)),
            ],
          ),

          const SizedBox(height: 16),

          /// Grid Skeleton
          Expanded(
            child: GridView.builder(
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                return const SkeletonLoader(
                  height: 100,
                  width: 100,
                  radius: 8,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// SHOW MESSAGE IF EMPTY
  if (gallery.isEmpty) {
    return const Center(
      child: Text(
        "No gallery items available",
        style: TextStyle(fontSize: 14, color: Colors.black54),
      ),
    );
  }

  /// Separate photos and videos
  final photos = gallery.where((item) => !item.image.endsWith(".mp4")).toList();
  final videos = gallery.where((item) => item.image.endsWith(".mp4")).toList();

  return Column(
    children: [
      /// Photos / Videos Tabs
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  galleryTabIndex = 0;
                });
              },
              child: Column(
                children: [
                  Text(
                    "Photos",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: galleryTabIndex == 0 ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (galleryTabIndex == 0)
                    Container(height: 2, color: Colors.green),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  galleryTabIndex = 1;
                });
              },
              child: Column(
                children: [
                  Text(
                    "Videos",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: galleryTabIndex == 1 ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (galleryTabIndex == 1)
                    Container(height: 2, color: Colors.green),
                ],
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 10),

      /// Gallery Content
      Expanded(
        child: galleryTabIndex == 0
            ? GridView.builder(
                padding: const EdgeInsets.all(4),
                itemCount: photos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  final imageUrl = photos[index].image;
                  final url = imageUrl.startsWith('http') 
                      ? imageUrl 
                      : 'https://dev.gobuddyindia.com/$imageUrl';

                  return Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SkeletonLoader(
                        height: 100,
                        width: 100,
                        radius: 8,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image),
                        ),
                      );
                    },
                  );
                },
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 200,
                    child: const SkeletonLoader(
                      height: 200,
                      width: double.infinity,
                      radius: 12,
                    ),
                  );
                },
              ),
      ),
    ],
  );
}
Widget _buildPhotosGrid(List<GalleryItem>? gallery) {

  /// SHOW SKELETON WHILE API IS LOADING
  if (gallery == null) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return const SkeletonLoader(
          height: 100,
          width: 100,
          radius: 8,
        );
      },
    );
  }

  final photos =
      gallery.where((item) => !item.image.endsWith(".mp4")).toList();

  if (photos.isEmpty) {
    return const Center(
      child: Text("No photos available"),
    );
  }

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
    ),
    itemCount: photos.length,
    itemBuilder: (context, index) {
      final imageUrl = photos[index].image;
      final url = imageUrl.startsWith('http') 
          ? imageUrl 
          : 'https://dev.gobuddyindia.com/$imageUrl';

      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          url,
          fit: BoxFit.cover,

          /// IMAGE LOADING SKELETON
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;

            return const SkeletonLoader(
              height: 100,
              width: 100,
              radius: 6,
            );
          },

          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image),
              ),
            );
          },
        ),
      );
    },
  );
}
Widget _buildVideosContent(List<GalleryItem> gallery) {
  final videos = gallery.where((item) => item.image.endsWith(".mp4")).toList();
  if (videos.isEmpty) return const Center(child: Text("No videos available"));

  return Column(
    children: videos.map((videoItem) {
      final imageUrl = videoItem.image;
      final videoUrl = imageUrl.startsWith('http') 
          ? imageUrl 
          : 'https://dev.gobuddyindia.com/$imageUrl';
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: 200,
        color: Colors.black12,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black12,
              ),
            ),
            Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.green,
                size: 50,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

Widget _buildReviewsTab(List<Review>? reviewsData) {

  /// SHOW SKELETON WHILE API IS LOADING
  if (reviewsData == null) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 20),

        /// Rating Skeleton
        const Center(
          child: SkeletonLoader(height: 32, width: 60),
        ),
        const SizedBox(height: 10),

        const Center(
          child: SkeletonLoader(height: 20, width: 150),
        ),

        const SizedBox(height: 20),

        /// Rating Distribution Skeleton
        const SkeletonLoader(height: 12, width: double.infinity),
        const SizedBox(height: 10),
        const SkeletonLoader(height: 12, width: double.infinity),
        const SizedBox(height: 10),
        const SkeletonLoader(height: 12, width: double.infinity),

        const SizedBox(height: 20),

        /// Review Cards Skeleton
        const SkeletonLoader(height: 70, width: double.infinity, radius: 8),
        const SizedBox(height: 12),
        const SkeletonLoader(height: 70, width: double.infinity, radius: 8),
        const SizedBox(height: 12),
        const SkeletonLoader(height: 70, width: double.infinity, radius: 8),
      ],
    );
  }

  final double rating = (onlyproviderDetails?.rating != null && onlyproviderDetails!.rating > 0)
      ? onlyproviderDetails!.rating.toDouble()
      : (passedRating ?? 0.0);
  final int reviewCount = int.tryParse(onlyproviderDetails?.reviewCount ?? passedReviews ?? '0') ?? 0;
  final List<Review> reviews = pushReviews;

  if (reviews.isEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (rating > 0) ...[
          const SizedBox(height: 20),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < rating.floor()
                    ? Icons.star
                    : (index < rating ? Icons.star_half : Icons.star_border),
                color: Colors.amber,
                size: 24,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            "Overall Rating ($reviewCount reviews)",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
        ],
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              "No reviews available yet for this provider",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }

  final Map<String, dynamic> ratingDistribution = {
    'excellent': 0.8,
    'good': 0.6,
    'average': 0.3,
    'belowAverage': 0.1,
    'poor': 0.05,
  };

  /// HEADER
  Widget header = Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const SizedBox(height: 16),
      Text(
        rating.toStringAsFixed(1),
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return Icon(
            index < rating.floor()
                ? Icons.star
                : (index < rating ? Icons.star_half : Icons.star_border),
            color: Colors.amber,
            size: 28,
          );
        }),
      ),

      const SizedBox(height: 8),

      Text(
        "Based on all reviews (${_formatNumber(reviewCount)} Reviews)",
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),

      const SizedBox(height: 16),

      _buildRatingRow("Excellent", Colors.green,
          ratingDistribution['excellent'] ?? 0),
      _buildRatingRow(
          "Good", Colors.lightGreen, ratingDistribution['good'] ?? 0),
      _buildRatingRow(
          "Average", Colors.yellow, ratingDistribution['average'] ?? 0),
      _buildRatingRow("Below Average", Colors.orange,
          ratingDistribution['belowAverage'] ?? 0),
      _buildRatingRow(
          "Poor", Colors.red, ratingDistribution['poor'] ?? 0),

      const SizedBox(height: 20),
    ],
  );

  /// REVIEW TILE
  Widget buildReviewTile(Review review) {
    final profileUrl =
        (review.profile != null && review.profile.isNotEmpty)
            ? (review.profile.startsWith('http')
                ? review.profile
                : 'https://dev.gobuddyindia.com/${review.profile}')
            : 'assets/images/placeholder.png';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: profileUrl.startsWith('http')
                ? NetworkImage(profileUrl)
                : AssetImage(profileUrl) as ImageProvider,
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.name ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Row(
                  children: List.generate(
                    5,
                    (starIndex) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  review.comments ?? '',
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  return ListView(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    children: [
      header,
      ...reviews.map(buildReviewTile).toList(),
      const SizedBox(height: 16),
    ],
  );
}
  Widget _buildRatingRow(String label, Color color, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percent,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildReviewItem(
  String image,
  String name,
  double rating,
  String timeAgo,
  String review, {
  bool isLoading = false,
}) {
  /// SKELETON STATE
  if (isLoading) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(height: 40, width: 40, radius: 20),
          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(height: 14, width: 120),
                SizedBox(height: 6),
                SkeletonLoader(height: 12, width: 80),
                SizedBox(height: 6),
                SkeletonLoader(height: 12, width: double.infinity),
                SizedBox(height: 4),
                SkeletonLoader(height: 12, width: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// NORMAL REVIEW ITEM
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(image),
          radius: 20,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    timeAgo,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating.floor()
                            ? Icons.star
                            : (index < rating
                                ? Icons.star_half
                                : Icons.star_border),
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),

                  const SizedBox(width: 4),

                  Text(
                    "($rating)",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                review,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ),
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