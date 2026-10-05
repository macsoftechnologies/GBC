import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/models/new_search_model.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/session_manager.dart';
import '../../utils/config.dart';

class SearchServicesScreenNew extends StatefulWidget {
  const SearchServicesScreenNew({super.key});

  @override
  State<SearchServicesScreenNew> createState() => _SearchAddServicesScreenState();
}

class _SearchAddServicesScreenState extends State<SearchServicesScreenNew> {
  List<Map<String, dynamic>> _services = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args?.containsKey('subServices') ?? false) {
        final List<ServicesforSearch> subServices = args?['subServices'] ?? [];

        _services = subServices.map((sub) {
  String imageUrl = '';

  if (sub.serviceImage != null && sub.serviceImage!.isNotEmpty) {
    // Remove spaces or illegal chars in the URL
    String cleanedImage = sub.serviceImage!.replaceAll(' ', '');

    // Check if it starts with http (complete URL)
    if (cleanedImage.startsWith('http')) {
      imageUrl = cleanedImage;
    } else {
      // Append to base URL if relative path or corrupted
      imageUrl = "https://dev.gobuddyindia.com/assets/images/${sub.serviceImage}";
    }
  }

  return {
    "id": sub.id,
    "title": sub.title,
    "image": imageUrl,
    "rating": "4.7 ",
    "time": "1 hr approx",
    "quantity": 0,
    "price": sub.price,
    "description": sub.note ?? "",
    "note": sub.note ?? "",
    "presponsibility": sub.presponsibility ?? "",
    "cresponsibility": sub.cresponsibility ?? "",
    "location_name": sub.locationName ?? "",
    "sub_services": sub.subServices ?? "",
  };
}).toList();


        _initialized = true;
        setState(() {});
      }
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
        updateServiceQuantity(id, (service['quantity'] ?? 0) + 1);
        break;
      }
    }
  }

  void decrementQuantity(String id) {
    for (var service in _services) {
      if (service['id'] == id) {
        int qty = service['quantity'] ?? 0;
        if (qty > 0) updateServiceQuantity(id, qty - 1);
        break;
      }
    }
  }

  List<Map<String, dynamic>> getSelectedServices() =>
      _services.where((s) => s['quantity'] > 0).toList();

  void _navigateToNextScreen() async {
    final selected = getSelectedServices();
    if (selected.isEmpty) return;

    final userId = await SessionManager.getUserId() ?? "";

    final formattedServices = selected.map((s) {
      return {
        "id": s['id'],
        "title": s['title'],
        "time": s['time'] ?? "1 hr approx",
        "service_image": s['image'] ?? "",
        "average_rating": s['rating'] ?? "4.7",
        "total_reviews": "0",
        "bookings": "0",
        "service_price": s['price'],
        "quantity": s['quantity'],
        "main_category_id": "1",
      };
    }).toList();

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      Config.serviceDateandTimeScreen,
      arguments: {
        'sendingServices': formattedServices,
        'user_id': userId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final cardAspectRatio = isSmallScreen ? 0.6 : 0.65;
    final selectedServices = getSelectedServices();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
        backgroundColor: MyColors.appThemeLight,
      ),
      backgroundColor: const Color(0xFFF5F9F6),
      body: Column(
        children: [
          _buildHeader(),
          _buildStatsRow(isSmallScreen),
          Expanded(
            child: _services.isEmpty
                ? _buildNoServicesAvailable()
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _services.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 14,
                      childAspectRatio: cardAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final s = _services[index];
                      return _buildServiceCard(
                        service: s,
                        imageHeight: 140,
                        onIncrement: () => incrementQuantity(s['id']),
                        onDecrement: () => decrementQuantity(s['id']),
                      );
                    },
                  ),
          ),
          if (selectedServices.isNotEmpty)
            _buildBottomBar(context, selectedServices),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
              child: Image.asset("assets/images/whiteLeftArrow.png", width: 9),
            ),
          ),
          SizedBox(width: 10,),
          const Text(
            "Choose Services",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isSmallScreen) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: isSmallScreen ? 8 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("${_services.length} Services",
              style: TextStyle(color: Colors.black54, fontSize: isSmallScreen ? 12 : 14)),
          Row(
            children: [
              Icon(Icons.people, size: isSmallScreen ? 14 : 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text("95", style: TextStyle(color: Colors.black54, fontSize: isSmallScreen ? 12 : 14)),
            ],
          ),
          Flexible(
            child: Row(
              children: [
                Icon(Icons.star, size: isSmallScreen ? 14 : 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text("4.7 ( 100k Bookings )",
                    style: TextStyle(color: Colors.black54, fontSize: isSmallScreen ? 10 : 12),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildServiceCard({
    required Map<String, dynamic> service,
    required double imageHeight,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final quantity = service['quantity'] ?? 0;
    final isAdded = quantity > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    ClipRRect(
  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
  child: Image.network(
    service['image'] ?? '',
    width: double.infinity,
    height: imageHeight,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        width: double.infinity,
        height: imageHeight,
        color: const Color(0xFFE8F5E9),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/logoImg.png',
          height: 40,
          fit: BoxFit.contain,
        ),
      );
    },
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
        ),
      );
    },
  ),
),

          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              Config.serviceDetailsRouteName,
              arguments: {
                "service_id": service['id']?.toString() ?? '',
                "serviceData": service,
              },
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(service['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: isSmallScreen ? 13 : 14)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 14),
                const SizedBox(width: 1),
                Expanded(
                  child: Text(service['rating'],
                      style: TextStyle(fontSize: isSmallScreen ? 10 : 12), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey, size: 14),
                const SizedBox(width: 2),
                Text(service['time'], style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: Colors.grey)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                Config.serviceDetailsRouteName,
                arguments: {
                  "service_id": service['id']?.toString() ?? '',
                  "serviceData": service,
                },
              ),
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
          const SizedBox(height: 2),
          Center(
            child: GestureDetector(
              onTap: () {
                if (!isAdded) onIncrement();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: 85,
                height: 25,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1EB35B)),
                  borderRadius: BorderRadius.circular(20),
                  color: isAdded ? const Color(0xFF1EB35B) : Colors.white,
                ),
                child: Center(
                  child: isAdded
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                                onTap: onDecrement,
                                child: Icon(Icons.remove,
                                    size: isSmallScreen ? 12 : 14, color: Colors.white)),
                            const SizedBox(width: 4),
                            Text("$quantity",
                                style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 12 : 14)),
                            const SizedBox(width: 4),
                            GestureDetector(
                                onTap: onIncrement,
                                child: Icon(Icons.add,
                                    size: isSmallScreen ? 12 : 14, color: Colors.white)),
                          ],
                        )
                      : Text("Add",
                          style: TextStyle(
                              color: MyColors.appThemeLight,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 12 : 14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, List<Map<String, dynamic>> selectedServices) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...selectedServices.map((s) => Text("${s['title']} (${s['quantity']})",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.grey))),

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
              onPressed: _navigateToNextScreen,
              child: const Text(
                "Pick a Schedule",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
