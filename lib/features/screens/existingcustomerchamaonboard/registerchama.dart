import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:flexmerchandiser/features/screens/existingcustomerchamaonboard/chamascreen.dart';
import 'package:flexmerchandiser/features/screens/newcustomerchamaonboard/chamatype.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterChamaPage extends StatefulWidget {
  @override
  _RegisterChamaPageState createState() => _RegisterChamaPageState();
}

class _RegisterChamaPageState extends State<RegisterChamaPage> {
  final UserController userController = Get.find<UserController>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  String selectedGender = "Female";
  String? selectedDay;
  String? selectedMonth; 
  String? selectedYear;

  bool isLoading = false;

  List<String> days = List.generate(31, (index) => (index + 1).toString());
  List<String> months = [
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
  List<String> years =
      List.generate(100, (index) => (DateTime.now().year - index).toString());

  Future<void> registerUser() async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        idNumberController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        selectedDay == null ||
        selectedMonth == null ||
        selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all required fields.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    String dob =
        "$selectedYear-${(months.indexOf(selectedMonth!) + 1).toString().padLeft(2, '0')}-${int.parse(selectedDay!).toString().padLeft(2, '0')}";
    String phoneNumber = phoneNumberController.text;
    print("Entered Phone Number: $phoneNumber");

    Map<String, dynamic> requestBody = {
      "phone_number": phoneNumberController.text,
      "dob": dob,
      "first_name": firstNameController.text,
      "last_name": lastNameController.text,
      "gender": selectedGender.toLowerCase(),
      "id_number": idNumberController.text,
      "agent_id": userController.userId.value,
    };

    // Log the request body
    print("Request Body: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse("https://www.flexpay.co.ke/users/api/flex-chama/join"),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczpcL1wvd3d3LmZsZXhwYXkuY28ua2VcL3VzZXJzXC9hcGlcL2xvZ2luIiwiaWF0IjoxNzM3OTk2NTE4LCJleHAiOjYwMDAxNzM3OTk2NDU4LCJuYmYiOjE3Mzc5OTY1MTgsImp0aSI6IjlhWFhuOFZUWTc1Z3FvamEiLCJzdWIiOjIxMTQyMiwicHJ2IjoiODdlMGFmMWVmOWZkMTU4MTJmZGVjOTcxNTNhMTRlMGIwNDc1NDZhYSJ9.RCMsQxDPdowoKt3BPSiXuY25XUmwpX5_3Nnwcq2I8fQ"
        },
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      String errorMessage = "Registration Failed";

      if (responseData["errors"] != null) {
  if (responseData["errors"] is Map) {
    final firstErrorKeys = responseData['errors'].keys.first;
    final errorsLists = responseData['errors'][firstErrorKeys];

    if (errorsLists is List && errorsLists.isNotEmpty) {
      errorMessage = errorsLists.first;
    }
  } else if (responseData["errors"] is List) {
    if (responseData["errors"].isNotEmpty) {
      errorMessage = responseData["errors"].first.toString();
    }
  }
}


      // Log the response status code and body
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account registered successfully!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ChamaType(phoneNumber: phoneNumberController.text)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: ${errorMessage}")),
        );
      }
    } catch (e) {
      // Log any errors
      print("Error during registration: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.06;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Chama Registration",
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Onboard Account",
              style: GoogleFonts.montserrat(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            _buildTextField("First Name", "Enter First Name",
                firstNameController, screenWidth),
            _buildTextField("Last Name", "Enter Last Name", lastNameController,
                screenWidth),
            _buildTextField("ID Number", "Enter ID Number", idNumberController,
                screenWidth),
            _buildTextField("Phone Number", "Enter Phone Number",
                phoneNumberController, screenWidth),
            SizedBox(height: 10),
            Text(
              "Birthday ",
              style: GoogleFonts.montserrat(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                    child: _buildDropdown(
                        "Day",
                        days,
                        selectedDay,
                        (value) => setState(() => selectedDay = value),
                        screenWidth)),
                SizedBox(width: 10),
                Expanded(
                    child: _buildDropdown(
                        "Month",
                        months,
                        selectedMonth,
                        (value) => setState(() => selectedMonth = value),
                        screenWidth)),
                SizedBox(width: 10),
                Expanded(
                    child: _buildDropdown(
                        "Year",
                        years,
                        selectedYear,
                        (value) => setState(() => selectedYear = value),
                        screenWidth)),
              ],
            ),
            SizedBox(height: 20),
            Text("Gender",
                style: GoogleFonts.montserrat(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            SizedBox(height: 10),
            Row(
              children: [
                _buildGenderOption(
                    "Male", Icons.male, Colors.black, screenWidth),
                SizedBox(width: 10),
                _buildGenderOption(
                    "Female", Icons.female, Colors.orange, screenWidth),
              ],
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: screenWidth * 0.15,
              child: ElevatedButton(
                onPressed: isLoading ? null : registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Register Account",
                        style: GoogleFonts.montserrat(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint,
      TextEditingController controller, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
          SizedBox(height: 5),
          TextField(
            controller: controller,
            style: GoogleFonts.montserrat(
                color: Colors.black), // Apply Montserrat font
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint, List<String> items, String? selectedValue,
      Function(String?) onChanged, double screenWidth) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedValue,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
      ),
      hint: Text(hint, style: GoogleFonts.montserrat(color: Colors.grey)),
      dropdownColor: Colors.white,
      style: GoogleFonts.montserrat(
          color: Colors.black, fontSize: screenWidth * 0.04),
      items: items
          .map((value) => DropdownMenuItem(
                value: value,
                child: Text(value,
                    style: GoogleFonts.montserrat(
                        color: Colors.black, fontSize: screenWidth * 0.04)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildGenderOption(
      String gender, IconData icon, Color color, double screenWidth) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedGender = gender;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selectedGender == gender
                ? color.withOpacity(0.2)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: selectedGender == gender ? color : Colors.grey.shade400),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              SizedBox(width: 8),
              Text(
                gender,
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
