import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/models/notifications_model.dart';
import 'package:gobuddy_customer_app/services/end_points.dart';
import 'package:gobuddy_customer_app/services/repository.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import 'package:gobuddy_customer_app/utils/util_class.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _SelectNotificationsScreenState();
}

class _SelectNotificationsScreenState extends State<NotificationsScreen> {
  String? userId;
  GetNotificationsModel? pushintoNotificationModel;
  List<Data> notificationsData = [];
  bool isLoading = true;
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasLoaded) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        userId = args['user_id']?.toString();
        debugPrint("User ID received in Notification Screen = $userId");
      }
      _hasLoaded = true;
      _getNotificationsByUserId();
    }
  }

  Future<void> _getNotificationsByUserId() async {
    bool internet = await UtilClass.checkInternet();

    if (!internet) {
      UtilClass.showAlertDialog(
          context: context, message: "No Internet Connection");
      return;
    }

    try {
      final response = await Repository.NewPostApiService(
          EndPoints.getNotificationByUserId, {'user_id': userId ?? ""});

      late Map<String, dynamic> jsonResponse;

      if (response is String) {
        jsonResponse = json.decode(response as String);
      } else if (response is Map<String, dynamic>) {
        jsonResponse = response;
      }

      if (jsonResponse["status"] == "success") {
        print(jsonResponse);
        pushintoNotificationModel =
            GetNotificationsModel.fromJson(jsonResponse);

        setState(() {
          notificationsData = pushintoNotificationModel?.data ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      UtilClass.showAlertDialog(
          context: context, message: "Internal Server Error $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // ⭐ REUSABLE NOTIFICATION CARD UI
  Widget buildNotificationCard(Data item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 3)),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON + STATUS BADGE
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MyColors.appThemeLight.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active,
                color: Colors.blue, size: 28),
          ),

          const SizedBox(width: 12),

          // TEXT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE
                Text(
                  item.title ?? "No Title",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),

                const SizedBox(height: 4),

                // SUBTITLE
                Text(
                  item.subtitle ?? "",
                  style: const TextStyle(color: Colors.black87),
                ),

                const SizedBox(height: 8),

                // SERVICE NAME
                if (item.serviceName != null)
                  Text(
                    "Service: ${item.serviceName}",
                    style: const TextStyle(
                        fontSize: 13, color: Colors.grey),
                  ),

                // AMOUNT
                if (item.amount != null)
                  Text(
                    "Amount: \u20B9${item.amount}",
                    style: const TextStyle(
                        fontSize: 13, color: Colors.green),
                  ),

                const SizedBox(height: 8),

                // DATE
                Text(
                  item.dateTime ?? "",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.appThemeLight,
        title: const Text("Notifications",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white)),
      ),

      // ⭐ BODY
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : RefreshIndicator(
              onRefresh: _getNotificationsByUserId,
              child: notificationsData.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Text(
                            "No Notifications Found",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: notificationsData.length,
                      itemBuilder: (context, index) {
                        return buildNotificationCard(notificationsData[index]);
                      },
                    ),
            ),
    );
  }
}
