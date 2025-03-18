
import 'package:flexmerchandiser/features/screens/homescreen/homescreen.dart';
import 'package:flexmerchandiser/features/screens/auth/intropage.dart';
import 'package:flexmerchandiser/features/screens/auth/loginscreen.dart';
import 'package:flexmerchandiser/features/screens/auth/otpverificationscreen.dart';
import 'package:flexmerchandiser/features/screens/auth/profilepage.dart';
import 'package:flexmerchandiser/features/screens/auth/splashscreen.dart';
import 'package:flexmerchandiser/features/screens/urgentcalls.dart';
import 'package:flexmerchandiser/features/screens/vipscreen.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(), // SplashScreen as the initial route
  '/onboarding': (context) => OnboardingScreen(),
  '/login': (context) => LoginScreen(),
  '/otpverification': (context) => const OTPScreen(
        phoneNumber: '',
      ),
  '/home': (context) =>  HomeScreen(),
  '/profile': (context) => ProfilePage(userId: '',),
  '/urgentcalls': (context) => UrgentCallsPage(),
  '/vip': (context) => Vipscreen(),
};
