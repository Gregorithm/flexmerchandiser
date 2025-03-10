import 'package:flexmerchandiser/features/controllers/navigationcontroller.dart';
import 'package:flexmerchandiser/features/screens/homescreen/homescreen.dart';
import 'package:flexmerchandiser/features/screens/leaderboard.dart';
import 'package:flexmerchandiser/features/screens/newcustomerchamaonboard/registernewchama.dart';
import 'package:flexmerchandiser/features/screens/urgentcalls.dart';
import 'package:flexmerchandiser/features/screens/vipscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class NavigationBarWidget extends StatelessWidget {
  final NavigationController navigationController = Get.find();

  NavigationBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Obx(() => Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
            boxShadow: isDarkMode
                ? [
                    BoxShadow(
                        color: Colors.black26, blurRadius: 10, spreadRadius: 1)
                  ]
                : [],
          ),
          child: BottomNavigationBar(
            currentIndex: navigationController.currentIndex.value,
              onTap: (index) {
  print("Tapped index: $index"); // Debug log
  navigationController.changeIndex(index);

              if (index == 0) {
                Get.off(() => HomeScreen());
              } else if (index == 1) {
                Get.off(() => RegisterNewChamaCustomer());
              } else if (index == 2) {
                Get.off(() => UrgentCallsPage());
              } else if (index == 3) {
                Get.off(() => Vipscreen());
              } else if (index == 4) {
                Get.off(() => Leaderboard());
              }
            },
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            selectedItemColor: isDarkMode ? Colors.amber : Colors.black,
            unselectedItemColor:
                isDarkMode ? Colors.grey.shade400 : Colors.black54,
            showUnselectedLabels: true,
            selectedLabelStyle: GoogleFonts.montserrat(
                fontSize: 13, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 12),
            iconSize: 25,
            elevation: isDarkMode ? 10 : 0,
            type: BottomNavigationBarType.fixed,
            items: [
              _buildNavItem(Icons.home, "Home", 0, isDarkMode),
              _buildNavItem(Icons.people, "FlexChama", 1, isDarkMode),
              _buildNavItem(Icons.phone_in_talk, "Urgent", 2, isDarkMode),
              _buildNavItem(Icons.verified, "Vip", 3, isDarkMode),
              _buildNavItem(Icons.leaderboard, "Leaderboard", 4, isDarkMode),
            ],
          ),
        ));
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index, bool isDarkMode) {
    return BottomNavigationBarItem(
      icon: Obx(() {
        bool isSelected = navigationController.currentIndex.value == index;
        return Icon(
          icon,
          color: isSelected
              ? (isDarkMode ? Colors.amber : Colors.black)
              : (isDarkMode ? Colors.grey.shade400 : Colors.black54),
          size: isSelected ? 36 : 24,
        );
      }),
      label: label,
    );
  }
}




