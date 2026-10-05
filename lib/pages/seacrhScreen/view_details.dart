import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/pages/services/add_services_to_cart.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
class ViewDetailsScreen extends StatefulWidget{
  const ViewDetailsScreen({super.key});

  @override
  State<ViewDetailsScreen> createState()=> _ViewDetailsScreenState();
}


class _ViewDetailsScreenState extends State<ViewDetailsScreen> with SingleTickerProviderStateMixin {
 late Map<String, dynamic> serviceData;
   late TabController _tabController;
  int _itemCount = 0;


@override
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this); // adjust length as needed
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


 @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Map<String, dynamic>) {
      serviceData = args;
    } else {
      // Handle error or fallback
     
    }
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
            _buildServiceImage(width),

            // Title, Rating and Add Button
            _buildServiceHeader(context),

            const Divider(
              color: Colors.grey,
              thickness: 0.3,
              indent: 17,
              endIndent: 17,
            ),

            // About the service section
            _buildAboutSection(),

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
            _buildRatingSection(),

            // Tabs: Photos / Videos
            _buildMediaTabsSection(),

            // Reviews section
            _buildReviewsSection(),
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
                backgroundColor: const Color.fromARGB(255, 243, 236, 236),
                child: Icon(Icons.arrow_back)
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

  Widget _buildServiceImage(double width) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: width * 0.045,
        vertical: 14.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        image: DecorationImage(
          image: AssetImage(serviceData['image'] ?? 'https://media.istockphoto.com/id/517188688/photo/mountain-landscape.jpg?s=612x612&w=0&k=20&c=A63koPKaCyIwQWOTFBRWXj_PwCrR4cEoOw2S9Q7yVl8='),
          fit: BoxFit.cover,
        ),
      ),
      height: 180,
      width: double.infinity,
    );
  }

  Widget _buildServiceHeader(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceData['title'] ?? "Split AC Installation",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 15 : 16,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      serviceData['rating'] ?? "4.8 (120k reviews)",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      serviceData['duration'] ?? "2 hr 30 min",
                      style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.people, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      serviceData['bookings'] ?? "100k Bookings",
                      style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Add Button
          GestureDetector(
            onTap: () {
              setState(() {
                _itemCount++;
              });
              final String serviceType = serviceData['serviceType'] ?? 'split_ac';
              final String serviceTitle = serviceData['title'] ?? 'Split AC Installation';

            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: MyColors.appThemeLight),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Add",
                style: TextStyle(
                  color: MyColors.appThemeLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            "About the service",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            serviceData['description'] ??
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
                    "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,",
            style: const TextStyle(color: Colors.black38, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildIncludedSection() {
    final List<String> includedItems = List<String>.from(
        serviceData['included'] ?? [
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
        ]
    );

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
        ...includedItems.map((item) =>
            _buildInfoRow(Icons.check_circle, Colors.green, item)
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    final List<String> notes = List<String>.from(
        serviceData['notes'] ?? [
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
        ]
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            "Please Note",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        ...notes.map((note) =>
            _buildInfoRow(Icons.info, Colors.orange, note)
        ),
      ],
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

  Widget _buildRatingSection() {
    final double rating = serviceData['ratingValue'] is double
        ? serviceData['ratingValue']
        : 4.8;
    final int reviewCount = serviceData['reviewCount'] is int
        ? serviceData['reviewCount']
        : 120000;

    return Column(
      children: [
        // Rating Large
        Center(
          child: Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),

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

        // Review count
        Center(
          child: Text(
            "Based on all reviews (${_formatNumber(reviewCount)} Reviews)",
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaTabsSection() {
    final List<String> photos = List<String>.from(
        serviceData['photos'] ?? [
          'https://media.istockphoto.com/id/517188688/photo/mountain-landscape.jpg?s=612x612&w=0&k=20&c=A63koPKaCyIwQWOTFBRWXj_PwCrR4cEoOw2S9Q7yVl8=',
          'https://media.istockphoto.com/id/517188688/photo/mountain-landscape.jpg?s=612x612&w=0&k=20&c=A63koPKaCyIwQWOTFBRWXj_PwCrR4cEoOw2S9Q7yVl8=',
          'https://media.istockphoto.com/id/517188688/photo/mountain-landscape.jpg?s=612x612&w=0&k=20&c=A63koPKaCyIwQWOTFBRWXj_PwCrR4cEoOw2S9Q7yVl8='
        ]
    );

    final List<String> videos = List<String>.from(
        serviceData['videos'] ?? []
    );

    return Column(
      children: [
        const SizedBox(height: 16),

        // Tabs: Photos / Videos
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
              // Photos Tab
              ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                children: photos.map((photo) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Image.asset(
                      photo,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),

              // Videos Tab
              videos.isEmpty
                  ? const Center(child: Text("No videos available"))
                  : ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                children: videos.map((video) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Image.asset(
                      video,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    final List<dynamic> reviews = serviceData['reviews'] ?? [
      {
        "name": "Viswak Varma",
        "time": "2 days ago",
        "rating": 4.5,
        "image": "assets/images/man.jpg",
        "comment": "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,"
      },
      {
        "name": "Pradeep Ranga",
        "time": "3 days ago",
        "rating": 4.5,
        "image": "assets/images/man.jpg",
        "comment": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
      }
    ];

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

        ...reviews.map((review) {
          return Column(
            children: [
              _buildReviewTile(
                name: review['name'],
                time: review['time'],
                rating: review['rating'] is double ? review['rating'] : 4.5,
                image: review['image'],
                comment: review['comment'],
              ),
              const Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 17,
                endIndent: 17,
              ),
            ],
          );
        }),
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
          CircleAvatar(radius: 20, backgroundImage: AssetImage(image)),
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