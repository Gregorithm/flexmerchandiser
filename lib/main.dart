import 'dart:developer';

import 'package:flexmerchandiser/features/controllers/authcontroller.dart';
import 'package:flexmerchandiser/features/controllers/navigationcontroller.dart';
import 'package:flexmerchandiser/features/controllers/usercontroller.dart';
import 'package:flexmerchandiser/features/screens/auth/intropage.dart';
import 'package:flexmerchandiser/features/screens/auth/loginscreen.dart';
import 'package:flexmerchandiser/features/screens/auth/splashscreen.dart';
import 'package:flexmerchandiser/features/screens/homescreen/homescreen.dart';
import 'package:flexmerchandiser/util/device/device_utility.dart'; 
import 'package:flexmerchandiser/util/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is ready for async calls.

  // Initialize controllers globally before runApp()
  final navigationController = Get.put(NavigationController());
  final userController = Get.put(UserController());
  final authController = Get.put(AuthController());

  // Load user data (simulate from SharedPreferences or API)
  await userController.loadUserId();
  await userController.loadPhoneNumber();

  String initialRoute = '/login'; // Default route if not authenticated.

  final userId = userController.userId.value;

  if (userId.isNotEmpty) {
    // Load token with userId
    await authController.loadToken(userId);

    // Check authentication with userId
    if (authController.isAuthenticated) {
      log('✅ User authenticated - UserID: $userId');
      initialRoute = '/home'; // Direct to home if authenticated
    } else {
      log('❌ Token not found. Redirecting to Login.');
      initialRoute = '/login';
    }
  } else {
    log('❌ No userId found. Redirecting to Login.');
    initialRoute = '/login';
  }

  runApp(FlexMerchandiserApp(initialRoute: initialRoute));
}

class FlexMerchandiserApp extends StatelessWidget {
  final String initialRoute;

  const FlexMerchandiserApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            DeviceUtil.init(context); // Initialize device utility

            debugPrint(
                "📱 Screen Width: ${constraints.maxWidth}, Height: ${constraints.maxHeight}");

            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.system,
              theme: TAppTheme.lightTheme,
              darkTheme: TAppTheme.darkTheme,
              initialRoute: initialRoute, // ✅ Dynamic route based on auth state
              getPages: [
                GetPage(name: '/', page: () => const SplashScreen()),
                GetPage(name: '/onboarding', page: () => OnboardingScreen()),
                GetPage(name: '/login', page: () => LoginScreen()),
                GetPage(name: '/home', page: () => HomeScreen()), // ✅ Home route
              ],
            );
          },
        );
      },
    );
  }
}