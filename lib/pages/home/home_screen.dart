import 'package:gobuddy_customer_app/data/prefernces.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gobuddy_customer_app/models/advertisments_model.dart';
import 'package:gobuddy_customer_app/models/banners_model.dart';
import 'package:gobuddy_customer_app/models/getupdateaddress_model.dart';
import 'package:gobuddy_customer_app/models/head_category.dart';
import 'package:gobuddy_customer_app/models/home_userDetails_model.dart';
import 'package:gobuddy_customer_app/models/homescreen_details_model.dart';
import 'package:gobuddy_customer_app/models/new_search_model.dart';
import 'package:gobuddy_customer_app/pages/bookings/my_bookings_screen1.dart';
import 'package:gobuddy_customer_app/pages/subscription/subscription_screen.dart';
import 'package:gobuddy_customer_app/pages/user/user_profile.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/session_manager.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/my_colors.dart';
import '../../../utils/config.dart';
import 'package:gobuddy_customer_app/components/customer_profile_avatar.dart';

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({super.key});

  @override
  State<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen>
    with AutomaticKeepAliveClientMixin {
  // ─── Keep alive so tab switches don't rebuild ───────────────────────────────
  @override
  bool get wantKeepAlive => true;
  Timer? _sessionCheckTimer;
  bool _isForcingLogout = false;

  // ─── State ──────────────────────────────────────────────────────────────────
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  int _currentBannerIndex = 0;
  DateTime? _lastBackPressed;
  Map<String, dynamic>? userIdData;
  GetUpdateAddressModel? pushintoupdateaddressmodel;
  CustomerDetails? customerDetails;
  List<MainHeadCategory> _mainHeadCategories = [];
  List<Sliders> _sliders = [];
  Mainscreen? _mainscreenData;
  List<Advertisement> _advertisements = [];
  List<Map<String, dynamic>> _mostBookedServices = [];
  int _notificationCount = 0;
  String _subscriptionStatus = "No";
  int _subscriptionRemaining = 0;

  bool _isLoading = false;

  // ─── Controllers ────────────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();

  // ── Location state ──────────────────────────────────────────────────────────
  String _currentAddress = "";
  bool _isFetchingLocation = false;
  bool _isUpdatingAddress =
      false; // true while the address-update API call is in-flight
  double? _currentLat;
  double? _currentLng;
  final TextEditingController _manualAddressController =
      TextEditingController();

  // ── Fetch device GPS location, reverse-geocode it, then push it live to the server ──
  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Location permission permanently denied. Enable it in settings.",
              ),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = "";
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address =
            "${p.street ?? ''}, ${p.subLocality ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''} ${p.postalCode ?? ''}";
        address = address.trim();
      }

      if (mounted) {
        setState(() {
          _currentAddress = address;
          _currentLat = position.latitude;
          _currentLng = position.longitude;
        });
        SharedPreferences.getInstance().then((prefs) {
          prefs.setDouble('user_lat', position.latitude);
          prefs.setDouble('user_lng', position.longitude);
        });
      }

      // Tapping "Use Current Location" IS the confirmation for this flow,
      // so immediately push the live address + lat/lng to the server.
      if (address.isNotEmpty) {
        await _updateAddressOnServer(
          address,
          lat: position.latitude,
          lng: position.longitude,
        );
      }
    } catch (e) {
      debugPrint("Location error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not fetch location: $e")));
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _updateAddressOnServer(
    String newAddress, {
    double? lat,
    double? lng,
  }) async {
    // Update UI and local storage immediately
    if (mounted) {
      setState(() {
        _currentAddress = newAddress;
        if (lat != null) _currentLat = lat;
        if (lng != null) _currentLng = lng;
      });
    }

    final prefs = await SharedPreferences.getInstance();
    if (lat != null) prefs.setDouble('user_lat', lat);
    if (lng != null) prefs.setDouble('user_lng', lng);
    prefs.setString('user_address', newAddress);

    if (!await _checkNet()) return;

    final uid = (userIdData?['user_id']?.toString().isNotEmpty == true)
        ? userIdData!['user_id'].toString()
        : (prefs.getString('user_id') ?? await Preferences.getUserID() ?? "");

    if (uid.isEmpty) {
      debugPrint(
        "⚠️ _updateAddressOnServer: user_id is empty, skipped backend sync.",
      );
      return;
    }

    if (mounted) setState(() => _isUpdatingAddress = true);

    final params = {
      "user_id": uid,
      "address": newAddress,
      "latitude": lat?.toString() ?? "",
      "longitude": lng?.toString() ?? "",
      "place_id": "",
      "landmark": newAddress,
      "location": "",
    };

    debugPrint(
      "📡 updateAddress REQUEST ➡️ endpoint: ${EndPoints.getUpdateAddress}",
    );
    debugPrint("📡 updateAddress PARAMS  ➡️ $params");

    try {
      final response = await Repository.postApiRawService(
        EndPoints.getUpdateAddress,
        params,
      );

      Map<String, dynamic> jsonResponse;
      if (response is String) {
        jsonResponse = json.decode(response) as Map<String, dynamic>;
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      } else {
        return;
      }

      debugPrint("📡 updateAddress PARSED  ➡️ $jsonResponse");

      if (jsonResponse['status'] == 'valid' ||
          jsonResponse['status'] == 'success') {
        if (mounted) {
          setState(() {
            pushintoupdateaddressmodel = GetUpdateAddressModel.fromJson(
              jsonResponse,
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Location updated successfully!"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        final reason =
            jsonResponse['message'] ?? jsonResponse['error'] ?? "Failed";
        debugPrint("⚠️ updateAddress REJECTED by server ➡️ $reason");
      }
    } catch (e) {
      debugPrint("⚠️ updateAddress EXCEPTION ➡️ $e");
    } finally {
      if (mounted) setState(() => _isUpdatingAddress = false);
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    await SessionManager.clearSession();
    debugPrint("👋 MANUAL LOGOUT — session cleared");
    if (mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Config.loginRouteName, (route) => false);
    }
  }

  void _showAddressBottomSheet() {
    _manualAddressController.text = _currentAddress;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // StatefulBuilder lets the sheet show its own local "confirming..." spinner
        // without needing to rebuild the whole HomeMainScreen.
        bool isConfirming = false;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Set Your Location",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Use current location button
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _fetchCurrentLocation();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: MyColors.appThemeLight),
                        borderRadius: BorderRadius.circular(10),
                        color: MyColors.appThemeLight.withOpacity(0.07),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.my_location,
                            color: MyColors.appThemeLight,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Use Current Location",
                                  style: TextStyle(
                                    color: MyColors.appThemeLight,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (_isFetchingLocation)
                                  const Text(
                                    "Fetching...",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  )
                                else
                                  const Text(
                                    "Uses GPS to detect your location",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (_isFetchingLocation)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              Icons.chevron_right,
                              color: MyColors.appThemeLight,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Or enter manually",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),

                  // Manual text field
                  TextField(
                    controller: _manualAddressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "e.g. 44-45-34, Venkateswara Colony, Hyderabad",
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(Icons.edit_location_alt_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: MyColors.appThemeLight,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.appThemeLight,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isConfirming
                          ? null
                          : () async {
                              final entered = _manualAddressController.text
                                  .trim();
                              if (entered.isEmpty) {
                                Navigator.pop(ctx);
                                return;
                              }

                              setSheetState(() => isConfirming = true);

                              // Geocode the typed address so we still capture
                              // live lat/lng for the API params.
                              double? lat;
                              double? lng;
                              try {
                                final locations = await locationFromAddress(
                                  entered,
                                );
                                if (locations.isNotEmpty) {
                                  lat = locations.first.latitude;
                                  lng = locations.first.longitude;
                                }
                              } catch (e) {
                                debugPrint(
                                  "Geocoding manual address failed: $e",
                                );
                              }

                              Navigator.pop(ctx);

                              await _updateAddressOnServer(
                                entered,
                                lat: lat,
                                lng: lng,
                              );
                            },
                      child: isConfirming
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Confirm Location",
                              style: TextStyle(fontSize: 15),
                            ),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initArgs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _manualAddressController.dispose();
    super.dispose();
  }

  // ─── Initialise route arguments then fire all APIs in parallel ───────────────
  Future<void> _initArgs() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      userIdData = args;
      if (args['tab_index'] != null) {
        final tab = int.tryParse(args['tab_index'].toString()) ?? 0;
        if (mounted) {
          setState(() {
            _currentIndex = tab;
          });
        }
      }
    }
    if (userIdData == null || userIdData?['user_id'] == null) {
      final savedUid = await Preferences.getUserID();
      if (savedUid != null && savedUid.isNotEmpty) {
        userIdData = {'user_id': savedUid};
      }
    }
    _loadAllData();
    _getNotificationCount();
    _getUserSubscriptionStatus();
  }

  /// Fire all independent API calls simultaneously instead of sequentially.
  Future<void> _loadAllData() async {
    await Future.wait([
      _getMainCategories(),
      _getUserDetails(),
      _getBanners(),
      _getDashboardDetails(),
      _getAdvertisements(),
      _getMostBookedServices(),
      _getNotificationCount(),
      _getUserSubscriptionStatus(),
    ]);
  }

  Future<void> _onRefreshHome() => _loadAllData();

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  /// Safely parses any API response to Map<String,dynamic>.
  Map<String, dynamic>? _parseResponse(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String) {
      try {
        return json.decode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  bool _isValidResponse(Map<String, dynamic>? json) =>
      json != null && json['status'] == 'valid';

  // ─── API calls ───────────────────────────────────────────────────────────────

  Future<void> _getMainCategories() async {
    if (!await _checkNet()) return;
    if (mounted) setState(() => _isLoading = true);
    try {
      final raw = await Repository.getApiService(
        EndPoints.getMainHeadCategories,
      );
      final res = _parseResponse(raw);
      if (_isValidResponse(res)) {
        final list = (res!['categories'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) {
              try {
                return MainHeadCategory.fromJson(e);
              } catch (_) {
                return null;
              }
            })
            .whereType<MainHeadCategory>()
            .toList();
        if (list != null && mounted) {
          setState(() => _mainHeadCategories = list);
        }
      }
    } catch (e) {
      debugPrint('getMainCategories error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getUserDetails() async {
    if (!await _checkNet()) return;
    // Fall back to saved Preferences user_id if userIdData not yet ready
    final uid = userIdData?['user_id'] ?? await Preferences.getUserID();
    if (uid == null || uid.toString().isEmpty) return;
    try {
      final raw = await Repository.postApiService(
        EndPoints.getUserDetailsforDashboard,
        {'id': uid},
      );
      final res = _parseResponse(raw);
      if (_isValidResponse(res)) {
        final model = HomeUserDetailsModel.fromJson(res!);
        if (mounted) setState(() => customerDetails = model.customerDetails);
      }
    } catch (e) {
      debugPrint('getUserDetails error: $e');
    }
  }

  Future<void> _getBanners() async {
    if (!await _checkNet()) return;
    try {
      final raw = await Repository.getApiService(EndPoints.getBanners);
      final res = _parseResponse(raw);
      if (_isValidResponse(res)) {
        final model = getBannersModel.fromJson(res!);
        final list = model.sliders ?? [];
        if (mounted) setState(() => _sliders = list);
      }
    } catch (e) {
      debugPrint('getBanners error: $e');
    }
  }

  Future<void> _getDashboardDetails() async {
    if (!await _checkNet()) return;
    try {
      final raw = await Repository.getApiService(EndPoints.getdashboardDetails);
      final res = _parseResponse(raw);
      if (_isValidResponse(res)) {
        final model = getDownloadsmodel.fromJson(res!);
        final first = (model.mainscreen?.isNotEmpty == true)
            ? model.mainscreen![0]
            : null;
        if (mounted) setState(() => _mainscreenData = first);
      }
    } catch (e) {
      debugPrint('getDashboardDetails error: $e');
    }
  }

  Future<void> _getAdvertisements() async {
    if (!await _checkNet()) return;
    try {
      final raw = await Repository.getApiService(EndPoints.getAllAdvertisments);
      final res = _parseResponse(raw);
      if (_isValidResponse(res)) {
        final model = GetAdvertisements.fromJson(res!);
        if (mounted) {
          setState(() => _advertisements = model.advertisements ?? []);
        }
      }
    } catch (e) {
      debugPrint('getAdvertisements error: $e');
    }
  }

  Future<void> _getMostBookedServices() async {
    if (!await _checkNet()) return;
    try {
      final raw = await Repository.getApiService(EndPoints.mostBookedServices);
      final res = _parseResponse(raw);
      if (_isValidResponse(res) && res!['most_booked_services'] != null) {
        final baseUrl =
            res['base_url']?.toString() ??
            'https://dev.gobuddyindia.com/assets/images/';
        final list = (res['most_booked_services'] as List)
            .whereType<Map<String, dynamic>>()
            .where(
              (item) =>
                  item['title'] != null &&
                  item['title'].toString().trim().isNotEmpty,
            )
            .map((item) {
              final rawImg = (item['service_image']?.toString() ?? '')
                  .replaceAll(r'\/', '/')
                  .replaceAll(RegExp(r'^/+'), '');
              final fullImg = rawImg.isEmpty
                  ? ''
                  : (rawImg.startsWith('http')
                        ? rawImg
                        : (rawImg.contains('assets/images/')
                              ? 'https://dev.gobuddyindia.com/$rawImg'
                              : '$baseUrl$rawImg'));
              return {
                'service_id': item['service_id']?.toString() ?? '',
                'title': item['title']?.toString() ?? '',
                'price': item['price']?.toString() ?? '0.00',
                'image': fullImg,
                'raw_image': rawImg,
                'bookings': item['total_bookings']?.toString() ?? '0',
                'rating': '4.8',
                'serviceData': item,
              };
            })
            .toList();
        if (mounted && list.isNotEmpty) {
          setState(() => _mostBookedServices = list);
        }
      }
    } catch (e) {
      debugPrint('getMostBookedServices error: $e');
    }
  }

  Future<void> _getNotificationCount() async {
    if (!await _checkNet()) return;
    final uid = userIdData?['user_id'];
    if (uid == null || uid.toString().trim().isEmpty) return;
    try {
      final raw = await Repository.postApiService(
        EndPoints.getCustomerNotificationsCount,
        {'user_id': uid.toString()},
      );
      final res = _parseResponse(raw);
      if (res != null &&
          (res['status'] == 'success' || res['status'] == 'valid') &&
          res['count'] != null) {
        final count = int.tryParse(res['count'].toString()) ?? 0;
        if (mounted) setState(() => _notificationCount = count);
      }
    } catch (e) {
      debugPrint('getNotificationCount error: $e');
    }
  }

  Future<void> _getUserSubscriptionStatus() async {
    if (!await _checkNet()) return;
    final uid = userIdData?['user_id'];
    if (uid == null || uid.toString().trim().isEmpty) return;
    try {
      final raw = await Repository.postApiService(
        EndPoints.getUserSubscriptions,
        {'user_id': uid.toString()},
      );
      final res = _parseResponse(raw);
      if (_isValidResponse(res)) {
        final sub = res!['subscription']?.toString() ?? 'No';
        final rem = int.tryParse(res['data']?.toString() ?? '0') ?? 0;
        if (mounted) {
          setState(() {
            _subscriptionStatus = sub;
            _subscriptionRemaining = rem;
          });
        }
      }
    } catch (e) {
      debugPrint('getUserSubscriptionStatus error: $e');
    }
  }

  Future<void> _searchApiIntegration() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      UtilClass.showAlertDialog(
        context: context,
        message: "Please search any service",
      );
      return;
    }
    if (!await _checkNet()) return;

    try {
      var raw = await Repository.NewPostApiService(EndPoints.newSearchApi, {
        'keyword': keyword,
      });
      var res = _parseResponse(raw);

      // Smart fallback: If multi-word search fails (e.g. 'AC service'), strip stopwords or search core token
      if (!_isValidResponse(res) ||
          (res != null && (res['services'] as List?)?.isEmpty == true)) {
        final cleaned = keyword
            .replaceAll(
              RegExp(
                r'\b(service|services|repair|installation|cleaning|expert|help)\b',
                caseSensitive: false,
              ),
              '',
            )
            .trim();
        if (cleaned.isNotEmpty &&
            cleaned.toLowerCase() != keyword.toLowerCase()) {
          raw = await Repository.NewPostApiService(EndPoints.newSearchApi, {
            'keyword': cleaned,
          });
          res = _parseResponse(raw);
        }
      }

      if (_isValidResponse(res)) {
        final model = NewSearchModel.fromJson(res!);
        if (model.services?.isNotEmpty == true) {
          Navigator.pushNamed(
            context,
            Config.searchScreen,
            arguments: {'subServices': model.services},
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No services found for your search"),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res?['message'] ?? "No services found")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No services found for your search")),
        );
      }
    }
  }

  /// Returns false and shows snackbar if no internet (avoids blocking dialogs).
  Future<bool> _checkNet() async {
    final ok = await UtilClass.checkInternet();
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No Internet Connection")));
    }
    return ok;
  }

  // ─── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          _getUserDetails();
          setState(() => _currentIndex = 0);
          return;
        }
        // If on Home tab, show Exit confirmation dialog
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Are you sure you want to exit GoBuddy?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.appThemeLight,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Exit"),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFf4f8f6),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            onTap: (i) {
              if (i == 0 && _currentIndex != 0) {
                _getUserDetails();
              }
              setState(() => _currentIndex = i);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: "Bookings",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.workspace_premium),
                label: "Subscription",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
          body: _getBody(),
        ),
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _homePage();
      case 1:
        return BookingsScreen(
          userData: userIdData,
          onBack: () {
            _getUserDetails();
            setState(() => _currentIndex = 0);
          },
        );
      case 2:
        return MySubscriptionScreen(
          userData: userIdData,
          onBack: () {
            _getUserDetails();
            setState(() => _currentIndex = 0);
          },
        );
      case 3:
        return AccountScreen(
          userData: userIdData,
          onBack: () {
            _getUserDetails();
            setState(() => _currentIndex = 0);
          },
          onProfileUpdated: () {
            _getUserDetails();
          },
        );
      default:
        return _homePage();
    }
  }

  // ─── Home page ────────────────────────────────────────────────────────────────
  Widget _homePage() {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: _onRefreshHome,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          // CustomScrollView is faster than Column+SingleChildScrollView
          // for many children because it uses slivers.
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(h, w)),
            SliverToBoxAdapter(child: _buildSubscriptionBanner(h, w)),
            SliverToBoxAdapter(child: _buildReferBanner(h, w)),
            SliverToBoxAdapter(child: SizedBox(height: 4)),
            SliverToBoxAdapter(child: _buildBannerSlider(h, w)),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildStatsRow()),
            // Use SliverGrid directly — avoids nested shrinkWrap GridView
            _buildCategoriesGrid(h, w),
            SliverToBoxAdapter(child: _buildMostBooked(h, w)),
            SliverToBoxAdapter(child: SizedBox(height: h * 0.02)),
            SliverToBoxAdapter(child: _buildAdvertisements(h, w)),
            SliverToBoxAdapter(child: SizedBox(height: h * 0.03)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double h, double w) {
    return Container(
      width: w,
      padding: EdgeInsets.all(w * 0.04),
      color: MyColors.appThemeLight,
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(),
              SizedBox(width: w * 0.02),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerDetails?.name ?? "",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Text(
                      "What you are looking for today?",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF19a64b),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () async {
                        await Navigator.pushNamed(
                          context,
                          Config.notificationscreen,
                          arguments: {'user_id': userIdData?['user_id'] ?? ""},
                        );
                        _getNotificationCount();
                      },
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  if (_notificationCount > 0)
                    Positioned(
                      right: 4,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          _notificationCount > 99
                              ? '99+'
                              : '$_notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),

              // ── Logout button ──────────────────────────────────────────
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF19a64b),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout, color: Colors.white, size: 22),
                ),
              ),
              // ─────────────────────────────────────────────────────────────
            ],
          ),
          SizedBox(height: h * 0.015),

          // ── Tappable location row ──────────────────────────────────────────
          GestureDetector(
            onTap: _showAddressBottomSheet,
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 18),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    _currentAddress.isNotEmpty
                        ? _currentAddress
                        : customerDetails?.address ?? "Please update Location",
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                (_isFetchingLocation || _isUpdatingAddress)
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 18,
                      ),
              ],
            ),
          ),
          // ──────────────────────────────────────────────────────────────────

          SizedBox(height: h * 0.015),
          Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(23),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search your service here",
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: MyColors.grayText,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchApiIntegration(),
                  ),
                ),
                GestureDetector(
                  onTap: _searchApiIntegration,
                  child: const Icon(Icons.search, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  "Popular: ",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ...[
                  "AC Service",
                  "Cleaning",
                  "Plumbing",
                  "Electrician",
                  "Painting",
                ].map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        _searchController.text = s;
                        _searchApiIntegration();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white30, width: 0.8),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildAvatar() {
    final profile = customerDetails?.profile;

    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey.shade300,
      child: ClipOval(child: CustomerProfileAvatar(profile: profile, size: 40)),
    );
  }

  Widget _buildSubscriptionBanner(double h, double w) {
    final bool hasSub = _subscriptionStatus.toLowerCase() == "yes";
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MySubscriptionScreen(userData: userIdData),
        ),
      ),
      child: Container(
        width: w,
        padding: EdgeInsets.all(w * 0.02),
        margin: EdgeInsets.only(bottom: h * 0.03),
        decoration: BoxDecoration(
          color: hasSub ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3C4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(right: w * 0.02, left: 4),
                child: Image.asset(
                  'assets/images/crown2.png',
                  height: w * 0.14,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: w * 0.03),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasSub
                        ? "Active Subscription ($_subscriptionRemaining services remaining)"
                        : "Try Our Home & Property Care Subscription & Avoid Costly Repairs",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: h * 0.003),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          hasSub
                              ? "View your subscription benefits"
                              : "Know more & Get Subscription",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Image.asset(
                'assets/images/startsImg.png',
                height: w * 0.13,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Refer banner ─────────────────────────────────────────────────────────────
  Widget _buildReferBanner(double h, double w) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            Config.referandearnRouteName,
            arguments: {'user_id': userIdData?['user_id'] ?? ""},
          );
        },
        child: Container(
          width: w,
          padding: EdgeInsets.all(w * 0.03),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5E5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Refer and get free services",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Invite and get 100 rupees",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Text(
                          "Invite Now",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: MyColors.appThemeLight,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 11,
                          color: MyColors.appThemeLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(w * 0.005),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/giftsImg.png',
                    height: w * 0.12,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Banner slider ────────────────────────────────────────────────────────────
  Widget _buildBannerSlider(double h, double w) {
    if (_sliders.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: h * 0.26,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _sliders.length,
            onPageChanged: (i) => setState(() => _currentBannerIndex = i),
            itemBuilder: (_, i) {
              final rawPath = (_sliders[i].image ?? '')
                  .replaceAll(r'\/', '/')
                  .replaceAll(RegExp(r'^/+'), '');
              final url = rawPath.startsWith('http')
                  ? rawPath
                  : rawPath.contains('assets/images/')
                  ? 'https://dev.gobuddyindia.com/$rawPath'
                  : 'https://dev.gobuddyindia.com/assets/images/$rawPath';
              final fallbackUrl = rawPath.startsWith('http')
                  ? rawPath
                  : rawPath.contains('assets/images/')
                  ? 'https://dev.gobuddyindia.com/$rawPath'
                  : 'https://dev.gobuddyindia.com/assets/images/$rawPath';
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: w * 0.03,
                  vertical: h * 0.002,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    url,
                    height: h * 0.25,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.network(
                      fallbackUrl,
                      height: h * 0.25,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE8F5E9),
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/logoImg.png',
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_sliders.length, (i) {
            final active = _currentBannerIndex == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 10 : 6,
              height: active ? 10 : 6,
              decoration: BoxDecoration(
                color: active ? Colors.green : Colors.green.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── Stats row ────────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statItem(
              Icons.people_alt_outlined,
              _mainscreenData?.providers ?? "1K+ Providers",
            ),
            _statItem(
              Icons.assignment_outlined,
              _mainscreenData?.bookings ?? "1M+ Bookings",
            ),
            _statItem(
              Icons.emoji_emotions_outlined,
              _mainscreenData?.customers ?? "90K+ Happy Customers",
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String label) => Row(
    children: [
      Icon(icon, size: 16, color: Colors.black54),
      const SizedBox(width: 2),
      Text(label, style: const TextStyle(fontSize: 9, color: Colors.black87)),
    ],
  );

  IconData _getCategoryIcon(String catName) {
    final lower = catName.toLowerCase();
    if (lower.contains('ac') || lower.contains('air')) return Icons.ac_unit;
    if (lower.contains('clean')) return Icons.cleaning_services;
    if (lower.contains('appliance') || lower.contains('repair'))
      return Icons.home_repair_service;
    if (lower.contains('electr')) return Icons.electrical_services;
    if (lower.contains('plumb')) return Icons.plumbing;
    if (lower.contains('carpent')) return Icons.carpenter;
    if (lower.contains('pest')) return Icons.pest_control;
    if (lower.contains('paint')) return Icons.format_paint;
    return Icons.handyman;
  }

  // ─── Categories grid (SliverGrid — no shrinkWrap) ────────────────────────────
  Widget _buildCategoriesGrid(double h, double w) {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return SliverPadding(
      padding: EdgeInsets.all(w * 0.03),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((_, i) {
          final cat = _mainHeadCategories[i];
          final rawImg = (cat.image)
              .replaceAll(r'\/', '/')
              .replaceAll('\\', '')
              .replaceAll(RegExp(r'^/+'), '')
              .trim();
          final imageUrl = rawImg.startsWith('http')
              ? rawImg
              : rawImg.contains('assets/images/')
              ? 'https://dev.gobuddyindia.com/$rawImg'
              : 'https://dev.gobuddyindia.com/assets/images/$rawImg';
          final fallbackUrl = rawImg.startsWith('http')
              ? rawImg
              : rawImg.contains('assets/images/')
              ? 'https://dev.gobuddyindia.com/$rawImg'
              : 'https://dev.gobuddyindia.com/assets/images/$rawImg';
          return InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              Config.selectServiceTypeRouteName,
              arguments: {
                'mainCategoryId': cat.id,
                'categoryName': cat.category,
                'user_id': userIdData?['user_id'],
              },
            ),
            child: Material(
              elevation: 2,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(50),
                bottom: Radius.circular(12),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(50),
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: h * 0.015),
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDFF5E3),
                        shape: BoxShape.circle,
                      ),
                      child: rawImg.isNotEmpty
                          ? Image.network(
                              Uri.encodeFull(imageUrl),
                              height: h * 0.04,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Image.network(
                                Uri.encodeFull(fallbackUrl),
                                height: h * 0.04,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  _getCategoryIcon(cat.category),
                                  size: h * 0.04,
                                  color: const Color(0xFF19a64b),
                                ),
                              ),
                            )
                          : Icon(
                              _getCategoryIcon(cat.category),
                              size: h * 0.04,
                              color: const Color(0xFF19a64b),
                            ),
                    ),
                    SizedBox(height: h * 0.012),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        cat.category,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: w * 0.032,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }, childCount: _mainHeadCategories.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
      ),
    );
  }

  // ─── Most booked ──────────────────────────────────────────────────────────────
  Widget _buildMostBooked(double h, double w) {
    if (_mostBookedServices.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "Most Booked Services",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: h * 0.02),
        SizedBox(
          height: h * 0.26,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _mostBookedServices.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            addAutomaticKeepAlives: false,
            itemBuilder: (_, i) {
              final svc = _mostBookedServices[i];
              final imgUrl = svc["image"]?.toString() ?? "";
              final isNetworkImg = imgUrl.startsWith("http");

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Config.serviceDetailsRouteName,
                    arguments: {
                      'service_id': svc['service_id'],
                      'serviceData': svc['serviceData'] ?? svc,
                    },
                  );
                },
                child: Container(
                  width: w * 0.38,
                  margin: EdgeInsets.only(right: w * 0.025),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: isNetworkImg
                            ? Image.network(
                                imgUrl,
                                height: h * 0.13,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: h * 0.13,
                                  color: Colors.grey.shade100,
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/images/logoImg.png',
                                    height: 36,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              )
                            : Image.asset(
                                imgUrl.isNotEmpty
                                    ? imgUrl
                                    : 'assets/images/logoImg.png',
                                height: h * 0.13,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          svc["title"] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: w * 0.032,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 13,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              svc["rating"] ?? "4.8",
                              style: TextStyle(
                                fontSize: w * 0.028,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "(${svc["bookings"]} Bookings)",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: w * 0.024,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Advertisements ───────────────────────────────────────────────────────────
  Widget _buildAdvertisements(double h, double w) {
    if (_advertisements.isEmpty) return const SizedBox.shrink();
    return Column(
      children: _advertisements.map((ad) {
        return Padding(
          padding: EdgeInsets.all(w * 0.03),
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(w * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xff3188c2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ad.title ?? "",
                          style: TextStyle(
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: h * 0.005),
                        Text(
                          ad.subTitle ?? "",
                          style: TextStyle(
                            fontSize: w * 0.032,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        ad.advertise ?? "",
                        height: h * 0.19,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white10,
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/logoImg.png',
                            height: 40,
                            fit: BoxFit.contain,
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
      }).toList(),
    );
  }
}
