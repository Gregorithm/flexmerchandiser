import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flexmerchandiser/features/screens/homescreen/homescreen.dart';
import 'package:flexmerchandiser/features/screens/outletdetailsscreen/outletdetailspage.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  void _onItemTapped(int index) {
    if (index == currentIndex) return; // Prevent unnecessary navigation
    switch (index) {
      case 0:
        Get.offAll(() => HomeScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          
        ],
      ),
    );
  }
}