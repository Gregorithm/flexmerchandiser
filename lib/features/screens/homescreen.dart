import 'dart:convert';
import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:flexmerchandiser/features/screens/appbarhome.dart';
import 'package:flexmerchandiser/features/screens/outletdetailspage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
  int outletsCount = 0; // Variable to store the number of outlets
  final UserController userController = Get.find <UserController>();

  @override
  void initState() {
    super.initState();
    fetchOutlets();
  }

  Future<void> fetchOutlets() async {
    final String userId = userController.userId.value; // Get the user ID from the controller
    //const  String userId = "309731"; // Replace with dynamic user ID after login
    if (userId .isEmpty){
      print("User ID is empty");
    }
    const String url =
        "https://bookings.flexpay.co.ke/api/merchandizer/outlets";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {"user_id": userId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"]) {
          if (mounted) {
            setState(() {
              outlets = data["data"];
              outletsCount = outlets.length; // Set the number of outlets
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

  // Function to map outlet name to image URL
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
    return Scaffold(
      backgroundColor: widget.isDarkModeOn ? Colors.black : Colors.white,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(490.0),
          child: appBarHome(
              context, outletsCount, outlets) // Assuming appBarHome is defined
          ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : outlets.isEmpty
              ? Center(
                  child: Text(
                    "No outlets available.",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: widget.isDarkModeOn ? Colors.white : Colors.black,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Outlets Category',
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: widget.isDarkModeOn
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            Icon(
                              Icons.grid_view,
                              color: widget.isDarkModeOn
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Generate cards dynamically
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                              subtitle:
                                  outlet["location_name"] ?? "Tap to view",
                              backgroundImage:
                                  imageUrl, // Replace with a dynamic image URL if available
                              outletId: outlet["id"].toString(),
                            );
                          },
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
        // Navigate to the outlet details page and pass the outletId
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
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkModeOn ? Colors.white : Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color:
                          widget.isDarkModeOn ? Colors.white60 : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Icon(
                Icons.arrow_outward,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
