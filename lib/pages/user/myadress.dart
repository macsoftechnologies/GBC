import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gobuddy_customer_app/models/home_userDetails_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';

class MyAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final String? initialAddress;
  final String? initialLocation;
  final String? initialLandmark;

  const MyAddressScreen({
    super.key,
    required this.userData,
    this.initialAddress,
    this.initialLocation,
    this.initialLandmark,
  });

  @override
  State<MyAddressScreen> createState() => _MyAddressScreenState();
}

class _MyAddressScreenState extends State<MyAddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDetectingLocation = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.initialAddress ?? "";
    _landmarkController.text = widget.initialLandmark ?? "";
    _locationController.text = widget.initialLocation ?? "";
    _fetchAddressDetails();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAddressDetails() async {
    final uid = widget.userData?['user_id'];
    if (uid == null) return;

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> data = await Repository.NewPostApiService(
        EndPoints.userprofileDetails,
        {'id': uid.toString()},
      );

      if (data['status'] == 'valid' && data['customer_details'] != null) {
        final details = CustomerDetails.fromJson(
          Map<String, dynamic>.from(data['customer_details']),
        );
        setState(() {
          if (_addressController.text.isEmpty) {
            _addressController.text = details.address ?? "";
          }
          if (_landmarkController.text.isEmpty) {
            _landmarkController.text = details.landmark ?? "";
          }
          if (_locationController.text.isEmpty) {
            _locationController.text = details.location ?? "";
          }
          if (details.latitude != null) {
            _latitude = details.latitude;
          }
          if (details.longitude != null) {
            _longitude = details.longitude;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching address details: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _detectCurrentLocation() async {
    setState(() => _isDetectingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          UtilClass.showAlertDialog(
            context: context,
            message: "Location permission permanently denied. Enable it in settings.",
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final street = p.street ?? '';
        final subLocality = p.subLocality ?? '';
        final locality = p.locality ?? '';
        final state = p.administrativeArea ?? '';
        final postal = p.postalCode ?? '';

        final fullAddr = "$street, $subLocality, $locality, $state $postal".trim();

        setState(() {
          _addressController.text = fullAddr;
          _locationController.text = locality.isNotEmpty ? locality : subLocality;
          if (_landmarkController.text.isEmpty) {
            _landmarkController.text = subLocality;
          }
        });
      }
    } catch (e) {
      debugPrint("Error detecting location: $e");
      if (mounted) {
        UtilClass.showAlertDialog(
          context: context,
          message: "Could not fetch current location: $e",
        );
      }
    } finally {
      if (mounted) setState(() => _isDetectingLocation = false);
    }
  }

  Future<void> _saveAddress() async {
    final addressText = _addressController.text.trim();
    if (addressText.isEmpty) {
      UtilClass.showAlertDialog(
        context: context,
        message: "Please enter your address.",
      );
      return;
    }

    final uid = widget.userData?['user_id'];
    if (uid == null) {
      UtilClass.showAlertDialog(
        context: context,
        message: "User session not found. Please log in again.",
      );
      return;
    }

    if (!await UtilClass.checkInternet()) {
      if (mounted) {
        UtilClass.showAlertDialog(
          context: context,
          message: "No internet connection.",
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    final params = {
      "user_id": uid.toString(),
      "address": addressText,
      "latitude": _latitude?.toString() ?? "",
      "longitude": _longitude?.toString() ?? "",
      "place_id": "",
      "landmark": _landmarkController.text.trim(),
      "location": _locationController.text.trim(),
    };

    try {
      final Map<String, dynamic> res = await Repository.NewPostApiService(
        EndPoints.getUpdateAddress,
        params,
      );

      if (res['status'] == 'valid' || res['status'] == 'success') {
        if (mounted) {
          UtilClass.showAlertDialog(
            context: context,
            message: res['message'] ?? "Address updated successfully.",
            onOkClick: () {
              Navigator.pop(context, true);
            },
          );
        }
      } else {
        final msg = res['message'] ?? "Failed to update address.";
        if (mounted) {
          UtilClass.showAlertDialog(context: context, message: msg);
        }
      }
    } catch (e) {
      debugPrint("Error saving address: $e");
      if (mounted) {
        UtilClass.showAlertDialog(
          context: context,
          message: "Something went wrong. Please try again.",
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: MyColors.appThemeLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Manage Address",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GPS Detect Button Card
                  InkWell(
                    onTap: _isDetectingLocation ? null : _detectCurrentLocation,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.my_location, color: Color(0xFF00A651)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Use Current Location",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Automatically fill address using GPS",
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          if (_isDetectingLocation)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Address Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Address Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Full Address Field
                        const Text(
                          "Street Address",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _addressController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "e.g. Flat 402, Green Meadows Apartment",
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 40),
                              child: Icon(Icons.home_outlined),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF00A651), width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Landmark Field
                        const Text(
                          "Landmark",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _landmarkController,
                          decoration: InputDecoration(
                            hintText: "e.g. Near City Hospital",
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.place_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF00A651), width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Location / City Field
                        const Text(
                          "City / Area",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            hintText: "e.g. Madhapur, Hyderabad",
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.location_city_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF00A651), width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A651),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      onPressed: _isSaving ? null : _saveAddress,
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "Save Address",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
