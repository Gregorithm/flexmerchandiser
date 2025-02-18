import 'package:flexmerchandiser/features/screens/chamaproductspage.dart';
import 'package:flexmerchandiser/features/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChamaScreen extends StatefulWidget {
  final String phoneNumber; // Accept phoneNumber from RegisterPage

  ChamaScreen({required this.phoneNumber});

  @override
  _ChamaScreenState createState() => _ChamaScreenState();
}

class _ChamaScreenState extends State<ChamaScreen> {
  double screenWidth = 0;
  String? selectedType;
  bool isLoading = false;

  void _selectType(String type) {
    setState(() {
      selectedType = type;
    });
  }

  void _fetchChamaProducts() async {
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a Chama type.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse("https://www.flexpay.co.ke/users/api/flex-chama/products");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization":
            "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczpcL1wvd3d3LmZsZXhwYXkuY28ua2VcL3VzZXJzXC9hcGlcL2xvZ2luIiwiaWF0IjoxNzM3OTk2NTE4LCJleHAiOjYwMDAxNzM3OTk2NDU4LCJuYmYiOjE3Mzc5OTY1MTgsImp0aSI6IjlhWFhuOFZUWTc1Z3FvamEiLCJzdWIiOjIxMTQyMiwicHJ2IjoiODdlMGFmMWVmOWZkMTU4MTJmZGVjOTcxNTNhMTRlMGIwNDc1NDZhYSJ9.RCMsQxDPdowoKt3BPSiXuY25XUmwpX5_3Nnwcq2I8fQ"
      },
      body: jsonEncode({"type": selectedType}),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["success"]) {
        Navigator.pushReplacement(
          context, // Replace the current screen so the user cannot go back
          MaterialPageRoute(
            builder: (context) => ChamaProductsPage(
              products: data["data"],
              phoneNumber: widget.phoneNumber, // Pass phone number
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch products.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${response.statusCode}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false, // Disable the back button
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Chamas",
            style: GoogleFonts.montserrat(
              fontSize: screenWidth * 0.06, // Increased font size
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove the back button
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset(
                "assets/images/happyafricanlogin.png",
                height: 220, // Slightly increased image height
                fit: BoxFit.contain,
              ),
              SizedBox(height: 25),
              Text(
                "Welcome to Chamas",
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.07, // Increased font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                "Start saving towards your goals with our wide range of products.",
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.045, // Increased font size
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),
              Text(
                "Choose your product.",
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.048, // Increased font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),

              // Selectable Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSelectableIcon(Icons.calendar_month, "Half-Yearly", "half_yearly"),
                  SizedBox(width: 40), // Increased spacing
                  _buildSelectableIcon(Icons.group, "Yearly", "yearly"),
                ],
              ),

              SizedBox(height: 35),
              ElevatedButton(
                onPressed: isLoading ? null : _fetchChamaProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF337687),
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 18), // Increased padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Proceed with Chama",
                        style: GoogleFonts.montserrat(
                          fontSize: screenWidth * 0.05, // Increased font size
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
         floatingActionButton: FloatingActionButton(
          onPressed: () => Get.to(HomeScreen()), // Navigate to HomeScreen
          backgroundColor: Colors.teal, // Custom color
          shape: CircleBorder(), // Ensures a perfect circle
          child: Icon(Icons.home, size: 32, color: Colors.white),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked, // Centers the button
        bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(), // Creates a notch effect
            notchMargin: 10.0, // Space around FAB
            child: Container(
              height: 50,
              child: Center(
                child: Text("Tap Home Button to Navigate",
                    style: GoogleFonts.montserrat(
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            ),
      ),
    );
  }

  Widget _buildSelectableIcon(IconData icon, String label, String type) {
    bool isSelected = selectedType == type;

    return GestureDetector(
      onTap: () => _selectType(type),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14), // Increased padding
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.blue : Colors.white,
              border: Border.all(color: isSelected ? Colors.blue : Colors.orange, width: 3),
            ),
            child: Icon(icon, color: isSelected ? Colors.white : Color(0xFF337687), size: 35), // Increased icon size
          ),
          SizedBox(height: 7),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: screenWidth * 0.04, // Increased font size
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}