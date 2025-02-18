import 'dart:convert';
import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:flexmerchandiser/features/screens/monthlyonboardedcustomers.dart';
import 'package:flexmerchandiser/features/screens/navbar.dart';
import 'package:flexmerchandiser/features/screens/outletdetailspage.dart';
import 'package:flexmerchandiser/features/screens/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedMonthIndex = DateTime.now().month - 1;
  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  List<dynamic> outlets = [];
  bool isLoading = true;
  int outletsCount = 0;
  late UserController userController;

  @override
  void initState() {
    super.initState();
    userController = Get.find<UserController>(); // Initialize inside initState
    fetchOutlets();
  }

  Future<void> fetchOutlets() async {
    final String userId = userController.userId?.value ?? '';
    if (userId.isEmpty) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;
  final double appBarHeight = screenHeight * 0.25; // 25% of screen height

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 10,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/appbarbackground.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          toolbarHeight: 330,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        backgroundImage:
                            AssetImage("assets/icon/userprofile.png"),
                        radius: 22,
                      ),
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, Merchandiser",
                          style: GoogleFonts.montserrat(
                              fontSize: 16, color: Colors.white),
                        ),
                        Text(
                          "Welcome Back",
                          style: GoogleFonts.montserrat(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
           //add aditional icon
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(150),
            child: Column(
              children: [
                /// **Customer Conversion & Growth Section (Above the Month Selector)**
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: _buildCardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Customer Conversion", style: _titleStyle()),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(7, (index) {
                            return CircleAvatar(
                              backgroundColor:
                                  index < 5 ? Colors.orange : Colors.grey[300],
                              child: Icon(Icons.check, color: Colors.white),
                            );
                          }),
                        ),
                        SizedBox(height: 10),
                        Text("🔥 What a streak! Keep it going every day.",
                            style: _highlightStyle()),
                        Divider(
                            thickness: 1, height: 30, color: Colors.grey[300]),
                        Text("Your Growth this Week", style: _subtitleStyle()),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            _buildProgressIndicator(
                                Colors.blue, outletsCount.toString(), "Outlets Number"),
                            SizedBox(width: 10),
                            _buildProgressIndicator(
                                Colors.green, "44", "Flexchama customers"),
                            SizedBox(width: 10),
                            _buildProgressIndicator(
                                Colors.red, "29", "Not in Flexchama"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10),

                /// **Month Selector (Moved Below Customer Conversion)**
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(months.length, (index) {
                      bool isSelected = index == selectedMonthIndex;
                      return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OnboardedCustomersPage(
                          selectedMonth: months[index], 
                          monthIndex: index,
                        ),
                      ),
                    );
                  },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 7, vertical: 10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Text(
                            months[index],
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                SizedBox(height: 10),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
/// **Outlets Section**
_buildCardContainer(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("To get you started", style: _titleStyle()),
      Text("Here are Outlets we picked just for you", style: _textStyle()),
      SizedBox(height: 10),
      isLoading
          ? Center(child: CircularProgressIndicator())
          : outlets.isEmpty
              ? Center(
                  child: Text(
                    "No outlets available.",
                    style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3 / 4, // Controls aspect ratio of cards
                  ),
                  itemCount: outlets.length,
                  itemBuilder: (context, index) {
                    final outlet = outlets[index];
                    String imageUrl = getOutletImage(outlet["outlet_name"]);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OutletDetailsPage(
                              outletId: outlet["id"].toString(), description: '',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(imageUrl),
                            fit: BoxFit.cover, // Ensures image fills entire card
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Dark gradient overlay for text readability
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),

                            // Outlet name and location at the bottom
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(
                              outlet["outlet_name"] ?? "Unknown Outlet",
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              outlet["location_name"] ?? "Unknown Location",
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),                              
                            ],
                              ),
                            ),

                            // Arrow icon at the top-right
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Icon(
                                Icons.arrow_outward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    ],
  ),
),
],
),
),
);
          
  }
}

/// **Reusable Card Container**
Widget _buildCardContainer({required Widget child}) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
}

/// **Progress Indicator**
Widget _buildProgressIndicator(Color color, String value, String label) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value,
            style: GoogleFonts.montserrat(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: _textStyle()),
      ],
    ),
  );
}



/// **Text Styles**
TextStyle _titleStyle() =>
    GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold);
TextStyle _subtitleStyle() =>
    GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold);
TextStyle _textStyle() =>
    GoogleFonts.montserrat(fontSize: 14, color: Colors.black54);
TextStyle _highlightStyle() =>
    GoogleFonts.montserrat(fontSize: 14, color: Colors.orange);

Widget _buildOutletsCard(BuildContext context,
    {required String title,
    required String subtitle,
    required String backgroundImage,
    required String outletId}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OutletDetailsPage(outletId: outletId, description: '',),
        ),
      );
    },
    child: Container(
      height: 200, // Adjust height to match the design
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Dark gradient overlay for better text contrast
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // Outlet name and location at the bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
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
                        fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),

          // Arrow icon at the top-right
          Positioned(
            top: 16,
            right: 16,
            child: Icon(Icons.arrow_outward, color: Colors.white, size: 24),
          ),
        ],
      ),
    ),
  );
}