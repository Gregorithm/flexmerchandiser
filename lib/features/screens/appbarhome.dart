import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar appBarHome(BuildContext context, int outletsCount, List<dynamic> outlets) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  // Set colors based on the theme
  final backgroundColor = isDarkMode ? Colors.black : const Color(0xFF337687);
  final chipBackgroundColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];
  final chipTextColor = isDarkMode ? Colors.white : Colors.black;
  final searchBarColor = isDarkMode ? Colors.grey[850] : Colors.grey[200];
  final iconColor = isDarkMode ? Colors.white70 : Colors.grey[600];

  // Get screen dimensions
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  // Search controller
  TextEditingController searchController = TextEditingController();

  // Filtered outlets based on search input
  List<dynamic> filteredOutlets = outlets;

  // Function to update filtered outlets based on search query
  void updateSearchResults(String query) {
    if (query.isEmpty) {
      filteredOutlets = outlets; // Reset to all outlets if search is empty
    } else {
      filteredOutlets = outlets.where((outlet) {
        return outlet['outlet_name']
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    }
  }

  return AppBar(
    backgroundColor: backgroundColor,
    elevation: 0,
    automaticallyImplyLeading: false,
    toolbarHeight: screenHeight * 0.1, // Dynamically set height (40% of screen height)
    flexibleSpace: Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.04, // 5% of screen height
        horizontal: screenWidth * 0.04, // 5% of screen width
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row: Profile, Greeting, and Notification Icon
          SizedBox(height: screenHeight * 0.06),
          Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.05, // Adjust radius dynamically
                backgroundImage:
                    const AssetImage('assets/icon/userprofile.png'),
              ),
              SizedBox(width: screenWidth * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello Merchandiser,',
                    style: GoogleFonts.montserrat(
                      fontSize: screenWidth * 0.04, // Scale font size
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
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
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.02),
                child: Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: screenWidth * 0.08,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.03),

          // Second Row: Large Number and 'Your outlets' Text
          Center(
            child: Column(
              children: [
                Text(
                  '$outletsCount',
                  style: GoogleFonts.montserrat(
                    fontSize: screenWidth * 0.15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Your outlets',
                  style: GoogleFonts.montserrat(
                    fontSize: screenWidth * 0.04,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.04),

          // Third Row: Search Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: searchBarColor,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: screenWidth * 0.03),
                      Icon(Icons.grid_view, color: iconColor),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: (query) {
                            updateSearchResults(query);
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Spotlight Search",
                            hintStyle: GoogleFonts.montserrat(
                              fontSize: screenWidth * 0.04,
                              color: iconColor,
                            ),
                          ),
                          style: GoogleFonts.montserrat(
                            fontSize: screenWidth * 0.04,
                            color: chipTextColor,
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Icon(Icons.grid_view, color: iconColor),
                      SizedBox(width: screenWidth * 0.03),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),

          // Scrollable Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                    "Near me", true, isDarkMode, chipBackgroundColor),
                _buildFilterChip(
                    "Outlets", false, isDarkMode, chipBackgroundColor),
                _buildFilterChip(
                    "Customers", false, isDarkMode, chipBackgroundColor),
                _buildFilterChip(
                    "Merchandisers", false, isDarkMode, chipBackgroundColor),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Helper function to create FilterChip
Widget _buildFilterChip(
    String label, bool selected, bool isDarkMode, Color? chipBackgroundColor) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5.0),
    child: FilterChip(
      label: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 14.0,
          color: selected ? Colors.white : Colors.black,
        ),
      ),
      selected: selected,
      onSelected: (value) {},
      selectedColor: isDarkMode ? Colors.white : Colors.black,
      backgroundColor: chipBackgroundColor,
    ),
  );
}