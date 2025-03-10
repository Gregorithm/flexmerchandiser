import 'dart:developer';

import 'package:flexmerchandiser/features/controllers/authcontroller.dart';
import 'package:flexmerchandiser/features/controllers/navigationcontroller.dart';
import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:flexmerchandiser/features/screens/auth/intropage.dart';
import 'package:flexmerchandiser/features/screens/auth/loginscreen.dart';
import 'package:flexmerchandiser/features/screens/auth/splashscreen.dart';
import 'package:flexmerchandiser/util/device/device_utility.dart';
import 'package:flexmerchandiser/util/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  Get.put(NavigationController());
  Get.put(UserController()); // Initialize the UserController
  final authController = Get.put(AuthController());
  await authController.loadToken();
  final userController = Get.put(UserController());
  await userController.loadUserId();
  await userController.loadPhoneNumber();

  if (authController.isAuthenticated) {
    log('user is authenticated with token: ${authController.token.value}');
  } else {
    log('User is not authenticated, prompt for login');
  }

  if (userController.isAuthenticated) {
    log('User is authenticated with user ID: ${userController.userId.value}\n PhoneNumber: ${userController.phoneNumber.value}');
  } else {
    log('UserId is not stored in shared preferences, prompt for login');
  }

  runApp(const FlexMerchandiserApp());
}

class FlexMerchandiserApp extends StatelessWidget {
  const FlexMerchandiserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            DeviceUtil.init(
                context); // Initialize DeviceUtil for screen utilities

            // Determine the screen width and height
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;

            // Log screen dimensions for debugging
            debugPrint(
                "Screen Width: $screenWidth, Screen Height: $screenHeight");

            return GetMaterialApp(
              debugShowCheckedModeBanner: false, // Remove debug banner
              themeMode: ThemeMode.system,
              theme: TAppTheme.lightTheme,
              darkTheme: TAppTheme.darkTheme,
              initialRoute: '/',
              getPages: [
                GetPage(name: '/', page: () => const SplashScreen()),
                GetPage(name: '/onboarding', page: () => OnboardingScreen()),
                GetPage(name: '/login', page: () => LoginScreen()),
              ],
            );
          },
        );
      },
    );
  }
}
