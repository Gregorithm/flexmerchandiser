import 'dart:convert';
import 'dart:developer';
import 'package:flexmerchandiser/features/controllers/authcontroller.dart';
import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:flexmerchandiser/features/controllers/api_service.dart';
import 'package:flexmerchandiser/features/screens/homescreen/homescreen.dart';
import 'package:flexmerchandiser/features/screens/auth/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPScreen({super.key, required this.phoneNumber});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final UserController userController = Get.find<UserController>();
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isLoading = false;
  String _otp = '';

  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController =
        VideoPlayerController.asset("assets/images/otpverification.webm")
          ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _otp = _controllers.map((c) => c.text).join();
    });

    final String url =
        'https://www.flexpay.co.ke/users/api/app/promoter/verify-otp';

    final Map<String, dynamic> requestBody = {
      "phone_number": widget.phoneNumber,
      'otp': _otp,
    };

    try {
      await ApiService.postRequest(
        url: url,
        body: requestBody,
        showLoader: true,
        onSuccess: (responseData) async {
          log('responseData: $responseData'); // Logs the full response

          // Check if the response is successful

          final decodedResponseData = jsonDecode(responseData);

      if (decodedResponseData['success'] == true) {
        final userId = decodedResponseData['data']['user']['id'].toString();
        final token = decodedResponseData['data']['token'];

        userController.phoneNumber.value = widget.phoneNumber;

        //SET THE userId 
        userController.setUserId(userId.toString());
        log('User ID: $userId, Token: $token');
        final authController = Get.find<AuthController>();
        await authController.loginUser(token, userId);

        if (authController.isAuthenticated == true) {
          _playSuccessVideo();
        } else {
          Get.offAll(HomeScreen());
        }
      }else {
            _showErrorDialog("Invalid OTP. Please try again.");
            setState(() {
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          log("Error verifying OTP: $error");
          _showErrorDialog("An error occurred. Please try again.");
          setState(() {
            _isLoading = false;
          });
        },
      );
    } catch (error) {
      log("Unexpected error verifying OTP: $error");
      _showErrorDialog("An unexpected error occurred. Please try again.");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _playSuccessVideo() {
    _videoController.play();

    // Define the listener function so we can remove it later.
    void listener() {
      if (_videoController.value.position >= _videoController.value.duration) {
        _videoController.removeListener(listener);
        Get.offAll(() => HomeScreen());
      }
    }

    _videoController.addListener(listener);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }



  void _resendOtp() async {
    final String url =
        "https://www.flexpay.co.ke/users/api/app/promoter/send-otp";

    final Map<String, dynamic> requestBody = {
      'phone_number': widget.phoneNumber,
    };

    await ApiService.postRequest(
      url: url,
      body: requestBody,
      context: context,
      showLoader: true,
      onSuccess: (responseData) async {
        try {
          // Decode the response if it's a JSON string
          final decodedResponse = json.decode(responseData);

          if (decodedResponse["success"] == true) {
            log("OTP resent successfully to phone number: ${widget.phoneNumber}");

            // Clear the input fields
            for (var controller in _controllers) {
              controller.clear();
            }

            setState(() {
              _otp = "";
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("OTP resent successfully")),
            );
          } else {
            log("Failed to resend OTP: ${decodedResponse["errors"]}");

            setState(() {
              _isLoading = false;
            });
          }
        } catch (e) {
          log("Error decoding response: $e");
          setState(() {
            _isLoading = false;
          });
        }
      },
      onError: (errorMessage) {
        log('Failed to send OTP: $errorMessage');
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check the current theme (light or dark)
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08, // Adjust padding relative to width
            vertical: screenHeight * 0.18, // Adjust padding relative to height
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter Verification Code',
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.08, // Font size scales with width
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'We will send you a one-time password on this phone number'
                    .toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.045,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Text(
                'OTP sent to ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.normal,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: screenWidth * 0.12, // Adjust width dynamically
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      onChanged: (value) {
                        if (value.length == 1 && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        setState(() {
                          _otp = _controllers.map((c) => c.text).join();
                        });
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: screenHeight * 0.1),
              ElevatedButton(
                onPressed: _otp.length == 4 && !_isLoading
                    ? () => _verifyOtp(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF337687), // Always the desired blue
                  disabledForegroundColor: const Color(0xFF337687),
                  disabledBackgroundColor:
                      const Color(0xFF337687).withOpacity(0.12),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.2,
                    vertical: screenHeight * 0.02,
                  ),
                ),
                child: Text(
                  _isLoading ? 'Verifying...' : 'Verify',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextButton(
                onPressed: _resendOtp,
                child: Text(
                  'Resend OTP',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              if (_isLoading)
                _videoController.value.isInitialized
                    ? SizedBox(
                        width: screenWidth * 0.15,
                        height: screenWidth * 0.15,
                        child: VideoPlayer(_videoController),
                      )
                    : const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
