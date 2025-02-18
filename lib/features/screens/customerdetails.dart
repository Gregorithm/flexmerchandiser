import 'dart:convert';
import 'package:flexmerchandiser/features/screens/chamascreen.dart';
import 'package:flexmerchandiser/features/screens/registerchama.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailsPage extends StatefulWidget {
  final Map<String, dynamic> customer;
  final int customerId;
  final String description;

  const CustomerDetailsPage(
      {Key? key,
      required this.customer,
      required this.customerId,
      required this.description})
      : super(key: key);

  @override
  _CustomerDetailsPageState createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  String? selectedStatus;
  TextEditingController descriptionController = TextEditingController();
  Map<String, String> statusDescriptions = {}; // Store descriptions
  bool isUpdating = false;
  String? paymentPattern;
  String? customerCategory;
  bool isLoading = false;
  List<String> statusOptions = [
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
    print("Customer ID: ${widget.customerId}");
    print('Fetched description: ${widget.description}');
    fetchCustomerSummary();
  
  }

  Future<void> fetchCustomerSummary() async {
    setState(() {
      isLoading = true;
    });

    const String baseUrl =
        "https://bookings.flexpay.co.ke/api/booking/customer-summary/";
    final String phoneNumber = widget.customer["phone"]
        .toString(); //"254715263854"  widget.customer["phone"].toString() ??

    print("Modified Phone Number: $phoneNumber");
    final String url = "$baseUrl$phoneNumber";

    print("Requesting URL: $url");
    print("Using Phone Number: $phoneNumber");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczpcL1wvd3d3LmZsZXhwYXkuY28ua2VcL3VzZXJzXC9hcGlcL2xvZ2luIiwiaWF0IjoxNzM3OTk2NTE4LCJleHAiOjYwMDAxNzM3OTk2NDU4LCJuYmYiOjE3Mzc5OTY1MTgsImp0aSI6IjlhWFhuOFZUWTc1Z3FvamEiLCJzdWIiOjIxMTQyMiwicHJ2IjoiODdlMGFmMWVmOWZkMTU4MTJmZGVjOTcxNTNhMTRlMGIwNDc1NDZhYSJ9.RCMsQxDPdowoKt3BPSiXuY25XUmwpX5_3Nnwcq2I8fQ",
        },
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if "data" is a non-empty list before accessing its first element
        if (data["data"] is Map &&
            data["data"].containsKey("payment_summary")) {
          final paymentSummary = data["data"]["payment_summary"];

          setState(() {
            customerCategory =
                paymentSummary?["customer_category"]?.toString() ?? "N/A";
            paymentPattern =
                paymentSummary?["payment_pattern"]?.toString() ?? "N/A";
          });
        } else {
          print("No customer summary found.");
        }
      } else {
        print("Failed to fetch customer summary: ${response.body}");
      }
    } catch (error) {
      print("Error fetching customer summary: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> updateCustomerStatus(
      int customerId, String status, String? description) async {
    const String updateUrl =
        "https://www.flexpay.co.ke/users/api/merchandizer/customer-followup";

    try {
      final Map<String, dynamic> requestBody = {
        "user_id": customerId,
        "status": status,
        "description": description,
      };

      // Log the request body
      print("Request Body: $requestBody");

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
      print("Response Status Code: ${updateResponse.statusCode}");
      print("Response Headers: ${updateResponse.headers}");

      print("Status Descriptions: $statusDescriptions");
      print("Selected Status: $status");
      print("Fetched Description: $description");

      // Try parsing response as JSON
      try {
        final responseBody = json.decode(updateResponse.body);
        print("Decoded Response: $responseBody");

        if (updateResponse.statusCode == 200 &&
            responseBody["success"] == true) {
          print("Customer ID $customerId status updated successfully.");
          return true;
        } else {
          print("Error: ${responseBody["message"] ?? "Unknown error"}");
          return false;
        }
      } catch (jsonError) {
        // If response is not JSON, print as raw text
        print("Raw Response Body (Not JSON): ${updateResponse.body}");
        return false;
      }
    } catch (e) {
      print("Request Error for Customer ID $customerId: $e");
      return false;
    }
  }



  

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
        toolbarHeight: 90,
        title: Text(
          "Customer Information",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [IconButton(icon: Icon(Icons.star_border), onPressed: () {})],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchCustomerSummary();
          await updateCustomerStatus(widget.customerId, selectedStatus ?? 'Not Updated', widget.description);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: screenWidth * 0.15,
                backgroundImage: AssetImage("assets/icon/userprofile.png"),
              ),
              SizedBox(height: screenWidth * 0.03),
              Text(
                widget.customer["customer_name"] ?? "N/A",
                style: GoogleFonts.montserrat(
                    fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenWidth * 0.02),
              Text(
                "Payment Behaviour: $paymentPattern",
                style: GoogleFonts.montserrat(
                    fontSize: screenWidth * 0.04, color: Colors.black),
              ),
              SizedBox(height: screenWidth * 0.02),
              Text(
                "Customer Category: $customerCategory",
                style: GoogleFonts.montserrat(
                    fontSize: screenWidth * 0.04, color: Colors.black),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle,
                      color: widget.customer["flexsave"] == "Yes"
                          ? Colors.green
                          : Colors.red),
                  SizedBox(width: screenWidth * 0.009),
                  Text(
                    "FlexSave: ${widget.customer["flexsave"] ?? "N/A"}",
                    style: GoogleFonts.montserrat(fontSize: screenWidth * 0.04),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.05),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildListTile(
                        Icons.calendar_today,
                        "Date Created",
                        widget.customer["date_created"] ?? "N/A",
                        widget.customer["date_created"] ?? "N/A",
                        screenWidth),
                    _buildListTile(
                        Icons.phone,
                        "Phone Number",
                        widget.customer["phone"]
                                ?.toString()
                                .replaceFirst("254", "80") ??
                            "N/A",
                        widget.customer["phone"]
                                ?.toString()
                                .replaceFirst("254", "80") ??
                            "N/A",
                        screenWidth),
                    _buildListTile(
                      Icons.info,
                      "Status",
                      widget.customer["status"] ?? "N/A",
                      widget.customer["phone"] ?? "N/A",
                      screenWidth,
                      trailing: isUpdating
                          ? CircularProgressIndicator() // Show loader when updating
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF337687),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 11),
                                textStyle: GoogleFonts.montserrat(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                String? newStatus = await _buildStatusDropdown(
                                    context, screenWidth);
                                if (newStatus != null) {
                                  setState(() {
                                    isUpdating = true;
                                  });

                                  await Future.delayed(Duration(seconds: 1));

                                  if (mounted) {
                                    setState(() {
                                      widget.customer["status"] = newStatus;
                                      _showSnackbar(
                                          context,
                                          "Status has been sent successfully wait for update!",
                                          Colors.green);
                                      isUpdating = false;
                                    });

                                    // Fetch the description based on status
                                    String? description =
                                        statusDescriptions[newStatus];

                                    // Pass the description to the update API
                                    bool updateSuccessful =
                                        await updateCustomerStatus(
                                      widget.customerId, // <- Might be null
                                      newStatus,
                                      description,
                                    );

                                    if (updateSuccessful) {
                                      _showSnackbar(context,
                                          "Update successful!", Colors.green);
                                    } else {
                                      _showSnackbar(context,
                                          "Failed to update.", Colors.red);
                                    }
                                  }
                                }
                              },
                              child: Text("Update",
                                  style: GoogleFonts.montserrat()),
                            ),
                    ),
                    _buildListTile(
                      Icons.description,
                      "Description:", // Label
                      widget.description, // The dynamic description text
                      widget.customer["description"] ??
                          "N/A", // Passing the description
                      screenWidth, // Add the missing argument
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Current Status: ${widget.customer["status"] ?? "N/A"}",
                          style: GoogleFonts.montserrat(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        if (statusDescriptions
                            .containsKey(widget.customer["status"]))
                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              "New Description: ${statusDescriptions[widget.customer["status"]] ?? ""}",
                              style: GoogleFonts.montserrat(
                                fontSize: screenWidth * 0.04,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03), // Responsive space
                    if (widget.customer["flexsave"] == "No")
                      ElevatedButton(
                        onPressed: () {
                          Get.to(() => RegisterChamaPage());
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 11),
                          backgroundColor: const Color(0xFF337687),
                          textStyle: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Register to Flexchama",
                            style: GoogleFonts.montserrat()),
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

  Widget _buildListTile(IconData icon, String title, String subtitle,
      String phoneNumber, double screenWidth,
      {Widget? trailing}) {
    String maskedNumber = (phoneNumber);

    return ListTile(
      leading: Icon(icon, size: screenWidth * 0.06),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.045, fontWeight: FontWeight.w600),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
      subtitle: trailing == null
          ? GestureDetector(
              onTap: () => _makePhoneCall(phoneNumber),
              child: Text(
                maskedNumber,
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.04,
                  color: Colors.blue, // Highlighted as clickable
                  // Underline to show it's tappable
                ),
              ),
            )
          : null,
    );
  }

  bool _descriptionDialogShown = false;

  Future<String?> _buildStatusDropdown(
      BuildContext context, double screenWidth) async {
    selectedStatus = widget.customer["status"] ?? statusOptions[0];
    descriptionController.clear();

    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Update Status", style: GoogleFonts.montserrat()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedStatus,
                    items: statusOptions.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status, style: GoogleFonts.montserrat()),
                      );
                    }).toList(),
                    onChanged: (newStatus) {
                      setState(() {
                        selectedStatus = newStatus!;
                        if (newStatus == "ANSWERED") {
                          _showDescriptionDialog(
                              context, newStatus, setState, statusDescriptions);
                        }
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: Text("Cancel", style: GoogleFonts.montserrat()),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, selectedStatus);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    backgroundColor: const Color(0xFF337687),
                    textStyle: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text("Update", style: GoogleFonts.montserrat()),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

void _showSnackbar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.montserrat()),
      backgroundColor: color));
}

Future<void> _makePhoneCall(String phoneNumber) async {
  final Uri url = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunch(url.toString())) {
    await launch(url.toString());
  } else {
    throw 'Could not launch dialer with number $phoneNumber';
  }
}

TextEditingController descriptionController =
    TextEditingController(); // Declare the controller globally

void _showDescriptionDialog(
    BuildContext context,
    String status,
    void Function(void Function()) setState,
    Map<String, String> statusDescriptions) {
  if (status == "ANSWERED") {
    // Use existing controller
    descriptionController.clear(); // Make sure it is cleared every time

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter New Description "),
          content: TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: "Enter details..."),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  statusDescriptions[status] =
                      descriptionController.text; // Save description
                });
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
