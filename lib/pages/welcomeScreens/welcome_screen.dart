import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../utils/config.dart';

// 📌 Model class for onboarding pages
class WelcomePageData {
  final List<Color> gradientColors;
  final String imagePath;
  final String title;
  final String subtitle;
  final String buttonText;
  final Color buttonColor;
  final bool showLink;
  final VoidCallback? onLinkTap;

  WelcomePageData({
    required this.gradientColors,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.buttonColor,
    this.showLink = false,
    this.onLinkTap,
  });
}

// 📌 Reusable Onboarding Screen
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // 📌 Onboarding data
  late final List<WelcomePageData> pages = [
    WelcomePageData(
      gradientColors: const [Color(0xFFFFFFFF), Color(0xFF97d194), Color(0xFF5c964a)],
      imagePath: "assets/images/welcomeCleaningImg1.png",
      title: "Trusted and Best-in-class Service Providers",
      subtitle:
      "Reviewed, Background Verified and Skilled Technician catered straight to you to service.",
      buttonText: "Next",
      buttonColor: const Color(0xFF02a335),
    ),
    WelcomePageData(
      gradientColors: const [Color(0xFFFFFFFF), Color(0xFFF28C28), Color(0xFFFF7518)],
      imagePath: "assets/images/welcomeCleaningImg2.png",
      title: "Our Commitment to YOU!",
      subtitle:
      "From routine upkeep to urgent repairs, we are on an un-compromised mission to provide you top-notch experience to cherish. You are in good hands!",
      buttonText: "Next",
      buttonColor: const Color(0xFFFF7518),
    ),
    WelcomePageData(
      gradientColors: const [Color(0xFFFFFFFF), Color(0xFF97d194), Color(0xFF5c964a)],
      imagePath: "assets/images/welcomeCleaningImg3.png",
      title: "Save time & money with subscription-based bundled services!",
      subtitle:
      "Transform your House into Home and discover piece of mind with our subscription packages tailored to fit your needs.",
      buttonText: "Get Started",
      buttonColor: const Color(0xFF02a335),
      showLink: true,
      onLinkTap: () {
        print("Know More clicked!");
        Navigator.pushNamed(
          context,
          Config.signUpGuidingRouteName,//signUpGuidingRouteName
        );
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: pages.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final page = pages[index];
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: page.gradientColors,
                ),
              ),
              child: Column(
                children: [
                  // Top section (Logo + Skip + Image)
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        // Logo
                        Positioned(
                          top: screenHeight * 0.05,
                          left: 0,
                          right: 0,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              "assets/images/logoImg.png",
                              width: screenWidth * 0.2,
                              height: screenWidth * 0.2,
                            ),
                          ),
                        ),
                        // Skip Button
                        Positioned(
                          right: screenWidth * 0.04,
                          top: screenHeight * 0.02,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey, width: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: Size(screenWidth * 0.18, screenHeight * 0.035),
                            ),
                            onPressed: () {
                              _pageController.jumpToPage(pages.length - 1);
                            },
                            child: Text(
                              "SKIP",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // Worker image
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.15),
                            child: ClipRect(
                              child: Image.asset(
                                page.imagePath,
                                height: screenHeight * 0.55,
                                fit: index == 1 ? BoxFit.fitHeight : BoxFit.contain,
                                alignment: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Section
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.08,
                        vertical: screenHeight * 0.03,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            page.title,
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Subtitle
                          page.showLink
                              ? RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(text: page.subtitle),
                                TextSpan(
                                  text: " Know More",
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = page.onLinkTap,
                                ),
                              ],
                            ),
                          )
                              : Text(
                            page.subtitle,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                          const Spacer(),

                          // Indicators + Button
                          Row(
                            children: [
                              // Page indicators
                              Row(
                                children: List.generate(
                                  pages.length,
                                      (dotIndex) => Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    width: _currentIndex == dotIndex ? 20 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _currentIndex == dotIndex
                                          ? page.buttonColor
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),

                              // Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: page.buttonColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.07,
                                    vertical: screenHeight * 0.015,
                                  ),
                                ),
                                onPressed: () {
                                  if (index == pages.length - 1) {
                                    // Navigate to sign up screen when "Get Started" is pressed
                                    Navigator.pushNamed(
                                      context,
                                      Config.signUpGuidingRouteName,
                                    );
                                  } else {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                child: Text(
                                  page.buttonText,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}