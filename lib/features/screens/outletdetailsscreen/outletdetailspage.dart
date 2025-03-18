import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:flexmerchandiser/features/screens/outletdetailsscreen/customerdetails.dart';
import 'package:flexmerchandiser/features/screens/outletdetailsscreen/shimmer_customerrow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class OutletDetailsPage extends StatefulWidget {
  final String outletId;
  final String description;

  OutletDetailsPage(
      {super.key, required this.outletId, required this.description});

  @override
  _OutletDetailsPageState createState() => _OutletDetailsPageState();
}

class _OutletDetailsPageState extends State<OutletDetailsPage> {
  List<dynamic> outletDetails = [];
  List<dynamic> filteredDetails = [];
  bool isLoading = true;
  final UserController userController =
      Get.find<UserController>(); // Injecting the UserController
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  final List<String> statusOptions = [
    "NOT CALLED",
    "NOT ANSWERED",
    "ANSWERED",
    "CALL BACK LATER",
    "RESTRICTED",
    "UNREACHABLE",
    "NOT EXIST",
    "BUSY",
    "NOT IN SERVICE"
  ];

  @override
  void initState() {
    super.initState();
    fetchOutletDetails();
    _searchController.addListener(_filterCustomers);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

void _filterCustomers() {
  final query = _searchController.text.trim();

  if (query.isEmpty) {
    setState(() {
      filteredDetails = outletDetails;
    });
  } else {
    setState(() {
      // Apply search on the formatted "07" phone numbers
      filteredDetails = outletDetails.where((customer) {
        // Ensure phone is a string and apply the same transformation used in the UI
        final phone = customer["phone"]?.toString().replaceFirst("254", "80") ?? "N/A";
        final status = customer["status"]?.toString().toLowerCase() ?? "";
        final name = customer["customer_name"]?.toString().toLowerCase() ?? "";

        // Search using the formatted phone number
        return phone.contains(query) || status.contains(query) || name.contains(query);
      }).toList();
    });
  }
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool hasNextPage = true;
  int currentPage = 1;
  final int itemsPerPage = 10;


  
Future<void> fetchOutletDetails() async {
  setState(() {
    isLoading = true;
  });

  const String url = "https://bookings.flexpay.co.ke/api/merchandizer/customers";
  final Map<String, dynamic> requestBody = {
    "user_id": userController.userId.value,
    "outlet_id": int.parse(widget.outletId),
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        ...requestBody,
        "page": currentPage,
        "per_page": itemsPerPage,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["success"] == true) {
        List<dynamic> pageData = data["data"]["data"] ?? [];

        setState(() {
          outletDetails = pageData.map((customer) {
            customer["phone"] = (customer["phone"] ?? "");
            customer["status"] = customer["customer_followup"]?["status"] ?? "NOT CALLED";
            customer["description"] = (customer["customer_followup"]?["description"] ?? "") ?? "";
            customer["flexsave"] = customer["is_flexsave_customer"] == 1 ? "Yes" : "No";
            return customer;
          }).toList();

          filteredDetails = outletDetails;
          hasNextPage = pageData.length == itemsPerPage;
        });
      }
    }
  } catch (e) {
    Get.snackbar("Error", "Failed to fetch data: $e");
  }

  setState(() {
    isLoading = false;
  });
}

  // Update page and fetch data when user presses Next/Previous
  void changePage(int delta) {
    setState(() {
      currentPage += delta;
      outletDetails.clear(); // Clear current data to replace with new page data
    });
    fetchOutletDetails();
  }

