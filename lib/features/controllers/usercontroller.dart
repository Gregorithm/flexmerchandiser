import 'dart:developer';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  RxString userId = ''.obs;
  RxString phoneNumber = ''.obs;

  Future<void> setUserId(String id) async {
    userId.value = id;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);

    //ensure the stored user id is stored properly
    final storedUserId = prefs.getString('user_id');
    log('Stored user id in shared preferences is: $storedUserId');
  }

  Future<void> loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId.value = await prefs.getString('user_id') ?? '';

    log('User ID loaded: ${userId.value}');
  }

  Future<void> setPhoneNumber(String phoneNumberValue) async {
    phoneNumber.value = phoneNumberValue;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone_number', phoneNumberValue);

    final storedPhoneNumber = prefs.getString('phone_number');
    log('Stored Phone Number is: $storedPhoneNumber');
  }

  Future<void> loadPhoneNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    phoneNumber.value = await prefs.getString('phone_number') ?? '';
    
    log('PhoneNumber loaded is: ${phoneNumber.value}');
  }

  bool get isAuthenticated => userId.value.isNotEmpty;
}
