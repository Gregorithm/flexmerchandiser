import 'package:flexmerchandiser/features/controllers/authcontroller.dart';
import 'package:flexmerchandiser/features/screens/homescreen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final authController = Get.find<AuthController>();

    // Detect current theme mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: screenWidth * 0.6,
      child: Container(
        color:  const Color(0xFF337687), // Background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),

            // Sidebar Menu Items
           buildMenuItem(Icons.home, 'Home', () => Get.to(HomeScreen()), isDarkMode),

            const Spacer(),


            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Reusable function for sidebar items with custom onTap
  Widget buildMenuItem(IconData icon, String text, VoidCallback onTap, bool isDarkMode) {
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black54),
      title: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 18,
          color: isDarkMode ? Colors.white : Colors.white70,
        ),
      ),
      onTap: onTap,
    );
  }
}