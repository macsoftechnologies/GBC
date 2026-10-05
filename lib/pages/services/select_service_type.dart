import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/models/home_subcategory_model.dart';
import 'package:gobuddy_customer_app/models/subcategory_banner_details_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'add_services_to_cart.dart';

class SelectServiceTypeScreen extends StatefulWidget {
  const SelectServiceTypeScreen({super.key});

  @override
  State<SelectServiceTypeScreen> createState() =>
      _SelectServiceTypeScreenState();
}

class _SelectServiceTypeScreenState extends State<SelectServiceTypeScreen>
    with SingleTickerProviderStateMixin {

  String? mainCategoryId;
  String? categoryName;
  String? userId;

  GetSubCategoryModel? pushSubcategory;
  List<SubCategory> subcategories = [];

  GetReviewsOnSubcategoryModel? pushcategoriesuserDetails;
  Data? subcatbannerDetails;
  List<Data> subcategoriesBannerDetails = [];

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && args['mainCategoryId'] != null) {
      mainCategoryId = args['mainCategoryId'];
      categoryName = args['categoryName'];
      userId = args['user_id'];

      _getSubCategoriesList();
      _getReviewsListApi();
    }
  }

  Future<void> _getReviewsListApi() async {
    bool internet = await UtilClass.checkInternet();

    if (!internet) {
      UtilClass.showAlertDialog(
          context: context, message: "No Internet Connection");
      return;
    }

    try {
      final response = await Repository.NewPostApiService(
          EndPoints.subcategoryuserdetails, {'category_id': mainCategoryId});

      late Map<String, dynamic> jsonResponse;

      if (response is String) {
        jsonResponse = json.decode(response as String);
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      }

      if (jsonResponse["status"] == "valid") {
        setState(() {
          pushcategoriesuserDetails =
              GetReviewsOnSubcategoryModel.fromJson(jsonResponse);

          subcatbannerDetails = pushcategoriesuserDetails!.data;
          subcategoriesBannerDetails = [
            if (subcatbannerDetails != null) subcatbannerDetails!
          ];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getSubCategoriesList() async {
    bool internet = await UtilClass.checkInternet();

    if (!internet) {
      UtilClass.showAlertDialog(context: context, message: "Bad Network!");
      return;
    }

    try {
      final response = await Repository.NewPostApiService(
          EndPoints.getSubcategoriesByMaincategoryApi,
          {"category_id": mainCategoryId});

      if (response["status"] == "valid") {
        pushSubcategory = GetSubCategoryModel.fromJson(response);

        setState(() {
          subcategories = pushSubcategory!.subCategory!;
          categoryName = pushSubcategory!.categoryName ?? "";
        });

        _controller.forward();
      }
    } catch (e) {
      UtilClass.showAlertDialog(
          context: context, message: "Something went wrong.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;
    final bool isSmallScreen = width < 360;

    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: Column(
        children: [

          /// HEADER
          _buildHeader(context, width),

          /// STATS
          _buildStatsRow(width, isSmallScreen),

          const SizedBox(height: 25),

          /// SERVICE LIST
          _buildServiceList(context, width, height),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double width) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(color: MyColors.appThemeLight),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 15),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                child: Image.asset("assets/images/whiteLeftArrow.png", width: 9),
              ),
            ),
            SizedBox(width: width * 0.05),
            Text(
              categoryName ?? "",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(double width, bool isSmallScreen) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.04, vertical: isSmallScreen ? 10 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
              icon: Icons.people,
              text: subcatbannerDetails?.providers ?? "",
              isSmallScreen: isSmallScreen),
          _buildStatItem(
              icon: Icons.star,
              text: subcatbannerDetails?.reviews ?? "",
              isSmallScreen: isSmallScreen),
          _buildStatItem(
              icon: Icons.assignment,
              text: subcatbannerDetails?.bookings ?? "",
              isSmallScreen: isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      {required IconData icon,
      required String text,
      required bool isSmallScreen}) {
    return Row(
      children: [
        Icon(icon, size: isSmallScreen ? 14 : 16, color: Colors.black54),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(
                fontSize: isSmallScreen ? 11 : 13, color: Colors.black87)),
      ],
    );
  }

  Widget _buildServiceList(BuildContext context, double width, double height) {
    return Expanded(
      child: subcategories.isEmpty
          ? const Center(child: Text('No services available'))
          : FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                itemCount: subcategories.length,
                itemBuilder: (context, index) {

                  final subCategory = subcategories[index];

                  return _AnimatedServiceCard(
                    subCategory: subCategory,
                    width: width,
                    mainCategoryId: mainCategoryId,
                    userId: userId,
                  );
                },
              ),
            ),
    );
  }
}

/// Animated Card Widget
class _AnimatedServiceCard extends StatefulWidget {
  final SubCategory subCategory;
  final double width;
  final String? mainCategoryId;
  final String? userId;

  const _AnimatedServiceCard(
      {required this.subCategory,
      required this.width,
      required this.mainCategoryId,
      required this.userId});

  @override
  State<_AnimatedServiceCard> createState() => _AnimatedServiceCardState();
}

class _AnimatedServiceCardState extends State<_AnimatedServiceCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {

    final imageUrl =
        (widget.subCategory.subImage != null &&
                widget.subCategory.subImage!.isNotEmpty)
            ? "https://dev.gobuddyindia.com/assets/images/${widget.subCategory.subImage}"
            : null;

    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) => setState(() => pressed = false),
      onTapCancel: () => setState(() => pressed = false),
      onTap: () {

        Navigator.pushNamed(
          context,
          Config.addServicesToCartRouteName,
          arguments: {
            "subcat_id": widget.subCategory.id,
            "sub_category_name": widget.subCategory.subCategory,
            "main_category_id": widget.mainCategoryId ?? "",
            "user_id": widget.userId ?? ""
          },
        );
      },
      child: AnimatedScale(
        scale: pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(pressed ? 0.25 : 0.1),
                blurRadius: pressed ? 10 : 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
                horizontal: widget.width * 0.04, vertical: 8),

            leading: AnimatedScale(
              scale: pressed ? 1.2 : 1,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF5E3),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/acr.png',
                          fit: BoxFit.contain,
                        ),
                      )
                    : Image.asset('assets/images/acr.png'),
              ),
            ),

            title: Text(widget.subCategory.subCategory ?? "No Title",
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),

            subtitle: Text(widget.subCategory.id ?? "",
                style: const TextStyle(fontSize: 13, color: Colors.black54)),

            trailing: const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFDFF5E3),
              child: Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.green),
            ),
          ),
        ),
      ),
    );
  }
}
