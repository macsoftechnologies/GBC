import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gobuddy_customer_app/utils/config.dart';

Future<void> handlerBackgroundMessaging(RemoteMessage message) async {
  print('Background Message Title: ${message.notification?.title}');
  print('Background Message Body: ${message.notification?.body}');
  print('Background Payload: ${message.data}');
}

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<String?> getFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('fcm_token');
      if (token == null || token.isEmpty) {
        token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await prefs.setString('fcm_token', token);
        }
      }
      return token;
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
      return null;
    }
  }

  Future<void> initNotifications(BuildContext context) async {
    // Request permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final fcmToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fcmToken");
    if (fcmToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', fcmToken);
    }

    // Background messages
    FirebaseMessaging.onBackgroundMessage(handlerBackgroundMessaging);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground Message Title: ${message.notification?.title}');
      print('Foreground Message Body: ${message.notification?.body}');
      print('Foreground Payload: ${message.data}');

      // Navigate if message has a "screen" key
      if (message.data['screen'] != null) {
        Navigator.pushNamed(context, Config.pushnotificationscreen);
      }
    });

    // When app is opened from terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && initialMessage.data['screen'] != null) {
      Navigator.pushNamed(context, Config.pushnotificationscreen);
    }

    // When app is in background but opened via notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Foreground Message Title: ${message.notification?.title}');
  print('Foreground Message Body: ${message.notification?.body}');
  print('Foreground Payload: ${message.data}');

  // Instead of automatic navigation, show a Snackbar
  if (message.notification != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${message.notification!.title}: ${message.notification!.body}'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            Navigator.pushNamed(context, Config.pushnotificationscreen);
          },
        ),
      ),
    );
  }
});

  }
}
