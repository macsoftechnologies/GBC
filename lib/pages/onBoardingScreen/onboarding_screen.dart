import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/utils/config.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _shadowAnimation = Tween<double>(begin: 8, end: 25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildButton({
    required String text,
    required VoidCallback onPressed,
    bool filled = true,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(
                  colors: [Color(0xff00c853), Color(0xff2e7d32)],
                )
              : null,
          color: filled ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: filled
              ? null
              : Border.all(color: Colors.green, width: 1.5),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: filled ? Colors.white : Colors.green,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            const Spacer(),

            /// Animated GoBuddy Logo
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.35),
                          blurRadius: _shadowAnimation.value,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/logoImg.png",
                        width: screenWidth * 0.32,
                        height: screenWidth * 0.32,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: screenHeight * 0.02),

            /// GoBuddy Text Logo
            Image.asset(
              "assets/images/gobuddyText.png",
              width: screenWidth * 0.45,
            ),

            const Spacer(),

            /// Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                children: [

                  /// Sign Up
                  buildButton(
                    text: "Sign Up",
                    filled: true,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Config.welcomeScreenRouteName,
                      );
                    },
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  /// Login
                  buildButton(
                    text: "Login",
                    filled: false,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Config.loginRouteName,
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.07),
          ],
        ),
      ),
    );
  }
}