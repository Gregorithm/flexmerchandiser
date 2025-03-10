import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:flexmerchandiser/features/screens/navigationbar/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

final dateFormat = DateFormat('dd-MM-yyyy');

class OnboardedCustomersPage extends StatefulWidget {
  final String selectedMonth;
  final int monthIndex;

  OnboardedCustomersPage(
      {required this.selectedMonth, required this.monthIndex});

  @override
  _OnboardedCustomersPageState createState() => _OnboardedCustomersPageState();
}

class _OnboardedCustomersPageState extends State<OnboardedCustomersPage> {
  List<Map<String, dynamic>> customers = [];
  bool isLoading = true;
  bool hasError = false;
  late UserController userController;

  @override
  void initState() {
    super.initState();
    userController = Get.find<UserController>();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    final String phoneNumber = userController.phoneNumber.value;
    if (phoneNumber.isEmpty) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("UserId is empty"),
        ),
      );
      return;
    }

    final String url =
        "https://www.flexpay.co.ke/users/api/flex-chama/agent-customers/$phoneNumber";
    print('PhoneNumber sent to backend is : $phoneNumber');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-type": "application/json",
          "Authorization":
              "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczpcL1wvd3d3LmZsZXhwYXkuY28ua2VcL3VzZXJzXC9hcGlcL2FwcFwvcHJvbW90ZXJcL3ZlcmlmeS1vdHAiLCJpYXQiOjE3NDEyNjQ3MDcsImV4cCI6NjAwMDE3NDEyNjQ2NDcsIm5iZiI6MTc0MTI2NDcwNywianRpIjoibVFLSWtVZFBkdk9NSzE2YSIsInN1YiI6MzA5NzMxLCJwcnYiOiI4N2UwYWYxZWY5ZmQxNTgxMmZkZWM5NzE1M2ExNGUwYjA0NzU0NmFhIn0.46VcL8LKjOf1uYLDX9IXzdiZ3CSl3uEyA1IG4WO8ov0",
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) {
          final List<dynamic> customerData = data['data'];

          List<Map<String, dynamic>> filteredCustomers =
              customerData.where((customer) {
            DateTime createdAt = DateTime.parse(customer['created_at']);
            return createdAt.month == widget.monthIndex + 1;
          }).map((customer) {
            return {
              "name":
                  "${customer["first_name"] ?? ""} ${customer["last_name"] ?? ""}",
              "phone": customer["phone_number"] ?? "",
              "date": customer["created_at"] != null
                  ? dateFormat.format(DateTime.parse(customer['created_at']))
                  : "",
            };
          }).toList();

          setState(() {
            customers = filteredCustomers;
            hasError = false;
          });
        } else {
          setState(() {
            hasError = true;
          });
        }
      } else {
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          "Onboarded Customers - ${widget.selectedMonth}",
          style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black),
        ),
        centerTitle: true,
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                    color: isDarkMode ? Colors.white : Colors.black))
            : hasError
                ? Center(
                    child: Text(
                      'Error loading customers',
                      style: GoogleFonts.montserrat(
                          fontSize: 16, color: Colors.redAccent),
                    ),
                  )
                : customers.isEmpty
                    ? Center(
                        child: Text(
                          "No customers were onboarded on ${widget.selectedMonth}.",
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black),
                        ),
                      )
                    : ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[900]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade400,
                                    blurRadius: 10,
                                    spreadRadius: 1),
                              ],
                            ),
                            child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  child:
                                      Icon(Icons.person, color: Colors.white),
                                ),
                                title: Text(
                                  customers[index]['name'] ?? 'No Name',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                subtitle: Text(
                                  customers[index]['phone'] ?? 'No Phone',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.black87),
                                ),
                                trailing: Text(
                                  customers[index]['date'] ?? 'No Date',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.black87),
                                )),
                          );
                        },
                      ),
      ),
      bottomNavigationBar: NavigationBarWidget(),
    );
  }
}
