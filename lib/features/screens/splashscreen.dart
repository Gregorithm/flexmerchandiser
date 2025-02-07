import 'dart:async';
import 'package:flexmerchandiser/features/controllers/authcontroller.dart';
import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:flexmerchandiser/features/screens/homescreen.dart';
import 'package:flexmerchandiser/features/screens/intropage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Animation duration
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Navigate after the animation or delay based on the auth status
    Timer(const Duration(seconds: 2),
        _navigateBasedOnAuthStatus); // Redirect based on auth status
  }

  void _navigateBasedOnAuthStatus() {
    final authController = Get.find<AuthController>();
    final userController = Get.find<UserController>();

    if (authController.isAuthenticated && userController.isAuthenticated) {
      Get.offAll(() => HomeScreen(isDarkModeOn: false,));
    } else {
      Get.offAll(() => OnboardingScreen());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF337687),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            'assets/logos/logo.png', // Replace with your logo path
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
