import 'dart:developer';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  RxString userId = ''.obs;
  RxString phoneNumber = ''.obs;

  /// Set user ID and store it in SharedPreferences
  Future<void> setUserId(String id) async {
    userId.value = id;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);

    final storedUserId = prefs.getString('user_id');
    log('[UserController] Stored user ID in SharedPreferences: $storedUserId');
  }

  /// Load user ID from SharedPreferences
  Future<void> loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getString('user_id') ?? '';

    log('[UserController] User ID loaded: ${userId.value}');
  }

  /// Set phone number and store it in SharedPreferences
  Future<void> setPhoneNumber(String phoneNumberValue) async {
    phoneNumber.value = phoneNumberValue;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone_number', phoneNumberValue);

    final storedPhoneNumber = prefs.getString('phone_number');
    log('[UserController] Stored phone number: $storedPhoneNumber');
  }

  /// Load phone number from SharedPreferences
  Future<void> loadPhoneNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    phoneNumber.value = prefs.getString('phone_number') ?? '';

    log('[UserController] Phone number loaded: ${phoneNumber.value}');
  }

  /// Clear user data (memory + SharedPreferences)
  Future<void> clearUser() async {
    log('[UserController] Clearing user data...');

    // Reset in-memory values
    userId.value = '';
    phoneNumber.value = '';

    // Clear all SharedPreferences data
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool result = await prefs.clear(); // This clears EVERYTHING in prefs!

    if (result) {
      log('[UserController] All SharedPreferences cleared successfully.');
    } else {
      log('[UserController] Failed to clear SharedPreferences.');
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => userId.value.isNotEmpty;
}