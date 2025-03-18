import 'dart:developer';
import 'package:flexmerchandiser/features/service/database_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flexmerchandiser/features/controllers/usercontroller.dart'; // Import UserController if you want to clear user info too

class AuthController extends GetxController {
  var token = "".obs;

  Future<void> loginUser(String newToken, String userId) async {
    token.value = newToken;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', newToken);
    await prefs.setString('user_id', userId);

    final storedToken = prefs.getString('auth_token');
    log("Stored token in SharedPreferences is: $storedToken");
  }

  Future<void> loadToken(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString('auth_token') ?? "";
    log('Token loaded: ${token.value}');
  }

  Future<void> logoutUser(String userId) async {
    log("Logging out user...");

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove token and userId from SharedPreferences
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('phone_number');

    // Optionally clear all preferences if no data should persist:
    // await prefs.clear();

    // Reset observable values
    token.value = "";

    // Optionally: Clear user data from UserController
    Get.find<UserController>().clearUser();

    // Optionally: Clear user data from local database (outlets, etc.)
    await DatabaseService.instance.clearOutlets();

    log('User has been logged out. Token, user data, and local DB cleared.');
  }

  bool get isAuthenticated => token.value.isNotEmpty;
}