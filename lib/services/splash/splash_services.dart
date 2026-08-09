import 'package:cellphone_doctor/screens/Auth/login_screen.dart';
import 'package:cellphone_doctor/screens/ProfileView/create_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../helpers/auth_helper.dart';
import '../../screens/main_screen.dart';
import '../../ApiService/ApiService.dart';
import '../../models/app/getProfileResponseModel.dart';

class SplashServices {
  Future<Widget> getTargetScreen(BuildContext context, bool loginStatus) async {
    String token = await AuthHelper.getString("token") ?? "";

    if (token.isEmpty) {
      return const LoginScreen();
    }

    try {
      final result = await ApiService.getData(
        uri: "/customer/profile",
        isAuthorized: true,
        context: context,
      );

      if (result != null && result != "failed") {
        final profile = GetProfileResponseModel.fromJson(result);
        bool isProfileComplete = profile.name.trim().isNotEmpty &&
            profile.email.trim().isNotEmpty &&
            profile.address.trim().isNotEmpty;

        if (isProfileComplete) {
          return MainScreen();
        } else {
          // Mandatory completion: incomplete profile must complete CreateProfileScreen first
          return CreateProfileScreen(
            token: token,
            number: profile.phone.isNotEmpty ? profile.phone : "",
          );
        }
      }
    } catch (e) {
      debugPrint("Splash Profile Check Error: $e");
    }

    return MainScreen();
  }

  Future<void> isLogin(BuildContext context, bool loginStatus) async {
    final target = await getTargetScreen(context, loginStatus);
    Get.off(() => target);
  }
}

