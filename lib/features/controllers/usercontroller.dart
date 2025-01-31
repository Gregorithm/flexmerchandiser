import 'package:get/get.dart';

class UserController extends GetxController {
  // Observables for user data
  var phoneNumber = ''.obs; // Observable for the phone number
  var userId = ''.obs;      // Observable for the user ID
  var token = ''.obs;       // Observable for the token

  // Method to set the user ID
  void setUserId(String id) {
    userId.value = id;
  }

  // Method to set the token
  void loginUser(String userToken) {
    token.value = userToken;
  }

  // Method to clear user data upon logout
  void logoutUser() {
    phoneNumber.value = '';
    userId.value = '';
    token.value = '';
  }

  // Method to get the token
  String getToken() {
    return token.value;
  }
}