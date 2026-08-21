import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../ApiService/ApiService.dart';
import '../../../helpers/app_toast.dart';
import '../../../helpers/auth_helper.dart';
import '../../../models/auth/LoginResponseModel.dart';
import '../../ProfileView/create_profile.dart';
import '../../main_screen.dart';

class OtpController extends GetxController {
  String otp = "";
  String phoneNumber = "";
  String verificationId = "";
  bool isLoading = false;
  bool isResending = false;
  int resendTimer = 0;
  Timer? _timer;
  Rxn<LoginResponseModel > loginResponse = Rxn<LoginResponseModel >();
  Function(String)? onCodeAutoFilled;

  final ApiService apiService = ApiService();

  void onAutoVerifiedCodeReceived(String code) {
    otp = code;
    if (onCodeAutoFilled != null) {
      onCodeAutoFilled!(code);
    }
    update();
  }

  void onAutoVerifiedWithoutCode() {
    login();
  }

  void setVerificationId(String id) {
    verificationId = id;
    resendTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      resendTimer--;
      update();
      if (resendTimer <= 0) {
        timer.cancel();
      }
    });
    update();
  }

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
      AppToast.showWarning("Please wait ${resendTimer} seconds before requesting again", title: "Wait");
      return;
    }

    isResending = true;
    update();

    String formattedPhone =
        phoneNumber.startsWith('+') ? phoneNumber : "+91$phoneNumber";

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 30),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("✅ Resend Auto SMS Verification Completed!");
          if (credential.smsCode != null && credential.smsCode!.isNotEmpty) {
            onAutoVerifiedCodeReceived(credential.smsCode!);
          } else {
            onAutoVerifiedWithoutCode();
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print("❌ RESEND OTP FAILED: $e");
          AppToast.showError("Failed to resend OTP: ${e.message}", title: "Failed");
          isResending = false;
          update();
        },
        codeSent: (String newVerificationId, int? resendToken) {
          print("✅ OTP RESENT SUCCESSFULLY");
          AppToast.showSuccess("OTP sent successfully", title: "Success");
          onVerificationIdReceived(newVerificationId);
          setVerificationId(newVerificationId);
          isResending = false;
          update();
        },
        codeAutoRetrievalTimeout: (String newVerificationId) {
          isResending = false;
          update();
        },
      );
    } catch (e) {
      print("❌ RESEND OTP ERROR: $e");
      AppToast.showError("Failed to resend OTP", title: "Error");
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
      AppToast.showWarning(
        "Please enter a valid 10 digit mobile number",
        title: "Invalid Number",
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
        String message = loginResponse.value?.message ?? "Login successful";
        String token = loginResponse.value!.token.toString();
        String userId = loginResponse.value!.customer?.id?.toString() ?? "";

        // Save session persistently so user does not get logged out
        await AuthHelper.saveSession(token: token, userId: userId);

        AppToast.showSuccess(message, title: "Success");

        if (loginResponse.value!.type.toString() != "existing_user") {
          Get.offAll(() => CreateProfileScreen(token: token, number: phoneNumber.toString()));
        } else {
          Get.offAll(() => MainScreen());
        }
      } else {
        AppToast.showError(loginResponse.value?.message ?? "Login failed", title: "Failed");
      }
    } catch (e) {
      update();
      print("LOGIN ERROR => $e");
      AppToast.showError("Login failed. Please try again.", title: "Error");
    } finally{
      isLoading = false;
    }
  }

}
