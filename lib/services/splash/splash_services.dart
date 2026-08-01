import 'dart:async';
import 'package:cellphone_doctor/screens/Auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../helpers/auth_helper.dart';
import '../../screens/main_screen.dart';
import '../../ApiService/ApiService.dart';
import '../../models/app/getProfileResponseModel.dart';

class SplashServices {
  Future<void> isLogin(BuildContext context, loginStatus) async {
    bool hasSeenSplash = await AuthHelper.getBool("hasSeenSplash") ?? false;
    
    // Capture start time to respect splash duration
    final startTime = DateTime.now();
    bool isProfileValid = false;

    if (loginStatus) {
      try {
        final result = await ApiService.getData(
          uri: "/customer/profile",
          isAuthorized: true,
          context: context,
        );

        if (result != null && result != "failed") {
          final profile = GetProfileResponseModel.fromJson(result);
          // Check if user has completely filled out their profile
          if (profile.name.trim().isNotEmpty && profile.email.trim().isNotEmpty) {
            isProfileValid = true;
          }
        }
      } catch (e) {
        debugPrint("Splash Profile Check Error: $e");
      }
    }

    if (!hasSeenSplash) {
      await AuthHelper.setBool("hasSeenSplash", true);
    }

    int splashDuration = hasSeenSplash ? 0 : 3;
    final elapsedTime = DateTime.now().difference(startTime).inMilliseconds;
    final requiredWait = (splashDuration * 1000) - elapsedTime;

    if (requiredWait > 0) {
      await Future.delayed(Duration(milliseconds: requiredWait));
    }

    if (loginStatus && isProfileValid) {
      Get.off(() => MainScreen());
    } else {
      if (loginStatus && !isProfileValid) {
        // Clear invalid or backed-up incomplete session
        await AuthHelper.setBool("isShowOnBoard", false);
        await AuthHelper.setString("token", "");
      }
      Get.off(() => LoginScreen());
    }
  }
}
