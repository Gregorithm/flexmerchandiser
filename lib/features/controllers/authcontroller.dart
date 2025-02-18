import 'dart:developer';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  var token = "".obs;

  Future<void> loginUser(String newToken) async {
    token.value = newToken;

    //store token in shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', newToken);

    //confirm that the token is stored
    final storedToken = prefs.getString('auth_token');
    log("Storedtoken in the shared preferences is: $storedToken");
  }

  Future<void> loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString('auth_token') ?? "";

    log('Token Loaded: ${token.value}');
  }

  Future<void> logoutUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString('auth_token') ?? "";
    await prefs.remove('auth_token');
    log('Token ${token.value} removed from shared preferences');
  }

  bool get isAuthenticated => token.value.isNotEmpty;

  void logout() {}
}
