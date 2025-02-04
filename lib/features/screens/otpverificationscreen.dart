import 'dart:convert';
import 'dart:developer';
import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:flexmerchandiser/features/screens/homescreen.dart';
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

  Future<void> _verifyOtp() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _otp = _controllers.map((c) => c.text).join();
    });

    final url = Uri.parse(
        'https://www.flexpay.co.ke/users/api/app/promoter/verify-otp');
    try {
      final response = await http.post(
        url,
        body: {
          'phone_number': widget.phoneNumber,
          'otp': _otp,
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final userId = responseData['data']['user']['id'];
        final token = responseData['data']['token'];


        userController.phoneNumber.value = widget.phoneNumber;
        userController.setUserId(userId.toString());
        userController.loginUser(token);

        _playSuccessVideo();
      } else {
        _showErrorDialog("Invalid OTP. Please try again.");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      log("Error verifying OTP: $error");
      _showErrorDialog("An error occurred. Please try again.");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _playSuccessVideo() {
    _videoController.play();

    // Wait for the video to finish, then navigate to the homepage
    _videoController.addListener(() {
      if (_videoController.value.position >= _videoController.value.duration) {
        _videoController.removeListener(() {});
        Get.offAll(() => HomeScreen(isDarkModeOn: false,));
      }
    });
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
    final url =
        Uri.parse('https://www.flexpay.co.ke/users/api/app/promoter/send-otp');
    try {
      final response = await http.post(
        url,
        body: {
          'phone_number': widget.phoneNumber,
        },
      );
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        log("OTP resent to ${widget.phoneNumber}");

      // Clear the input fields
      for (var controller in _controllers) {
        controller.clear();
      }
      setState(() {
        _otp = ''; // Reset the OTP string as well
      });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP resent successfully")),
        );
      } else {
        _showErrorDialog("Failed to resend OTP. Please try again.");
      }
    } catch (error) {
      _showErrorDialog(
          "An error occurred while resending OTP. Please check your connection.");
    }
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
                onPressed: _otp.length == 4 && !_isLoading ? _verifyOtp : null,
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
