import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gobuddy_customer_app/models/advertisments_model.dart';
import 'package:gobuddy_customer_app/models/banners_model.dart';
import 'package:gobuddy_customer_app/models/head_category.dart';
import 'package:gobuddy_customer_app/models/homescreen_details_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  final PageController _pageController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  DateTime? _lastBackPressed;

  List<MainHeadCategory> _mainHeadCategories = [];
  List<Sliders> _sliders = [];
  Mainscreen? _mainscreenData;
  List<Advertisement> _advertisements = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPublicData();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll() {
    _bannerTimer?.cancel();
    if (_sliders.length <= 1) return;
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        int next = (_currentBannerIndex + 1) % _sliders.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _fetchPublicData() async {
    final hasNet = await UtilClass.checkInternet();
    if (!hasNet) return;

    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _getCategories(),
        _getBanners(),
        _getDashboardDetails(),
        _getAdvertisements(),
      ]);
    } catch (e) {
      debugPrint("GuestHomeScreen: Error loading public data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic>? _parseResponse(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String) {
      try {
        return json.decode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  Future<void> _getCategories() async {
    try {
      final raw = await Repository.getApiService(EndPoints.getMainHeadCategories);
      final res = _parseResponse(raw);
      if (res != null && res['status'] == 'valid') {
        final list = (res['categories'] as List?)
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
      debugPrint('Guest _getCategories error: $e');
    }
  }

  Future<void> _getBanners() async {
    try {
      final raw = await Repository.getApiService(EndPoints.getBanners);
      final res = _parseResponse(raw);
      if (res != null && res['status'] == 'valid') {
        final model = getBannersModel.fromJson(res);
        final list = model.sliders ?? [];
        if (mounted) {
          setState(() => _sliders = list);
          _startBannerAutoScroll();
        }
      }
    } catch (e) {
      debugPrint('Guest _getBanners error: $e');
    }
  }

  Future<void> _getDashboardDetails() async {
    try {
      final raw = await Repository.getApiService(EndPoints.getdashboardDetails);
      final res = _parseResponse(raw);
      if (res != null && res['status'] == 'valid') {
        final model = getDownloadsmodel.fromJson(res);
        final first = (model.mainscreen?.isNotEmpty == true) ? model.mainscreen![0] : null;
        if (mounted) setState(() => _mainscreenData = first);
      }
    } catch (e) {
      debugPrint('Guest _getDashboardDetails error: $e');
    }
  }

  Future<void> _getAdvertisements() async {
    try {
      final raw = await Repository.getApiService(EndPoints.getAllAdvertisments);
      final res = _parseResponse(raw);
      if (res != null && res['status'] == 'valid') {
        final model = GetAdvertisements.fromJson(res);
        if (mounted) setState(() => _advertisements = model.advertisements ?? []);
      }
    } catch (e) {
      debugPrint('Guest _getAdvertisements error: $e');
    }
  }

  void _promptLogin({String? message}) {
    Fluttertoast.showToast(
      msg: message ?? "Please sign in to book services",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    Navigator.pushNamed(context, Config.loginRouteName);
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      Fluttertoast.showToast(msg: "Press back again to exit");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF9),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 1,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Image.asset(
                'assets/images/logoImg.png',
                height: 34,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.home_repair_service_rounded,
                  color: MyColors.appThemeLight,
                  size: 28,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "GoBuddy",
                style: TextStyle(
                  color: MyColors.appThemeLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14, top: 8, bottom: 8),
              child: ElevatedButton.icon(
                onPressed: () => _promptLogin(message: "Please enter your mobile number to login"),
                icon: const Icon(Icons.login_rounded, size: 16, color: Colors.white),
                label: const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.appThemeLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                ),
              ),
            ),
          ],
        ),
        body: _isLoading && _mainHeadCategories.isEmpty && _sliders.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchPublicData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Top Search Banner
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 12),
                        color: MyColors.appThemeLight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome to GoBuddy!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Explore trusted home & property maintenance",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => _promptLogin(
                                message: "Please login to search and book services",
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.03,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(23),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.search, color: Colors.grey, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Search your service here...",
                                        style: TextStyle(
                                          color: MyColors.grayText,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Live Slider Banners
                    if (_sliders.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Column(
                            children: [
                              SizedBox(
                                height: h * 0.22,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _sliders.length,
                                  onPageChanged: (i) =>
                                      setState(() => _currentBannerIndex = i),
                                  itemBuilder: (_, i) {
                                    final rawPath =
                                        (_sliders[i].image ?? '').replaceAll(r'\/', '/');
                                    final url = rawPath.startsWith('http')
                                        ? rawPath
                                        : 'https://dev.gobuddyindia.com/assets/images/$rawPath';
                                    return GestureDetector(
                                      onTap: () => _promptLogin(),
                                      child: Container(
                                        margin: EdgeInsets.symmetric(horizontal: w * 0.04),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Image.network(
                                            url,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: const Color(0xFFE8F5E9),
                                              alignment: Alignment.center,
                                              child: Image.asset(
                                                'assets/images/logoImg.png',
                                                height: 48,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_sliders.length, (i) {
                                  final active = _currentBannerIndex == i;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    width: active ? 10 : 5,
                                    height: active ? 10 : 5,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? MyColors.appThemeLight
                                          : MyColors.appThemeLight.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Stats Row
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.04,
                          vertical: 12,
                        ),
                        child: Material(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
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
                                  _mainscreenData?.customers ?? "90K+ Customers",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Section Heading
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(w * 0.04, 8, w * 0.04, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Our Services",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _promptLogin(),
                              child: const Text(
                                "View All",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: MyColors.appThemeLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Categories Grid
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: 6),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final cat = _mainHeadCategories[i];
                            final imageUrl =
                                'https://dev.gobuddyindia.com/assets/images/${cat.image}';

                            return InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _promptLogin(
                                message: "Please login to book ${cat.category.isNotEmpty ? cat.category : 'service'}",
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => const Icon(
                                            Icons.build_circle_outlined,
                                            size: 36,
                                            color: MyColors.appThemeLight,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      cat.category,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: _mainHeadCategories.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.85,
                        ),
                      ),
                    ),

                    // Subscription Promo Card
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: w * 0.04,
                          vertical: 14,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3C4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/crown2.png',
                              height: 44,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.workspace_premium,
                                color: Colors.amber,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Save with Subscription",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Get zero platform fees & priority service",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _promptLogin(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyColors.appThemeLight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                "Explore",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Extra bottom padding so nothing gets obscured by the bottom bar
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _promptLogin(
                  message: "Please login to proceed with service booking",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.appThemeLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Sign In / Register to Book Services",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: MyColors.appThemeLight),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      );
}
