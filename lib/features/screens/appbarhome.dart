import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar appBarHome(BuildContext context, int outletsCount, List<dynamic> outlets) {
  // Define fixed light mode colors
  const backgroundColor = Color(0xFF337687);
  const chipBackgroundColor = Colors.white;
  const chipTextColor = Colors.black;
  const searchBarColor = Colors.white;
  const iconColor = Colors.black87;

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
      filteredOutlets = outlets;
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
    toolbarHeight: screenHeight * 0.1,
    flexibleSpace: Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.04,
        horizontal: screenWidth * 0.04,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.06),
          Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.05,
                backgroundImage: const AssetImage('assets/icon/userprofile.png'),
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

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("Near me", true, chipBackgroundColor),
                _buildFilterChip("Outlets", false, chipBackgroundColor),
                _buildFilterChip("Customers", false, chipBackgroundColor),
                _buildFilterChip("Merchandisers", false, chipBackgroundColor),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildFilterChip(String label, bool selected, Color chipBackgroundColor) {
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
      selectedColor: Colors.black,
      backgroundColor: chipBackgroundColor,
    ),
  );
}