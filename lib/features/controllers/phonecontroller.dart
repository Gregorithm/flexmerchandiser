import 'package:flutter/material.dart';

class PhoneNumberController {
  static final TextEditingController phoneNumberController = TextEditingController();

  static String get phoneNumber => phoneNumberController.text;
}
