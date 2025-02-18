import 'package:flexmerchandiser/features/screens/homescreen.dart';
import 'package:flexmerchandiser/features/screens/outletdetailspage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChamaProductsPage extends StatefulWidget {
  final List<dynamic> products;
  final String phoneNumber;

  ChamaProductsPage({required this.products, required this.phoneNumber});

  @override
  _ChamaProductsPageState createState() => _ChamaProductsPageState();
}

class _ChamaProductsPageState extends State<ChamaProductsPage> {
  TextEditingController depositController = TextEditingController();
  String? selectedProductId; // Track the product that is being processed

  Future<void> joinChama(String productId) async {
    setState(
        () => selectedProductId = productId); // Set loading for this button

    double depositAmount = double.tryParse(depositController.text) ?? 0;
    if (depositAmount <= 0) {
      _showModalMessage("Enter a valid deposit amount");
      setState(() => selectedProductId = null);
      return;
    }

    final url =
        Uri.parse("https://www.flexpay.co.ke/users/api/flex-chama/subscribe");
    final requestBody = jsonEncode({
      "phone_number": widget.phoneNumber,
      "product_id": productId,
      "deposit_amount": depositController.text
    });

    print("📢 Sending Request: $requestBody"); // Debug log

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczpcL1wvd3d3LmZsZXhwYXkuY28ua2VcL3VzZXJzXC9hcGlcL2xvZ2luIiwiaWF0IjoxNzM3OTk2NTE4LCJleHAiOjYwMDAxNzM3OTk2NDU4LCJuYmYiOjE3Mzc5OTY1MTgsImp0aSI6IjlhWFhuOFZUWTc1Z3FvamEiLCJzdWIiOjIxMTQyMiwicHJ2IjoiODdlMGFmMWVmOWZkMTU4MTJmZGVjOTcxNTNhMTRlMGIwNDc1NDZhYSJ9.RCMsQxDPdowoKt3BPSiXuY25XUmwpX5_3Nnwcq2I8fQ"
        },
        body: requestBody,
      );

      setState(() => selectedProductId = null); // Reset loading state

      if (response.statusCode == 200) {
        _showSuccessModal("✅ Successfully joined the Chama!");
      } else {
        print("❌ API Error: ${response.body}");
        _showModalMessage("Failed to join Chama. Try again.");
      }
    } catch (e) {
      print("❌ Network Error: $e");
      _showModalMessage("Network error. Please try again.");
      setState(() => selectedProductId = null);
    }
  }

  void _showDepositDialog(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter Deposit Amount",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: depositController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "KES"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.montserrat()),
          ),
          ElevatedButton(
            onPressed: selectedProductId == productId
                ? null
                : () {
                    Navigator.pop(context);
                    joinChama(productId);
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
            child: selectedProductId == productId
                ? CircularProgressIndicator(
                    color: Colors.white) // Show loader only for selected button
                : Text("Join", style: GoogleFonts.montserrat()),
          ),
        ],
      ),
    );
  }

  void _showSuccessModal(String message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        height: 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message,
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showModalMessage(String message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        height: 100,
        child: Center(
          child: Text(message,
              style: GoogleFonts.montserrat(
                  fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          title: Text("Chamas",
              style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Our Chamas",
                    style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700])),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.products.length,
                    itemBuilder: (context, index) {
                      final product = widget.products[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${product["name"]} @${product["monthly_price"]}k",
                              style: GoogleFonts.montserrat(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Target Amount: KES ${product["target_amount"]}",
                              style: GoogleFonts.montserrat(
                                  fontSize: 14, color: Colors.black54),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                onPressed: selectedProductId ==
                                        product["id"].toString()
                                    ? null
                                    : () => _showDepositDialog(
                                        product["id"].toString()),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.black),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                child: selectedProductId ==
                                        product["id"].toString()
                                    ? CircularProgressIndicator(
                                        color: Colors
                                            .black) // Show loader for selected button
                                    : Text("Join Chama",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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
            );
  }
}
