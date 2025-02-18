import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:flexmerchandiser/features/screens/customerdetails.dart';
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

  OutletDetailsPage({super.key, required this.outletId, required this.description});

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
          final phone = customer["phone"] ?? "";
          final status = customer["status"].toLowerCase() ?? "";
          final name =
              customer["customer_name"].toLowerCase() ?? ""; // Fixed here
          return phone.contains(query) ||
              status.contains(query) ||
              name.contains(query);
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

  // Fetch customer details with pagination
  Future<void> fetchOutletDetails() async {
    setState(() {
      isLoading = true;
    });

    const String url =
        "https://bookings.flexpay.co.ke/api/merchandizer/customers";
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

      List<int> customerIds = []; // To store the customer IDs

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == true) {
          List<dynamic> pageData = data["data"]["data"] ?? [];

          List<dynamic> formattedPageData = pageData.map((customer) {
            // Format customer data
            customer["phone"] = (customer["phone"] ?? "");
            customer["status"] =
                customer["customer_followup"]?["status"] ?? "NOT CALLED";
           customer["description"] = (customer["customer_followup"]?["description"] ?? "") ?? "";
            customer["flexsave"] =
                customer["is_flexsave_customer"] == 1 ? "Yes" : "No";

            // Add the customer ID to the list
            int customerId = customer["id"];
            customerIds.add(customerId); // Store the customer ID

            print("Fetched Customer ID: $customerId"); // Log the customer ID
            print("Fetched description: ${customer['description']}");

            return customer;
          }).toList();

          setState(() {
            outletDetails = formattedPageData; // Replace old records
            filteredDetails = formattedPageData; // Replace old records
            hasNextPage =
                pageData.length == itemsPerPage; // Check if there's more data
          });
        } else {
          throw Exception('Failed to load customer details');
        }
      } else {
        throw Exception('Failed to load customer details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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

    return Scaffold(
      backgroundColor: const Color(0xFF337687),
      appBar: AppBar(
        backgroundColor: const Color(0xFF337687),
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
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Loading customer details...",
                        style: GoogleFonts.montserrat(
                          fontSize: screenWidth * 0.04,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : outletDetails.isEmpty
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
                        _buildSearchBar(screenWidth, _searchController),
                        SizedBox(height: screenHeight * 0.01),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredDetails.length,
                            itemBuilder: (context, index) {
                              final customer = filteredDetails[index];
                              return GestureDetector(
                                onTap: () {
                                  // Navigate to CustomerDetailsPage with customer details
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CustomerDetailsPage(
                                          customer: customer,
                                          customerId: customer["id"] != null
                                              ? int.parse(
                                                  customer["id"].toString())
                                              : 0,
                                               description: customer["customer_followup"]?["description"] ?? "",
                                               ),
                                          
                                    ),
                                  );
                                },
                                child: _buildCustomerRow(customer, screenWidth),
                              );
                            },
                          ),
                        ),
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
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildCustomerRow(Map<String, dynamic> customer, double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
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
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                // Flexsave Status with Color Change
                Text(
                  customer["flexsave"] == "Yes" ? "Yes" : "No",
                  style: GoogleFonts.montserrat(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: customer["flexsave"] == "Yes"
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                SizedBox(height: screenWidth * 0.005),
                Text(
                  customer["date_created"] ?? "N/A",
                  style: GoogleFonts.montserrat(
                    fontSize: screenWidth * 0.035,
                    color: Colors.black54,
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
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              // Phone Number Below Dropdown
              GestureDetector(
                onTap: () => (customer["phone"]),
                child: Text(
                  customer["phone"]?.toString().replaceFirst("254", "80") ??
                      "N/A",
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
}


Widget _buildSearchBar(
    double screenWidth, TextEditingController searchController) {
  return Container(
    height: screenWidth * 0.13,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25.0),
    ),
    child: Row(
      children: [
        const SizedBox(width: 10),
        const Icon(Icons.search, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Search for phone number here",
              hintStyle: GoogleFonts.montserrat(
                fontSize: screenWidth * 0.04,
                color: Colors.grey,
              ),
            ),
            style: GoogleFonts.montserrat(
              fontSize: screenWidth * 0.04,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.grid_view, color: Colors.grey),
        const SizedBox(width: 10),
      ],
    ),
  );
}

Widget _buildHeaderCell(String text, double screenWidth) {
  return Expanded(
    child: SelectableText(
      text,
      style: GoogleFonts.montserrat(
        fontSize: screenWidth * 0.04,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

Widget _buildDataCell(String text, double screenWidth) {
  return Expanded(
    child: SelectableText(
      text,
      style: GoogleFonts.montserrat(
        fontSize: screenWidth * 0.035,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
