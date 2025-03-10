import 'package:flexmerchandiser/features/screens/existingcustomerchamaonboard/chamaproductspage.dart';
import 'package:flexmerchandiser/features/screens/newcustomerchamaonboard/chamaproducts.dart';
import 'package:flexmerchandiser/features/screens/navigationbar/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:lottie/lottie.dart';

class ChamaType extends StatefulWidget {
  final String phoneNumber;

  ChamaType({required this.phoneNumber});

  @override
  _ChamaTypeState createState() => _ChamaTypeState();
}

class _ChamaTypeState extends State<ChamaType> {
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

    final url =
        Uri.parse("https://www.flexpay.co.ke/users/api/flex-chama/products");
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
          context,
          MaterialPageRoute(
            builder: 
            (context) => 
            ChamaProducts(
              products: data["data"],
              customerPhoneNumber: widget.phoneNumber,
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
    var brightness = Theme.of(context).brightness;
    bool isDarkMode = brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Chamas",
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            children: [
              Lottie.asset(
                "assets/images/chamatype.json",
                height: MediaQuery.of(context).size.height * 0.25,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              Text(
                "Welcome to Chamas",
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Start saving towards your goals with our wide range of products.",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),
              Text(
                "Choose your product.",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSelectableIcon(Icons.calendar_month, "Half-Yearly",
                      "half_yearly", isDarkMode),
                  SizedBox(width: 30),
                  _buildSelectableIcon(
                      Icons.group, "Yearly", "yearly", isDarkMode),
                ],
              ),
              SizedBox(height: 35),
              ElevatedButton(
                onPressed: isLoading ? null : _fetchChamaProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF337687),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Proceed with Chama",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBarWidget(),
      ),
    );
  }

  Widget _buildSelectableIcon(
      IconData icon, String label, String type, bool isDarkMode) {
    bool isSelected = selectedType == type;

    return GestureDetector(
      onTap: () => _selectType(type),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.blue
                  : (isDarkMode ? Colors.grey[800] : Colors.white),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.orange,
                width: 3,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isDarkMode ? Colors.white70 : Color(0xFF337687)),
              size: 30,
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.blue
                  : (isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
