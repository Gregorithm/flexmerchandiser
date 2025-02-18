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



  bool get isAuthenticated => userId.value.isNotEmpty;
}
