
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';

// class GoogleMapScreen extends StatefulWidget {
//   const GoogleMapScreen({super.key});

//   @override
//   _GoogleMapScreenState createState() => _GoogleMapScreenState();
// }

// class _GoogleMapScreenState extends State<GoogleMapScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   late GoogleMapController _mapController;

//   static const LatLng _initialPosition = LatLng(37.7749, -122.4194); // San Francisco
//   Marker? _marker;


   
// Future<Position> _determinePosition() async {
//   bool serviceEnabled;
//   LocationPermission permission;

//   // Check if location services are enabled
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     throw Exception('Location services are disabled.');
//   }

//   // Check for permissions
//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       throw Exception('Location permissions are denied');
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     throw Exception(
//       'Location permissions are permanently denied.',
//     );
//   }

//   // If permissions granted, return the position
//   return await Geolocator.getCurrentPosition(
//     desiredAccuracy: LocationAccuracy.high,
//   );
// }


//   /// Get current location and move camera
//   Future<void> _goToCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         return Future.error('Location services are disabled.');
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           return Future.error('Location permissions are denied');
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         return Future.error('Location permissions are permanently denied.');
//       }

//       Position position = await Geolocator.getCurrentPosition();
//       _moveToLocation(position.latitude, position.longitude);
//     } catch (e) {
//       print("Error getting current location: $e");
//     }
//   }

//   /// Move map camera and update marker
//   Future<void> _moveToLocation(double latitude, double longitude) async {
//     final LatLng target = LatLng(latitude, longitude);

//     _mapController.animateCamera(CameraUpdate.newLatLngZoom(target, 15));

//     List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
//     String placeName = placemarks.isNotEmpty
//         ? "${placemarks.first.name}, ${placemarks.first.locality}"
//         : "Unknown";

//     print("📍 Latitude: $latitude");
//     print("📍 Longitude: $longitude");
//     print("📍 Address: $placeName");

//     setState(() {
//       _marker = Marker(
//         markerId: const MarkerId("location_marker"),
//         position: target,
//         infoWindow: InfoWindow(title: placeName),
//         draggable: false,
//       );
//     });
//   }

//   /// Search location by address
//   Future<void> _searchLocation(String query) async {
//     try {
//       List<Location> locations = await locationFromAddress(query);
//       if (locations.isNotEmpty) {
//         final loc = locations.first;
//         _moveToLocation(loc.latitude, loc.longitude);
//       } else {
//         print("No location found for: $query");
//       }
//     } catch (e) {
//       print("Error searching location: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final deviceWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(160),
//         child: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           automaticallyImplyLeading: false,
//           flexibleSpace: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//               child: Column(
//                 children: [
//                   // Search Bar
//                   Container(
//                     height: 55,
//                     width: deviceWidth * 0.95,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.arrow_back, color: Colors.black),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                         Expanded(
//                           child: TextField(
//                             controller: _searchController,
//                             decoration: const InputDecoration(
//                               hintText: "Search for your location",
//                               border: InputBorder.none,
//                             ),
//                             style: const TextStyle(fontSize: 14),
//                             onSubmitted: _searchLocation,
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.search, color: Colors.black),
//                           onPressed: () {
//                             _searchLocation(_searchController.text);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),

//                   // Use Current Location Button
//                   Container(
//                     height: 55,
//                     width: deviceWidth * 0.95,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.grey.shade300),
//                     ),
//                     child: InkWell(
//                       onTap: _goToCurrentLocation,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           children: const [
//                             Icon(Icons.my_location, color: Colors.green),
//                             SizedBox(width: 8),
//                             Text(
//                               'Use Current Location',
//                               style: TextStyle(
//                                 color: Colors.green,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),

