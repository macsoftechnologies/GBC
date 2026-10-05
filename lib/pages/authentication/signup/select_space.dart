import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/utils/my_colors.dart';
import '../../../utils/config.dart';

class SelectSpaceScreen extends StatefulWidget {
  const SelectSpaceScreen({super.key});

  @override
  State<SelectSpaceScreen> createState() => _SelectSpaceScreenState();
}

class _SelectSpaceScreenState extends State<SelectSpaceScreen> {
  int? _selectedIndex; // For tracking selected card

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: const Color(0xFFF6FBF7), // same as background
    //   statusBarIconBrightness: Brightness.dark, // dark icons
    // ));
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(

      //extendBodyBehindAppBar: true,// light greenish background
      child: Scaffold(
        backgroundColor: MyColors.backgroundColor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Config.guestHomeScreen,
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: MyColors.appThemeLight,
                      ),
                    ),
                  ),
                ),
              ),
        
              SizedBox(height: screenHeight * 0.04), // Padding above the box
        
              /// Box containing title + cards
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(12),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.grey.withOpacity(0.15),
                //       blurRadius: 6,
                //       spreadRadius: 2,
                //       offset: const Offset(0, 3),
                //     ),
                //   ],
                // ),
                child: Column(
                  children: [
                    /// Title
                    Center(
                      child: Text(
                        "Select your space",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF808080),
                        ),
                      ),
                    ),
        
                    SizedBox(height: screenHeight * 0.03),
        
                    /// Cards
                    buildCard(
                      index: 0,
                      imagePath: "assets/images/houseImg.png",
                      title: "Home Maintenance",
                      subtitle: "Apartment, houses, other residential spaces",
                      subtitleColor: const Color(0xFF808080),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    buildCard(
                      index: 1,
                      imagePath: "assets/images/propertyImg.png",
                      title: "Property Maintenance",
                      subtitle: "Offices, Apt maintenance, other commercial spaces",
                      subtitleColor: const Color(0xFF808080),
                    ),
                  ],
                ),
              ),
        
              const Spacer(),
        
              /// Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    _selectedIndex != null ? Colors.green : Colors.grey[300],
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.018,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _selectedIndex != null
                      ? () {
                    if (_selectedIndex == 0) {
                      Navigator.pushNamed(
                        // ignore: use_build_context_synchronously
                        context,
                        Config.homeRegRouteName,//signUpGuidingRouteName
                      );
                    } else if (_selectedIndex == 1) {
                      Navigator.pushNamed(
                        // ignore: use_build_context_synchronously
                        context,
                        Config.propertyRegRouteName,//signUpGuidingRouteName
                      );
                    }
                  }
                      : null,
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      color: _selectedIndex != null
                          ? Colors.white
                          : Colors.grey[600],
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
        
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard({
    required int index,
    required String imagePath,
    required String title,
    required String subtitle,
    Color backgroundColor = Colors.white,
    Color subtitleColor = Colors.grey,
  }) {
    double deviceHeight = MediaQuery.of(context).size.height;
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        height: deviceHeight * 0.16, // fixed responsive height
        padding: EdgeInsets.symmetric(
          horizontal: deviceHeight * 0.015,
          vertical: deviceHeight * 0.01,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            /// IMAGE → flex 2 with right padding
            Expanded(
              flex: 10,
              child: Padding(
                padding: EdgeInsets.only(right: deviceHeight * 0.015),
                child: Center(
                  child: Image.asset(
                    imagePath,
                    height: deviceHeight * 0.07,
                    width: deviceHeight * 0.07,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            /// TEXT COLUMN → flex 4.5
            Expanded(
              flex: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize:12,
                    ),
                  ),
                  SizedBox(height: deviceHeight * 0.005),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: deviceHeight * 0.016,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),

            /// RADIO BUTTON → flex 1.5
            Expanded(
              flex: 15,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: deviceHeight * 0.03,
                  width: deviceHeight * 0.03,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.grey,
                      width: 1.5,
                    ),
                    color: isSelected ? Colors.green : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: deviceHeight * 0.02,
                  )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
