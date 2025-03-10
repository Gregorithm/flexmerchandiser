import 'package:flexmerchandiser/features/screens/homescreen/homescreen.dart';
import 'package:flexmerchandiser/features/screens/leaderboard.dart';
import 'package:flexmerchandiser/features/screens/navigationbar/navigationbar.dart';
import 'package:flexmerchandiser/features/screens/newcustomerchamaonboard/registernewchama.dart';
import 'package:flexmerchandiser/features/screens/urgentcalls.dart';
import 'package:flexmerchandiser/features/screens/vipscreen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NavigationController extends GetxController {
  var currentIndex = 0.obs;

  final List<Widget> pages = [
    HomeScreen(),
    RegisterNewChamaCustomer(),
    UrgentCallsPage(),
    Vipscreen(),
    Leaderboard(),
  ];

  void changeIndex(int index) {
    if (index == currentIndex.value) return;

    if (index >= 0 && index < pages.length) {
      currentIndex.value = index;
      try {
        print("Navigating to index: $index, Page: ${pages[index]}");
        Get.off(() => pages[index]); 
      } catch (e) {
        print("Navigation error: $e");
      }
    } else {
      print("Invalid index: $index");
    }
  }
}

