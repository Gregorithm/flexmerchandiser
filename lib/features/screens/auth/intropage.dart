
import 'package:flexmerchandiser/features/screens/auth/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Set a base font size for responsiveness
    double fontSize = screenWidth * 0.08; // Adjust this factor to your preference

    return Scaffold(
      backgroundColor: Color(0xFF337687),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06), // Responsive padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05), // Responsive space
              Row(
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.02, // Scalable radius
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(width: screenWidth * 0.02), // Responsive spacing
                  Text(
                    'lipiapolepole',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Montserrat",
                      fontSize: fontSize * 0.60, // Scalable font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.2), // Responsive space
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: fontSize, // Scalable font size
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(text: "Get ready to ",
                    style: TextStyle(fontSize: fontSize * 1.2), // Scalable font size
                    ),
                    
                    TextSpan(
                      text: "supercharge your goal-",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize * 1.3, // Scalable font size
                        height: 1.3,
                      ),
                    ),
                    TextSpan(
                      text: "\nsetting and\nplanning with\nFlexPay app.",
                      style: TextStyle(
                        fontSize: fontSize * 1.2, // Scalable font size 
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => LoginScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF337687),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.28, // Responsive padding
                    vertical: screenHeight * 0.025, // Responsive vertical padding
                  ),
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: fontSize * 0.6, // Scalable font size for button
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03), // Responsive space
            ],
          ),
        ),
      ),
    );
  }
}