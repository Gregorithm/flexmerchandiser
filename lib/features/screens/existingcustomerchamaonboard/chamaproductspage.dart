import 'package:flexmerchandiser/features/controllers/phonecontroller.dart';
import 'package:flexmerchandiser/features/screens/homescreen/homescreen.dart';
import 'package:flexmerchandiser/features/screens/navigationbar/navigationbar.dart';
import 'package:flexmerchandiser/features/screens/outletdetailsscreen/outletdetailspage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChamaProductsPage extends StatefulWidget {
  final List<dynamic> products;

  ChamaProductsPage({
    required this.products, required String phoneNumber,
  });

  @override
  _ChamaProductsPageState createState() => _ChamaProductsPageState();
}

class _ChamaProductsPageState extends State<ChamaProductsPage> {
  TextEditingController depositController = TextEditingController();
  String? selectedProductId; // Track the product that is being processed
  
Future<void> joinChama(
    String productId, String phoneNumber, String depositAmount) async {
  setState(() => selectedProductId = productId);

  double deposit = double.tryParse(depositAmount) ?? 0;
  if (deposit <= 0) {
    _showModalMessage("Enter a valid deposit amount");
    setState(() => selectedProductId = null);
    return;
  }

  final url =
      Uri.parse("https://www.flexpay.co.ke/users/api/flex-chama/subscribe");
  final requestBody = jsonEncode({
    "phone_number": phoneNumber,
    "product_id": productId,
    "deposit_amount": depositAmount
  });

  print("📢 Sending Request: $requestBody");

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

    setState(() => selectedProductId = null);

    if (response.statusCode == 200) {
      _showSuccessModal("✅ Successfully joined the Chama!");
    } else {
      print("❌ API Error: ${response.body}");

      // Parse the response body
      final responseData = jsonDecode(response.body);

      // Extract error messages if they exist
      String errorMessage = "Failed to join Chama. Try again.";
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey("errors")) {
        List<dynamic> errors = responseData["errors"];
        if (errors.isNotEmpty) {
          errorMessage = errors.join("\n"); // Join multiple errors if any
        }
      }

      _showModalMessage(errorMessage);
    }
  } catch (e) {
    print("❌ Network Error: $e");
    _showModalMessage("Network error. Please try again.");
    setState(() => selectedProductId = null);
  }
}


  void _showDepositDialog(String productId) {
    TextEditingController phoneController = TextEditingController();
    TextEditingController depositController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black;
        final inputColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: backgroundColor,
          title: Text(
            "Enter Details",
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    hintText: "Enter Phone Number",
                    filled: true,
                    fillColor: inputColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: depositController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Deposit Amount",
                    hintText: "KES",
                    filled: true,
                    fillColor: inputColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: textColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.green[700] : Colors.green,
              ),
              onPressed: () {
                Navigator.pop(context);
                joinChama(
                    productId, phoneController.text, depositController.text);
              },
              child: Text("Join Chama", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showModalMessage(String message) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  Get.snackbar(
    "",  // No title, just message
    message,
    backgroundColor: isDarkMode ? Colors.grey[800] : Colors.red, // Dark mode uses grey
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
    duration: Duration(seconds: 2),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    borderRadius: 12,
    padding: EdgeInsets.all(16),
    icon: Icon(
      Icons.error_outline,
      color: Colors.white,
    ),
    shouldIconPulse: true,
  );
}

  void _showSuccessModal(String message) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  Get.snackbar(
    "",  // No title, just message
    message,
    backgroundColor: isDarkMode ? Colors.green[700] : Colors.green, // Dark mode uses darker green
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
    duration: Duration(seconds: 2),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    borderRadius: 12,
    padding: EdgeInsets.all(16),
    icon: Icon(
      Icons.check_circle_outline,
      color: Colors.white,
    ),
    shouldIconPulse: true,
  );
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chamas",
          style: GoogleFonts.montserrat(
              fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Our Chamas",
                style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700]),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.products.length,
                  itemBuilder: (context, index) {
                    final product = widget.products[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${product["name"]} @${product["monthly_price"]}k",
                              style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Target Amount: KES ${product["target_amount"]}",
                              style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54),
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
                                  side: BorderSide(color: textColor),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                child: selectedProductId ==
                                        product["id"].toString()
                                    ? CircularProgressIndicator(
                                        color: textColor)
                                    : Text(
                                        "Join Chama",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: textColor),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBarWidget(),
    );
  }
}
