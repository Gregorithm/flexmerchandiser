import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:flexmerchandiser/features/screens/otpverificationscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final UserController userController = Get.put(UserController()); // Injecting the UserController

  // Variable to track loading state
  bool isLoading = false;

  // Method to send OTP request
  Future<void> _requestOtp(BuildContext context) async {
    String phoneNumber = phoneController.text.trim();

    if (phoneNumber.isNotEmpty) {
      setState(() {
        isLoading = true; // Set loading state to true when API call starts
      });

      try {
        var response = await http.post(
          Uri.parse('https://www.flexpay.co.ke/users/api/app/promoter/send-otp'),
          body: {
            'phone_number': phoneNumber,
          },
        );

        setState(() {
          isLoading = false; // Set loading state to false when API call finishes
        });

        if (response.statusCode == 200) {
          log('OTP sent to $phoneNumber');

          // Save phone number in the UserController
          userController.phoneNumber.value = phoneNumber;

          // Navigate to OTP screen
          Get.to(() => OTPScreen(phoneNumber: phoneNumber));
        } else {
          log('Failed to send OTP: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid Phone Number. Please try again'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false; // Set loading state to false in case of error
        });
        log('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      log('Please enter your phone number');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                child: Image.asset(
                  'assets/images/happyafricanlogin.png',
                  width: screenWidth * 0.5, // Responsive image width
                  height: screenHeight * 0.25, // Responsive image height
                  fit: BoxFit.cover,
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
                    borderRadius: BorderRadius.circular(screenWidth * 0.03), // Responsive border radius
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
                      borderRadius: BorderRadius.circular(screenWidth * 0.03), // Responsive border radius
                    ),
                  ),
                  onPressed: isLoading ? null : () => _requestOtp(context),
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          "LOGIN",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: screenWidth * 0.05, // Responsive font size
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: TextButton(
                  onPressed: () {
                    
                  },
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