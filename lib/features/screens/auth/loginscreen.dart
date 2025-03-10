import 'dart:convert';

import 'package:flexmerchandiser/features/controllers/phonecontroller.dart';
import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:flexmerchandiser/features/screens/auth/api_service.dart';
import 'package:flexmerchandiser/features/screens/auth/otpverificationscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final UserController userController =
      Get.put(UserController()); // Injecting the UserController

  // Variable to track loading state
  bool isLoading = false;

  // Method to send OTP request
 Future<void> _requestOtp(BuildContext context) async {
  String phoneNumber = phoneController.text.trim();

  if (phoneNumber.isEmpty) {
    log('Please enter your phone number');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your phone number'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  final String url = "https://www.flexpay.co.ke/users/api/app/promoter/send-otp";
  final Map<String, dynamic> requestBody = {
    'phone_number': phoneNumber,
  };

  await ApiService.postRequest(
    url: url,
    body: requestBody,
    context: context,
    showLoader: true,
    onSuccess: (data) async {
      log('OTP sent to $phoneNumber');

      await userController.setPhoneNumber(phoneNumber);

      Get.to(() => OTPScreen(phoneNumber: phoneNumber));

      setState(() {
        isLoading = false;
      });
    },
    onError: (errorMessage) {
      log('Failed to send OTP: $errorMessage');

      setState(() {
        isLoading = false;
      });
    },
  );
}



  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // Responsive horizontal padding
            vertical: screenHeight * 0.02, // Responsive vertical padding
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.05), // Space at the top
              Align(
                alignment: Alignment.centerRight,
                child: Lottie.asset(
                  "assets/images/chamatype.json",
                  height: MediaQuery.of(context).size.height * 0.25,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  text: "Sign In to Flexpay ",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: screenWidth * 0.08, // Responsive font size
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                "We provide top-quality services and support for your needs.",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: screenWidth * 0.05, // Responsive font size
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              TextFormField(
                controller: phoneController,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: screenWidth * 0.045, // Responsive font size
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone),
                  labelText: "Phone Number",
                  hintText: "Enter your phone number",
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: screenWidth * 0.045, // Responsive font size
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.03), // Responsive border radius
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.004),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Handle Forgot Password
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: screenWidth * 0.04, // Responsive font size
                      color: const Color(0xFF337687),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF337687),
                    elevation: 5,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.018, // Responsive padding
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          screenWidth * 0.03), // Responsive border radius
                    ),
                  ),
                  onPressed: isLoading ? null : () => _requestOtp(context),
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          "LOGIN",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize:
                                screenWidth * 0.05, // Responsive font size
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: screenWidth * 0.045, // Responsive font size
                      color: const Color(0xFF337687),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dummy SignupScreen to prevent errors
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Signup Screen",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
