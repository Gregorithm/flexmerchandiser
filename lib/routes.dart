
import 'package:flexmerchandiser/features/screens/homescreen.dart';
import 'package:flexmerchandiser/features/screens/intropage.dart';
import 'package:flexmerchandiser/features/screens/loginscreen.dart';
import 'package:flexmerchandiser/features/screens/otpverificationscreen.dart';
import 'package:flexmerchandiser/features/screens/splashscreen.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(), // SplashScreen as the initial route
  '/onboarding': (context) => OnboardingScreen(),
  '/login': (context) => LoginScreen(),
  '/otpverification': (context) => const OTPScreen(
        phoneNumber: '',
      ),
  '/home': (context) =>  HomeScreen(isDarkModeOn: false),
};
