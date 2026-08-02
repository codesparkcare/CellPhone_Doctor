import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../ApiService/ApiService.dart';
import '../../../helpers/auth_helper.dart';
import '../../../models/auth/LoginResponseModel.dart';
import '../../ProfileView/create_profile.dart';
import '../../main_screen.dart';

class OtpController extends GetxController {
  String otp = "";
  String phoneNumber = "";
  bool isLoading = false;
  bool isResending = false;
  int resendTimer = 0;
  Timer? _timer;
  Rxn<LoginResponseModel > loginResponse = Rxn<LoginResponseModel >();

  final ApiService apiService = ApiService();

  void addDigit(String digit) {
    if (otp.length < 6) {
      otp += digit;
      update();
    }
  }

  void removeDigit() {
    if (otp.isNotEmpty) {
      otp = otp.substring(0, otp.length - 1);
      update();
    }
  }

  void clearOtp() {
    otp = "";
    update();
  }

  Future<void> resendOtp(String phoneNumber, {required Function(String) onVerificationIdReceived}) async {
    if (resendTimer > 0 || isResending) {
      Get.snackbar("Wait", "Please wait ${resendTimer} seconds before requesting again");
      return;
    }

    isResending = true;
    update();

    String formattedPhone =
        phoneNumber.startsWith('+') ? phoneNumber : "+91$phoneNumber";

    if (kIsWeb) {
      Get.snackbar("Success", "OTP sent successfully");
      onVerificationIdReceived("web_otp");

      resendTimer = 60;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        resendTimer--;
        update();
        if (resendTimer <= 0) {
          timer.cancel();
        }
      });

      isResending = false;
      update();
      return;
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval or instant verification
        },
        verificationFailed: (FirebaseAuthException e) {
          print("❌ RESEND OTP FAILED: $e");
          Get.snackbar("Failed", "Failed to resend OTP: ${e.message}");
          isResending = false;
          update();
        },
        codeSent: (String verificationId, int? resendToken) {
          print("✅ OTP RESENT SUCCESSFULLY");
          Get.snackbar("Success", "OTP sent successfully");
          onVerificationIdReceived(verificationId);
          
          // Start 60-second timer
          resendTimer = 60;
          _timer?.cancel();
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            resendTimer--;
            update();
            if (resendTimer <= 0) {
              timer.cancel();
            }
          });
          
          isResending = false;
          update();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          isResending = false;
          update();
        },
      );
    } catch (e) {
      print("❌ RESEND OTP ERROR: $e");
      Get.snackbar("Error", "Failed to resend OTP");
      isResending = false;
      update();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }


  Future<void> login() async {
    if (phoneNumber.length != 10) {
      Get.snackbar(
        "Invalid Number",
        "Please enter a valid 10 digit mobile number",
      );
      return;
    }

    isLoading = true;
    update();

    try {
      final response = await ApiService.postRequest(
        "customer/login",
        {
          "phone": phoneNumber,
          "otp": otp,
        },
      );
      print(response.toString());
      // CONVERT TO MODEL
      loginResponse.value = LoginResponseModel.fromJson(response);

      update();

      // SUCCESS CHECK
      if (loginResponse.value?.token != null && loginResponse.value!.token!.isNotEmpty) {
        Get.snackbar("Success", loginResponse.value!.message.toString()??"");
        if(loginResponse.value!.type.toString() != "existing_user"){
          Get.offAll(() => CreateProfileScreen(token:loginResponse.value!.token.toString(),number: phoneNumber.toString(),));
        } else{
          await AuthHelper.setBool("isShowOnBoard",true);
          await AuthHelper.setString("token",loginResponse.value!.token.toString());
          await AuthHelper.setString("userid",loginResponse.value!.customer!.id.toString());
          Get.offAll(() => MainScreen());
        }
      } else {
        Get.snackbar("Failed", loginResponse.value!.message??"");
      }
    } catch (e) {
      update();
      print("LOGIN ERROR => $e");
      Get.snackbar("Error", "Login failed");
    } finally{
      isLoading = false;
    }
  }

}
