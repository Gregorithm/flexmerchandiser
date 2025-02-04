import 'package:get/get.dart';

class UserController extends GetxController {
  RxString userId = ''.obs;
  RxString authToken = ''.obs;
  RxString phoneNumber = ''.obs;

  void setUserId(String id) {
    userId.value = id;
  }

  void setAuthToken(String token) {
    authToken.value = token;
  }

// Method to set the token
  void loginUser(String userToken) {
    authToken.value = userToken;
  }

  
  String getUserId() {
    return userId.value;
  }

  String getAuthToken() {
    return authToken.value;
  }
}

  

