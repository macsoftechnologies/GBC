import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/config.dart';
import '../../utils/session_manager.dart';
import '../../data/prefernces.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  int step = 0;

  late AnimationController _logoController;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _startSequence();
  }

  void _startSequence() async {

    await Future.delayed(const Duration(seconds: 2));
    setState(() => step = 1);

    await Future.delayed(const Duration(seconds: 2));
    setState(() => step = 2);

    await Future.delayed(const Duration(seconds: 3));
    setState(() => step = 3);

    _logoController.forward();

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final loggedIn = await SessionManager.isLoggedIn();
      if (loggedIn) {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('user_id') ?? await Preferences.getUserID() ?? '';
        Navigator.pushReplacementNamed(
          context,
          Config.homeRouteName,
          arguments: {
            "user_id": userId,
          },
        );
      } else {
        Navigator.pushReplacementNamed(context, Config.onBoardRouteName);
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  /// Responsive full screen image
  Widget serviceScreen(String image, ) {

    final size = MediaQuery.of(context).size;

    return SizedBox(
      
      width: size.width,
      height: size.height,
      child: Stack(
        children: [

          /// Background Image
          Positioned.fill(
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),

          // /// Title
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Positioned(
          //     bottom: size.height * 0.08,
          //     left: 0,
          //     right: 0,
          //     child: Center(
          //       child:
          //        Text(
              
          //         textAlign: TextAlign.center,
          //         style: TextStyle(
          //           fontSize: size.width * 0.07,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.white,
          //           letterSpacing: 1.2,
          //           shadows: const [
          //             Shadow(
          //               color: Colors.black,
          //               blurRadius: 10,
          //             )
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
     
     
     
        ],
      ),
    );
  }

  /// Final Gobuddy Screen
  Widget gobuddyFinal() {

    final size = MediaQuery.of(context).size;

    return SizedBox(
      key: const ValueKey("gobuddy"),
      width: size.width,
      height: size.height,
      child: Center(
        child: ScaleTransition(
          scale: _logoScale,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                "Powered by",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 20),

              Image.asset(
                "assets/images/gobuddyText.png",
                width: size.width * 0.55,
              ),

              const SizedBox(height: 15),

              const Text(
                "CHERISH YOUR SPACE",
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContent() {

    switch (step) {

      case 0:
        return serviceScreen(
          "assets/images/aa.jpeg"
         
        );

      case 1:
        return serviceScreen(
          "assets/images/pl.jpeg"
         
        );

      case 2:
        return serviceScreen(
          "assets/images/hc.jpeg"
        );

      default:
        return gobuddyFinal();
    }
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) {

              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );

            },
            child: buildContent(),
          ),
        ),
      ),
    );
  }
}