  Future<void> _initiatePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch dialer with number $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/images/appbarbackground.png"),
            fit: BoxFit.cover,
          )),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Flexpay',
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: isLoading
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                "Check out your Outlet details here",
                                style: GoogleFonts.montserrat(
                                  fontSize: screenWidth * 0.06,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              _buildSearchBar(screenWidth, _searchController, context),
                              SizedBox(height: screenHeight * 0.01),
                              // Pagination controls
                              if (hasNextPage || currentPage > 1)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.0011),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (currentPage > 1)
                                        TextButton(
                                          onPressed: () => changePage(-1),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.arrow_back,
                                                color: Colors.white,
                                                size: screenWidth * 0.04,
                                              ),
                                              SizedBox(
                                                  width: screenWidth *
                                                      0.01), // Space between icon and text
                                              Text(
                                                'Previous',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: screenWidth * 0.04,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (hasNextPage)
                                        TextButton(
                                          onPressed: () => changePage(1),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Next Page',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: screenWidth * 0.04,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: screenWidth *
                                                      0.01), // Space between text and icon
                                              Icon(
                                                Icons.arrow_forward,
                                                color: Colors.blue,
                                                size: screenWidth * 0.04,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              // Page indicators
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.001),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Page $currentPage',
                                      style: GoogleFonts.montserrat(
                                        fontSize: screenWidth * 0.04,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildCustomerList(context, screenWidth, isLoading, outletDetails), // Now shows shimmer effect
                      ],
                        ),
                      ],
                    ): outletDetails.isEmpty
                        ? Center(
                            child: Text(
                              "No customer details found.",
                              style: GoogleFonts.montserrat(
                                fontSize: screenWidth * 0.05,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                "Check out your Outlet details here",
                                style: GoogleFonts.montserrat(
                                  fontSize: screenWidth * 0.06,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              _buildSearchBar(screenWidth, _searchController, context),
                              SizedBox(height: screenHeight * 0.01),
                              // Pagination controls
                              if (hasNextPage || currentPage > 1)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.0011),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (currentPage > 1)
                                        TextButton(
                                          onPressed: () => changePage(-1),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.arrow_back,
                                                color: Colors.white,
                                                size: screenWidth * 0.04,
                                              ),
                                              SizedBox(
                                                  width: screenWidth *
                                                      0.01), // Space between icon and text
                                              Text(
                                                'Previous',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: screenWidth * 0.04,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (hasNextPage)
                                        TextButton(
                                          onPressed: () => changePage(1),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Next Page',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: screenWidth * 0.04,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: screenWidth *
                                                      0.01), // Space between text and icon
                                              Icon(
                                                Icons.arrow_forward,
                                                color: Colors.blue,
                                                size: screenWidth * 0.04,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              // Page indicators
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.001),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Page $currentPage',
                                      style: GoogleFonts.montserrat(
                                        fontSize: screenWidth * 0.04,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh:
                                      fetchOutletDetails, // Calls the function to refresh data
                                  child: ListView.builder(
                                    itemCount: filteredDetails.length,
                                    itemBuilder: (context, index) {
                                      final customer = filteredDetails[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CustomerDetailsPage(
                                                customer: customer,
                                                customerId: customer["id"] !=
                                                        null
                                                    ? int.parse(customer["id"]
                                                        .toString())
                                                    : 0,
                                                description: customer[
                                                            "customer_followup"]
                                                        ?["description"] ??
                                                    "",
                                              ),
                                            ),
                                          );
                                        },
                                        child: _buildCustomerRow(context, customer, screenWidth),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _selectedIndex == index
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 28,
          color: _selectedIndex == index ? Colors.amber : Colors.white60,
        ),
      ),
    );
  }
}
Widget _buildCustomerList(BuildContext context, double screenWidth, bool isLoading, dynamic outletDetails) {
  return isLoading
      ? Column(
          children: List.generate(1, (index) => ShimmerCustomerRow(screenWidth: screenWidth)),
        )
      : Column(
          children: outletDetails.map<Widget>((customer) => _buildCustomerRow(context, customer, screenWidth)).toList(),
        );
}

Widget _buildCustomerRow(BuildContext context, Map<String, dynamic> customer, double screenWidth) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
    padding: EdgeInsets.all(screenWidth * 0.04),
    decoration: BoxDecoration(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        // Left Section - Customer Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer["customer_name"] ?? "N/A",
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
              // Flexsave Status with Color Change
              Text(
                customer["flexsave"] == "Yes" ? "Yes" : "No",
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: customer["flexsave"] == "Yes" ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: screenWidth * 0.005),
              Text(
                customer["date_created"] ?? "N/A",
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.035,
                  color: isDarkMode ? Colors.grey[400] : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        // Right Section - Status Dropdown + Phone Number
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: screenWidth * 0.005),
            Text(
              customer["status"] ?? "N/A",
              style: GoogleFonts.montserrat(
                fontSize: screenWidth * 0.035,
                color: isDarkMode ? Colors.grey[400] : Colors.black54,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            // Phone Number Below Dropdown
            GestureDetector(
              onTap: () => (customer["phone"]),
              child: Text(
                customer["phone"]?.toString().replaceFirst("254", "80") ?? "N/A",
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.04,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


Widget _buildSearchBar(
    double screenWidth, TextEditingController searchController, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Container(
    height: screenWidth * 0.13,
    decoration: BoxDecoration(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      borderRadius: BorderRadius.circular(25.0),
      boxShadow: isDarkMode
          ? []
          : [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5.0,
                spreadRadius: 2.0,
                offset: Offset(0, 3),
              ),
            ],
    ),
    child: Row(
      children: [
        const SizedBox(width: 10),
        Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Search for phone number here",
              hintStyle: GoogleFonts.montserrat(
                fontSize: screenWidth * 0.04,
                color: isDarkMode ? Colors.white54 : Colors.grey,
              ),
            ),
            style: GoogleFonts.montserrat(
              fontSize: screenWidth * 0.04,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(Icons.grid_view, color: isDarkMode ? Colors.white70 : Colors.grey),
        const SizedBox(width: 10),
      ],
    ),
  );
}

