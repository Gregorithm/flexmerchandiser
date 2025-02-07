import 'dart:convert';
import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:flexmerchandiser/features/screens/outletdetailspage.dart';
import 'package:flexmerchandiser/features/screens/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final bool isDarkModeOn;

  const HomeScreen({super.key, required this.isDarkModeOn});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> outlets = [];
  bool isLoading = true;
  int outletsCount = 0;
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    fetchOutlets();
  }

  Future<void> fetchOutlets() async {
    //final String userId = '309731';
    final String userId = userController.userId.value;
    if (userId.isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID is empty!")),
      );
      return;
    }

    final String url =
        "https://bookings.flexpay.co.ke/api/merchandizer/outlets";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"]) {
          if (mounted) {
            setState(() {
              outlets = data["data"];
              outletsCount = outlets.length;
              isLoading = false;
            });
          }
        } else {
          throw Exception("Failed to load outlets.");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching outlets: $e")),
      );
    }
  }

  String getOutletImage(String outletName) {
    if (outletName.startsWith("Quickmart")) {
      return "assets/images/dashboardimages/Quickmart.png";
    } else if (outletName.startsWith("Naivas")) {
      return "assets/images/dashboardimages/Naivas.png";
    } else if (outletName.startsWith("Car and General")) {
      return "assets/images/dashboardimages/Car-and-General.png";
    } else {
      return "assets/images/dashboardimages/Default.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Chama.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03, vertical: screenHeight * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()),
                          );
                        },
                        child: CircleAvatar(
                          radius: screenWidth * 0.06,
                          backgroundImage:
                              AssetImage('assets/icon/userprofile.png'),
                        ),
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
                  Icon(Icons.notifications,
                      color: Colors.white, size: screenWidth * 0.08),
                ],
              ),
              SizedBox(height: screenHeight * 0.16),
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
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.06),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : outlets.isEmpty
                        ? Center(
                            child: Text(
                              "No outlets available.",
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                color: widget.isDarkModeOn
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              SizedBox(height: 40.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Outlets Category',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    Icons.grid_view,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 3 / 4,
                                    ),
                                    itemCount: outlets.length,
                                    itemBuilder: (context, index) {
                                      final outlet = outlets[index];
                                      String imageUrl =
                                          getOutletImage(outlet["outlet_name"]);

                                      return _buildCategoryCard(
                                        context,
                                        title: outlet["outlet_name"],
                                        subtitle: outlet["location_name"] ??
                                            "Tap to view",
                                        backgroundImage: imageUrl,
                                        outletId: outlet["id"].toString(),
                                      );
                                    },
                                  ),
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

  Widget _buildCategoryCard(BuildContext context,
      {required String title,
      required String subtitle,
      required String backgroundImage,
      required String outletId}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OutletDetailsPage(outletId: outletId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(subtitle,
                      style: GoogleFonts.montserrat(
                          fontSize: 14, color: Colors.white54)),
                ],
              ),
            ),
            Positioned(
                top: 16,
                right: 16,
                child:
                    Icon(Icons.arrow_outward, color: Colors.white, size: 24)),
          ],
        ),
      ),
    );
  }
}
