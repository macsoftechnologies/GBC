

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:gobuddy_customer_app/api/firebase_api.dart';
// import 'package:gobuddy_customer_app/routes/my_app_route.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   // Do NOT call initNotifications here with context
//   runApp(const MyApp());
// }


// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     // Safe to call initNotifications here because context exists
//     FirebaseApi().initNotifications(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const MyAppRoute(); // Your existing routes widget
//   }
// }



import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gobuddy_customer_app/pages/authentication/login/login_screen.dart';
import 'package:gobuddy_customer_app/pages/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gobuddy_customer_app/api/firebase_api.dart';
import 'package:gobuddy_customer_app/routes/my_app_route.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Do NOT call initNotifications here with context
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Safe to call initNotifications here because context exists
    FirebaseApi().initNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    return const MyAppRoute(); // Your existing routes widget
  }
}

// ─── Decides whether to show Home or Login on app start ─────────────
class SessionDecider extends StatelessWidget {
  const SessionDecider({super.key});

 Future<bool> _isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final loggedIn = prefs.getBool('is_logged_in') ?? false;
  debugPrint("🔍 SESSION CHECK ON APP START — is_logged_in = $loggedIn");
  return loggedIn;
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final loggedIn = snapshot.data ?? false;
        return loggedIn ?  HomeMainScreen() :   LoginScreen();
      },
    );
  }
}
