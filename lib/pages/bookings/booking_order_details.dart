import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/common/skeleton_loader.dart';

import 'package:gobuddy_customer_app/models/bookings_overview_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/config.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  // late Map<String, dynamic> orderData;
  String? jobCalendarId;
  GetBookingOverview? pushintoOverview;
  Order? getOders;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    jobCalendarId = args['order_id'] ?? "";
    print("This is Job calendar id $jobCalendarId");

    _getBookingsOverview();
  }

  Future<void> _getBookingsOverview() async {
    bool internet = await UtilClass.checkInternet();
    if (!internet) {
      UtilClass.showAlertDialog(
        context: context,
        message: "No Internet Connection!",
      );
      return;
    }

    try {
      final response = await Repository.NewPostApiService(
        EndPoints.getBookingsOverview,
        {'id': jobCalendarId ?? ""},
      );

      Map<String, dynamic> jsonResponse = response is String
          ? json.decode(response as String)
          : response;

      if (jsonResponse["status"] == "valid") {
        pushintoOverview = GetBookingOverview.fromJson(jsonResponse);

        setState(() {
          getOders = pushintoOverview?.order;
          isLoading = false;
        });
      } else {
        print("Error fetching Order Overview");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    Color getStatusColor(String status, Order getOders) {
      switch (getOders.status) {
        case "Scheduled":
          return Colors.green.shade100;
        case "Completed":
          return Colors.green.shade100;
        case "Cancelled":
          return Colors.red.shade100;
        default:
          return Colors.grey.shade200;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FCFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyColors.appThemeLight,
        leading: Container(
          width: 45,
          height: 45,
          margin: EdgeInsets.only(left: 16), // Add some margin from left edge
          decoration: BoxDecoration(
            color: Color(0xFF19a64b),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          "Order Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18, // Added font size for consistency
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            width: 45,
            height: 45,
            margin: EdgeInsets.only(
              right: 16,
            ), // Add some margin from right edge
            decoration: BoxDecoration(
              color: Color(0xFF19a64b),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                // Add your support action here
              },
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : getOders == null
          ? const Center(child: Text("No order details available"))
          : SingleChildScrollView(
              padding: EdgeInsets.all(width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _orderInfoCard(width, getOders!),

                  SizedBox(height: height * 0.015),

                  _customerInfoCard(width, getOders!),
                  SizedBox(height: height * 0.015),
                  _providerInfoCard(width, getOders!),
                  SizedBox(height: height * 0.015),
                  _priceDetailsCard(width, getOders!),
                  // if (orderData["status"] == "Completed" &&
                  //     (orderData["rating"] == 0 || orderData["rating"] == null))
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: height * 0.02),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Config
                                .rateProviderScreenforBookings, // ✅ route name
                            arguments: {
                              'provider': getOders?.provider,
                              'services': getOders?.service,
                              'order_id': getOders?.orderId ?? "",
                            },
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            "Rate Provider",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _orderInfoCard(double width, Order? getOders) {
    // 1️⃣ Show Skeleton while data is loading
    if (getOders == null) {
      return Container(
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top texts skeleton
            const SkeletonLoader(height: 14, width: 120),
            const SizedBox(height: 6),
            const SkeletonLoader(height: 14, width: 180),
            const SizedBox(height: 10),
            // Order ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonLoader(height: 14, width: 150),
                SkeletonLoader(height: 16, width: 60),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Skeleton
                const SkeletonLoader(height: 70, width: 70, radius: 8),
                SizedBox(width: width * 0.04),
                // Service info skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonLoader(height: 16, width: double.infinity),
                      SizedBox(height: 6),
                      SkeletonLoader(height: 14, width: 120),
                      SizedBox(height: 6),
                      SkeletonLoader(height: 14, width: 100),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // 2️⃣ Normal UI after data loads
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "Order ID: ${getOders.orderId ?? ""}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: getOders.status == "Cancelled"
                      ? Colors.red
                      : Colors.green.shade100,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Text(
                  getOders.status ?? "",
                  style: TextStyle(
                    color: getOders.status == "Cancelled"
                        ? Colors.white
                        : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            getOders.scheduleDate ?? "",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xffF0FFF5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffB2DFCC), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.pin_outlined,
                  color: Color(0xff08A045),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  "Order MPIN: ",
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  getOders.couponName ?? "N/A",
                  style: const TextStyle(
                    color: Color(0xff08A045),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    (getOders.service?.serviceImage != null &&
                        getOders.service!.serviceImage!.isNotEmpty)
                    ? Image.network(
                        "https://dev.gobuddyindia.com/assets/images/${getOders.service!.serviceImage}",
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.network(
                          "https://dev.gobuddyindia.com/assets/images/${getOders.service!.serviceImage}",
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
              ),
              SizedBox(width: width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getOders.service?.serviceName ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            getOders.scheduleDate ?? "",
                            style: TextStyle(color: Colors.grey.shade700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "₹ ${getOders.service?.subtotal ?? 0}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "₹ ${getOders.service?.price ?? 0}",
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "(${getOders.service?.discount ?? 0})",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _customerInfoCard(double width, Order getOders) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.green),
              SizedBox(width: width * 0.02),
              Flexible(
                child: Text(
                  getOders.user?.name ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: const Text("Home"),
                  ),
                  if (getOders.status == "Scheduled") ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        // Add your edit action here (e.g., open edit address screen)
                        print("Edit address tapped");
                      },
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            getOders.user?.phone ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            (getOders.location != null && getOders.location!.isNotEmpty)
                ? getOders.location!
                : (getOders.address != null && getOders.address!.isNotEmpty)
                ? getOders.address!
                : getOders.landmark ??
                      getOders.user?.email ??
                      "Address not specified",
            style: const TextStyle(fontSize: 14),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _providerInfoCard(double width, Order getOrders) {
    final provider = getOrders.provider;
    final imageUrl =
        (provider?.providerProfile != null &&
            provider!.providerProfile!.isNotEmpty)
        ? provider.providerProfile
        : null;

    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Service Provider",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey[200],
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl == null
                    ? const Icon(Icons.person, color: Colors.grey, size: 28)
                    : null, // Fallback icon when image is null
                onBackgroundImageError: (_, __) {
                  // You can also handle a broken image error here if needed
                },
              ),
              SizedBox(width: width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (provider?.name != null && provider!.name!.isNotEmpty)
                          ? provider.name!
                          : "No Name Provided",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider?.email ?? "No email available",
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _actionButton(Icons.person, "View Profile", getOders!),
              _circleIcon(context, Icons.phone, getOders!),
              const SizedBox(width: 8),
              _circleIcon(context, Icons.email, getOders!),
              if (getOrders.status?.toLowerCase() != 'completed' &&
                  getOrders.status?.toLowerCase() != 'cancelled')
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF19a64b)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => _showChangeProviderBottomSheet(getOrders),
                  icon: const Icon(
                    Icons.swap_horiz,
                    size: 16,
                    color: Color(0xFF19a64b),
                  ),
                  label: const Text(
                    "Change Provider",
                    style: TextStyle(
                      color: Color(0xFF19a64b),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _changeProvider(String newProviderId) async {
    final bool internet = await UtilClass.checkInternet();
    if (!internet) {
      UtilClass.showAlertDialog(
        context: context,
        message: "No Internet Connection!",
      );
      return;
    }
    UtilClass.showProgress(context: context);
    try {
      final response =
          await Repository.postApiRawService(EndPoints.assignToProvider, {
            "order_id": jobCalendarId ?? getOders?.orderId ?? "",
            "provider_id": newProviderId,
          });
      UtilClass.hideProgress();

      Map<String, dynamic> jsonResponse;
      if (response is String) {
        jsonResponse = json.decode(response);
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      } else {
        jsonResponse = {};
      }

      if (jsonResponse["status"] == "valid" || jsonResponse["status"] == true) {
        if (mounted) {
          UtilClass.showAlertDialog(
            context: context,
            message:
                jsonResponse["message"]?.toString() ??
                "Provider assigned successfully!",
          );
          _getBookingsOverview();
        }
      } else {
        if (mounted) {
          UtilClass.showAlertDialog(
            context: context,
            message:
                jsonResponse["message"]?.toString() ??
                "Failed to assign provider.",
          );
        }
      }
    } catch (e) {
      UtilClass.hideProgress();
      if (mounted) {
        UtilClass.showAlertDialog(
          context: context,
          message: "Error assigning provider: $e",
        );
      }
    }
  }

  void _showChangeProviderBottomSheet(Order order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Change Service Provider",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Current provider will be replaced with another verified professional for your scheduled booking.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF19a64b),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  label: const Text(
                    "Auto-Assign Best Alternate Provider",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _autoAssignAlternateProvider(order);
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _autoAssignAlternateProvider(Order order) async {
    final bool internet = await UtilClass.checkInternet();
    if (!internet) {
      UtilClass.showAlertDialog(
        context: context,
        message: "No Internet Connection!",
      );
      return;
    }
    UtilClass.showProgress(context: context);
    try {
      final response = await Repository.postApiRawService(
        EndPoints.AssignbestProvider,
        {
          "category_id": 1,
          "schedule_date": order.scheduleDate ?? "",
          "schedule_time": order.scheduleTime ?? "",
          "service_ids": [
            int.tryParse(order.service?.serviceId?.toString() ?? "") ?? 1,
          ],
        },
      );
      UtilClass.hideProgress();

      Map<String, dynamic> jsonResponse;
      if (response is String) {
        jsonResponse = json.decode(response);
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      } else {
        jsonResponse = {};
      }

      if (jsonResponse["status"] == "valid" && jsonResponse["data"] != null) {
        final newProviderId =
            jsonResponse["data"]["provider_id"]?.toString() ?? "";
        if (newProviderId.isNotEmpty) {
          await _changeProvider(newProviderId);
        } else {
          if (mounted) {
            UtilClass.showAlertDialog(
              context: context,
              message: "No alternate provider available for this time slot.",
            );
          }
        }
      } else {
        if (mounted) {
          UtilClass.showAlertDialog(
            context: context,
            message:
                jsonResponse["message"]?.toString() ??
                "No alternate provider found.",
          );
        }
      }
    } catch (e) {
      UtilClass.hideProgress();
      if (mounted) {
        UtilClass.showAlertDialog(
          context: context,
          message: "Error finding alternate provider: $e",
        );
      }
    }
  }

  Widget _priceDetailsCard(double width, Order getOrders) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Price Details",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _priceRow("Order(s) amount", "₹ ${getOrders.service?.subtotal}"),
          _priceRow("Actual Price", "₹ ${getOrders.service?.price}"),
          _priceRow("Offer(Discount)", "₹ ${getOrders.service?.discount}"),
          _priceRow("Platform fee", "₹ ${getOrders.platformFee}"),
          _priceRow("GB Coins", "₹ ${getOrders.gbCoins}"),
          _priceRow("Coupon Amount", "₹ ${getOrders.couponAmount}"),
          const Divider(height: 20),
          _priceRow("Total Amount", "₹ ${getOrders.grandTotal}", isBold: true),
          const SizedBox(height: 8),
          if (getOrders.status == "Cancelled")
            Text("• Refunded ", style: const TextStyle(color: Colors.black)),
          if (getOrders.status == "Completed")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (getOrders.platformFee != null &&
                    getOrders.platformFee!.isNotEmpty &&
                    getOrders.platformFee != "0")
                  Text("• Platform fee paid ₹${getOrders.platformFee}"),
                Text(
                  "• Paid to provider after service ₹${getOrders.grandTotal ?? getOrders.subTotal ?? '0'}",
                ),
              ],
            ),
          if (getOrders.status == "Scheduled")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (getOrders.platformFee != null &&
                    getOrders.platformFee!.isNotEmpty &&
                    getOrders.platformFee != "0")
                  Text("• Platform fee ₹${getOrders.platformFee}"),
                Text(
                  "• Amount to Pay After Service to Provider ₹${getOrders.grandTotal ?? getOrders.subTotal ?? '0'}",
                ),
              ],
            ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        offset: const Offset(0, 1),
        blurRadius: 4,
      ),
    ],
  );

  Widget _priceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Order getOders) {
    return OutlinedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          arguments: {'provider_id': getOders.provider?.id ?? ""},
          Config.providerOverviewScreen,
        );
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _circleIcon(BuildContext context, IconData icon, Order getOders) {
    return CircleAvatar(
      backgroundColor: Colors.green.shade100,
      child: IconButton(
        icon: Icon(icon, color: Colors.green),
        onPressed: () async {
          final phone = getOders.provider?.phone;
          final email = getOders.provider?.email;

          try {
            if (icon == Icons.phone) {
              // Handle phone call
              if (phone != null && phone.isNotEmpty) {
                final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No dialer app available')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No phone number available')),
                );
              }
            } else if (icon == Icons.email || icon == Icons.chat) {
              // Handle email
              if (email != null && email.isNotEmpty) {
                final Uri emailUri = Uri(scheme: 'mailto', path: email);
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No email app available')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No email available')),
                );
              }
            }
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        },
      ),
    );
  }
}
