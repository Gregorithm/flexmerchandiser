import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar appBarHome(BuildContext context, int outletsCount, List<dynamic> outlets) {
  // Get screen dimensions
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return AppBar(
    elevation: 0,
    automaticallyImplyLeading: false,
    toolbarHeight: screenHeight * 0.25, // Increased height for better image visibility
    flexibleSpace: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/flex2.png'), // Ensure this image exists
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.3), // Overlay for better readability
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.06), // Space for status bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.06,
                      backgroundImage: AssetImage('assets/icon/userprofile.png'), // Replace with actual user profile image
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello Merchandiser,',
                          style: GoogleFonts.montserrat(
                            fontSize: screenWidth * 0.04,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.montserrat(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: screenWidth * 0.08,
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.17),
            Center(
              child: Column(
                children: [
                  Text(
                    '$outletsCount',
                    style: GoogleFonts.montserrat(
                      fontSize: screenWidth * 0.18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Your Outlets',
                    style: GoogleFonts.montserrat(
                      fontSize: screenWidth * 0.05,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}