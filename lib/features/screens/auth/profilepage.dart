import 'package:flexmerchandiser/features/controllers/authcontroller.dart';
import 'package:flexmerchandiser/features/screens/auth/loginscreen.dart';
import 'package:flexmerchandiser/features/service/database_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  // You need to pass the current logged-in user's ID
  final String userId;

  ProfilePage({required this.userId});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    double fontSize = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: const Color(0xFF337687),
      appBar: AppBar(
        backgroundColor: const Color(0xFF337687),
        title: Row(
          children: [
            CircleAvatar(
              radius: screenWidth * 0.02,
              backgroundColor: Colors.white,
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'lipiapolepole',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: fontSize * 0.60,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: screenWidth * 0.10,
                backgroundImage: const AssetImage('assets/icon/userprofile.png'),
              ),
              const SizedBox(height: 16),
              Text(
                "Goodbye Merchandiser,", // Optionally pass user name here
                style: GoogleFonts.montserrat(
                  fontSize: 23,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.montserrat(
                    fontSize: fontSize,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(
                      text: "Log out to keep \nyour",
                      style: GoogleFonts.montserrat(
                        fontSize: fontSize * 1.2,
                      ),
                    ),
                    TextSpan(
                      text: " account secure",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize * 1.3,
                        height: 1.3,
                      ),
                    ),
                    TextSpan(
                      text: "\nand sign in again\n",
                      style: GoogleFonts.montserrat(
                        fontSize: fontSize * 1.2,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40.0),
              ElevatedButton(
              onPressed: () async {
                  await authController.logoutUser(userId);

                  // Clear navigation stack and go to LoginScreen
                  Get.offAll(() => LoginScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF337687),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.18,
                    vertical: screenHeight * 0.010,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.logout,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'Log Out',
                      style: GoogleFonts.montserrat(
                        fontSize: fontSize * 0.6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}