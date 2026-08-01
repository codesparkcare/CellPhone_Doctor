import 'package:cellphone_doctor/screens/CourseView/course_view.dart';
import 'package:cellphone_doctor/screens/ProfileView/profile_view.dart';
import 'package:cellphone_doctor/screens/home_view__/home_screen.dart';
import 'package:cellphone_doctor/screens/service__/service_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:upgrader/upgrader.dart';

import '../controller/navBar_controller.dart';
import 'LiveView/live_view.dart';
import 'ReviewView/review_view.dart';
import 'login/login_screen.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final NavController navController = Get.put(NavController());

  final List<Widget> screens = [
    HomeScreen(),
    ReviewView(),
    LiveView(),
    CourseView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (navController.currentIndex != 0) {
          navController.changePage(0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: UpgradeAlert(
        showIgnore: false,
        showLater: true,
        upgrader: Upgrader(
          debugLogging: true,
        ),
        child: GetBuilder<NavController>(
          builder: (_) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: IndexedStack(
                index: navController.currentIndex,
                children: screens,
              ),
              bottomNavigationBar: BottomNavBar(
                selectedIndex: navController.currentIndex,
                onTap: (index) => navController.changePage(index),
              ),
            );
          },
        ),
      ),
    );
  }
}