//       // Google Map
//       body: GoogleMap(
//         initialCameraPosition: const CameraPosition(
//           target: _initialPosition,
//           zoom: 12,
//         ),
//         onMapCreated: (controller) {
//           _mapController = controller;
//         },
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//         markers: _marker != null ? {_marker!} : {},
//       ),
//     );
//   }
// }


 import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  static const LatLng _defaultLatLng = LatLng(37.7749, -122.4194); // Fallback
  Marker? _marker;

  double? _incomingLat;
  double? _incomingLng;
  String? _incomingAddress;

  bool _initialLocationSet = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    if (args != null && !_initialLocationSet) {
      _incomingLat = args['latitude'];
      _incomingLng = args['longitude'];
      _incomingAddress = args['address'];
      _initialLocationSet = true;

      // Show marker at incoming location after map loads
      if (_incomingLat != null && _incomingLng != null) {
        Future.delayed(Duration.zero, () {
          _moveToLocation(_incomingLat!, _incomingLng!, _incomingAddress ?? "");
        });
      }
    }
  }

  Future<void> _moveToLocation(double lat, double lng, String? name) async {
    LatLng target = LatLng(lat, lng);

    _mapController.animateCamera(CameraUpdate.newLatLngZoom(target, 15));

    setState(() {
      _marker = Marker(
        markerId: const MarkerId("selected_location"),
        position: target,
        infoWindow: InfoWindow(title: name ?? "Selected Location"),
      );
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 7),
      );
    } catch (e) {
      print("getCurrentPosition timed out or failed: $e, trying last known position...");
      Position? lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        return lastPosition;
      }
      rethrow;
    }
  }

  Future<void> _handleCurrentLocation() async {
    UtilClass.showProgress(context: context);
    try {
      Position position = await _determinePosition();
      double lat = position.latitude;
      double lng = position.longitude;

      String address = "Lat: $lat, Lng: $lng";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [p.name, p.subLocality, p.locality, p.administrativeArea, p.postalCode, p.country]
              .where((s) => s != null && s.isNotEmpty)
              .toSet()
              .toList();
          if (parts.isNotEmpty) {
            address = parts.join(", ");
          }
        }
      } catch (geoError) {
        print("Geocoding reverse lookup error: $geoError");
      }

      UtilClass.hideProgress();

      _incomingLat = lat;
      _incomingLng = lng;
      await _moveToLocation(lat, lng, address);

      bool confirmed = await _showConfirmationDialog(lat, lng, address);
      if (confirmed) {
        Navigator.pop(context, {
          'latitude': lat,
          'longitude': lng,    
          'address': address,
        });
      }
    } catch (e) {
      UtilClass.hideProgress();
      print("Error fetching current location: $e");
      UtilClass.showAlertDialog(context: context, message: "Unable to fetch current location.");
    }
  }

  Future<void> _handleSearch(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        double lat = locations.first.latitude;
        double lng = locations.first.longitude;

        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        String address = placemarks.isNotEmpty
            ? "${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}"
            : "Searched Location";

        // Update state variables here to keep current location updated
        setState(() {
          _incomingLat = lat;
          _incomingLng = lng;
          _incomingAddress = address;
        });

        await _moveToLocation(lat, lng, address);

        bool confirmed = await _showConfirmationDialog(lat, lng, address);
        if (confirmed) {
          Navigator.pop(context, {
            'latitude': lat,
            'longitude': lng,
            'address': address,
          });
        }
      } else {
        UtilClass.showAlertDialog(context: context, message: "No location found for: $query");
      }
    } catch (e) {
      print("Search error: $e");
      UtilClass.showAlertDialog(context: context, message: "Error occurred while searching.");
    }
  }

  Future<bool> _showConfirmationDialog(double lat, double lng, String address) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Confirm Location"),
            content: Text("📍 Address: $address\n\nLatitude: $lat\nLongitude: $lng"),
            actions: [
              TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context, false)),
              ElevatedButton(child: const Text("Confirm"), onPressed: () => Navigator.pop(context, true)),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _onMapTapped(LatLng position) async {
    double lat = position.latitude;
    double lng = position.longitude;
    String address = "Selected Location";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address = "${p.street ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}, ${p.postalCode ?? ''}, ${p.country ?? ''}"
            .replaceAll(RegExp(r'^[,\s]+|[,\s]+$'), '')
            .replaceAll(RegExp(r',\s*,'), ',');
      }
    } catch (_) {}
    setState(() {
      _incomingLat = lat;
      _incomingLng = lng;
      _incomingAddress = address;
      _searchController.text = address;
    });
    await _moveToLocation(lat, lng, address);
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // Disable automatic back button to avoid duplicate
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    height: 50,
                    width: deviceWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search for your location',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                            ),
                            onSubmitted: _handleSearch,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.black),
                          onPressed: () {
                            _handleSearch(_searchController.text);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Use Current Location
                  GestureDetector(
                    onTap: _handleCurrentLocation,
                    child: Container(
                      height: 50,
                      width: deviceWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: const [
                          Icon(Icons.my_location, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            "Use Current Location",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),

      // Google Map
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _incomingLat != null && _incomingLng != null
              ? LatLng(_incomingLat!, _incomingLng!)
              : _defaultLatLng,
          zoom: 14,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        onTap: _onMapTapped,
        markers: _marker != null ? {_marker!} : {},
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.appThemeLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, {
                  'latitude': _incomingLat ?? _defaultLatLng.latitude,
                  'longitude': _incomingLng ?? _defaultLatLng.longitude,
                  'address': _incomingAddress ?? _searchController.text.trim(),
                });
              },
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                "Confirm Location",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
