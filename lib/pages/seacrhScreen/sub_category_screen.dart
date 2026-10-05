import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import '../../utils/config.dart';

class SearchAddServicesScreen extends StatefulWidget {
  const SearchAddServicesScreen({super.key});

  @override
  State<SearchAddServicesScreen> createState() => _SearchAddServicesScreenState();
}

class _SearchAddServicesScreenState extends State<SearchAddServicesScreen> {
  List<Map<String, dynamic>> _services = [];

  @override
  void initState() {
    super.initState();
    _services = List.from(services);
  }

  // Sample services data
  List<Map<String, dynamic>> get services => [
        {
          "id": "1",
          "title": "Split AC Installation",
          "image": "assets/images/ACInstallation.jpg",
          "rating": "4.8 (120k reviews)",
          "time": "2 hr 30 min",
          "quantity": 0,
          "price": 1499,
          "description": "Professional installation of split AC units with proper mounting and testing"
        },
        {
          "id": "2",
          "title": "Dry Servicing a Split AC",
          "image": "assets/images/DryAcCleaning.jpg",
          "rating": "4.7 (100k reviews)",
          "time": "1 hr 30 min",
          "quantity": 0,
          "price": 899,
          "description": "Dry cleaning service for split AC units without water usage"
        },
        {
          "id": "3",
          "title": "Jet Servicing of Split AC",
          "image": "assets/images/ACJetServicing.jpg",
          "rating": "4.6 (95k reviews)",
          "time": "1 hr 30 min",
          "quantity": 0,
          "price": 1299,
          "description": "High-pressure jet cleaning for thorough AC servicing"
        },
        {
          "id": "4",
          "title": "AC Repair Visit",
          "image": "assets/images/acRepair.png",
          "rating": "4.7 (89k reviews)",
          "time": "1 hr 15 min",
          "quantity": 0,
          "price": 499,
          "description": "Expert technician visit for AC repair and troubleshooting"
        },
        {
          "id": "5",
          "title": "Window AC Installation",
          "image": "assets/images/windowACInstallation.jpg",
          "rating": "4.7 (85k reviews)",
          "time": "2 hr 15 min",
          "quantity": 0,
          "price": 1299,
          "description": "Professional installation of window AC units"
        },
        {
          "id": "6",
          "title": "Window AC Servicing",
          "image": "assets/images/windowACService.jpg",
          "rating": "4.6 (78k reviews)",
          "time": "1 hr 45 min",
          "quantity": 0,
          "price": 799,
          "description": "Complete servicing for window AC units"
        },
        {
          "id": "7",
          "title": "Cassette AC Installation",
          "image": "assets/images/cassetteACInstallation.jpg",
          "rating": "4.8 (65k reviews)",
          "time": "3 hr 30 min",
          "quantity": 0,
          "price": 2499,
          "description": "Professional installation of cassette AC units"
        },
        {
          "id": "8",
          "title": "Cassette AC Maintenance",
          "image": "assets/images/cassetteACMaintenance.jpg",
          "rating": "4.7 (58k reviews)",
          "time": "2 hr 15 min",
          "quantity": 0,
          "price": 1499,
          "description": "Complete maintenance for cassette AC units"
        },
        {
          "id": "9",
          "title": "Tower AC Installation",
          "image": "assets/images/towerACInstallation.jpg",
          "rating": "4.6 (42k reviews)",
          "time": "3 hr 45 min",
          "quantity": 0,
          "price": 2999,
          "description": "Professional installation of tower AC units"
        },
        {
          "id": "10",
          "title": "Tower AC Repair",
          "image": "assets/images/towerACRepair.jpg",
          "rating": "4.5 (35k reviews)",
          "time": "2 hr 30 min",
          "quantity": 0,
          "price": 1699,
          "description": "Expert repair service for tower AC units"
        }
      ];

  // Update quantity
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

  void _navigateToNextScreen() {
    final selected = getSelectedServices();
    Navigator.pushNamed(context, Config.selectProviderVisitDateRouteName, arguments: {
      "serviceType": "service_type",
      "serviceTitle": "service_title",
      "services": selected,
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final cardAspectRatio = isSmallScreen ? 0.6 : 0.65;
    final imageHeight = isSmallScreen ? 90 : 100;
    final selectedServices = getSelectedServices();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      body: SafeArea(
        child: Column(
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
                          imageHeight: 400,
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
          Expanded(
            child: Center(
              child: Text(
                "This is Service Tile",
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
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
            child: Image.asset(service['image'], width: double.infinity, height: imageHeight, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(service['title'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: isSmallScreen ? 13 : 14)),
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
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: isSmallScreen ? 11 : 12),
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
                            GestureDetector(onTap: onDecrement, child: Icon(Icons.remove, size: isSmallScreen ? 12 : 14, color: Colors.white)),
                            const SizedBox(width: 4),
                            Text("$quantity", style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 12 : 14)),
                            const SizedBox(width: 4),
                            GestureDetector(onTap: onIncrement, child: Icon(Icons.add, size: isSmallScreen ? 12 : 14, color: Colors.white)),
                          ],
                        )
                      : Text("Add", style: TextStyle(color: MyColors.appThemeLight, fontWeight: FontWeight.w600, fontSize: isSmallScreen ? 12 : 14)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
