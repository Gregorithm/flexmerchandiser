import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';


class OutletDetailsPage extends StatefulWidget {
  final String outletId;

  OutletDetailsPage({super.key, required this.outletId});

  @override
  _OutletDetailsPageState createState() => _OutletDetailsPageState();
}

class _OutletDetailsPageState extends State<OutletDetailsPage> {
  List<dynamic> outletDetails = [];
  List<dynamic> filteredDetails = [];
  bool isLoading = true;
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchOutletDetails() async {
    const String url =
        "https://bookings.flexpay.co.ke/api/merchandizer/customers";
    final Map<String, dynamic> requestBody = {
      "user_id": 309731,
      "outlet_id": int.parse(widget.outletId),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == true) {
          setState(() {
            outletDetails = (data["data"]["data"] ?? []).map((customer) {
              // Format the phone numbers on fetch
              customer["phone"] = _formatPhoneNumber(customer["phone"] ?? "");
              customer["status"] = customer["customer_followup"]?["status"] ??
                  "NOT CALLED"; // Extract status or default to "NOT CALLED" since it is nested further and not directly
              customer["flexsave"] =
                  customer["is_flexsave_customer"] == 1 ? "Yes" : "No";
              return customer;
            }).toList();
            filteredDetails = outletDetails;
            isLoading = false;
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

  String _formatPhoneNumber(String phone) {
    if (phone.startsWith('254') && phone.length == 12) {
      return '0${phone.substring(3)}';
    }
    return phone; // Return the original phone number if it doesn't match the format
  }

  Future<void> updateCustomerStatus(int customerId, String status) async {
    const String updateUrl =
        "https://www.flexpay.co.ke/users/api/merchandizer/customer-followup";

    try {
      final Map<String, dynamic> requestBody = {
        "user_id": customerId, // Update only this customer
        "status": status, // New status to update
      };

      // Log the request body
      print("Sending update request: $requestBody");

      final updateResponse = await http.post(
        Uri.parse(updateUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczpcL1wvd3d3LmZsZXhwYXkuY28ua2VcL3VzZXJzXC9hcGlcL2xvZ2luIiwiaWF0IjoxNzM3OTk2NTE4LCJleHAiOjYwMDAxNzM3OTk2NDU4LCJuYmYiOjE3Mzc5OTY1MTgsImp0aSI6IjlhWFhuOFZUWTc1Z3FvamEiLCJzdWIiOjIxMTQyMiwicHJ2IjoiODdlMGFmMWVmOWZkMTU4MTJmZGVjOTcxNTNhMTRlMGIwNDc1NDZhYSJ9.RCMsQxDPdowoKt3BPSiXuY25XUmwpX5_3Nnwcq2I8fQ"
        },
        body: json.encode(requestBody),
      );

      // Log response details
      print("Response status: ${updateResponse.statusCode}");
      print("Response body: ${updateResponse.body}");

      if (updateResponse.statusCode == 200) {
        final updateData = json.decode(updateResponse.body);
        if (updateData["success"] == true) {
          print(
              "Customer ID $customerId status updated successfully in backend.");
        } else {
          print(
              "Backend error for Customer ID $customerId: ${updateData["message"]}");
        }
      } else {
        print(
            "Failed to update status for Customer ID $customerId. Status code: ${updateResponse.statusCode}");
      }
    } catch (e) {
      print("Error updating status for Customer ID $customerId: $e");
    }
  }

Future<void> _makePhoneCall(String phoneNumber) async {
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
                        _buildSearchBar(screenWidth),
                        SizedBox(height: screenHeight * 0.01),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredDetails.length,
                            itemBuilder: (context, index) {
                              final customer = filteredDetails[index];
                              return _buildCustomerRow(customer, screenWidth);
                            },
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth) {
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
              controller: _searchController, 
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
              _buildStatusDropdown(customer, screenWidth),

              SizedBox(height: screenWidth * 0.02),

              // Phone Number Below Dropdown
              GestureDetector(
                onTap: () => _makePhoneCall(customer["phone"]),
                child: Text(
                  customer["phone"] ?? "N/A",
                  style: GoogleFonts.montserrat(
                    fontSize: screenWidth * 0.04,
                    color: Colors.blue,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(
      Map<String, dynamic> customer, double screenWidth) {
    return DropdownButton<String>(
      value: statusOptions.contains(customer["status"])
          ? customer["status"]
          : statusOptions[0],
      items: statusOptions.map((String status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(
            status,
            style: GoogleFonts.montserrat(
              fontSize: screenWidth * 0.035,
              color: Colors.black,
            ),
          ),
        );
      }).toList(),
      onChanged: (newStatus) async {
  if (newStatus != null) {
    setState(() {
      customer["status"] = newStatus; // Update UI immediately
    });

    try {
      // Call API for the specific customer
      await updateCustomerStatus(customer["id"], newStatus);

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status updated to $newStatus successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle failure feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update status. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
},
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
}
