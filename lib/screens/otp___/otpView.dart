import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';

import '../ProfileView/create_profile.dart';
import '../main_screen.dart';
import '../service_detail/service_detail_view.dart';
import 'OtpController/otp_controller.dart';

class OtpView extends StatefulWidget {
  final String number;
  final String id;
  final ConfirmationResult? confirmationResult;

  const OtpView({
    super.key,
    required this.number,
    required this.id,
    this.confirmationResult,
  });

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  String verificationId = "";
  TextEditingController _otpController = TextEditingController();
  FocusNode _otpFocusNode = FocusNode();
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    verificationId = widget.id;
    
    // Auto-focus on OTP field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleOtpSubmit(String otpCode) async {
    if (_isVerifying || otpCode.trim().length != 6) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      final OtpController controller = Get.find<OtpController>();
      controller.phoneNumber = widget.number;
      controller.otp = otpCode.trim();

      if (verificationId != "web_otp" && FirebaseAuth.instance.currentUser == null) {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otpCode.trim(),
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      await controller.login();
      print("✅ Login Success");
    } catch (e) {
      print("❌ OTP VERIFY ERROR: $e");
      if (mounted && FirebaseAuth.instance.currentUser == null) {
        Get.snackbar("Failed", "Incorrect OTP: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final OtpController controller = Get.put(OtpController());
    final size = MediaQuery.of(context).size;

    final double aspectRatio =
    (size.height < 700) ? 0.9 : (size.height < 800 ? 1.1 : 1.3);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Verify",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              "Code is send to ${widget.number}",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 25),

            // Interactive OTP Input Section (Stacking Boxes + Transparent TextField)
            GestureDetector(
              onTap: () {
                _otpFocusNode.requestFocus();
              },
              child: SizedBox(
                height: 60,
                width: 330,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Full-size Transparent TextField to capture Web Keyboard Focus
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.01,
                        child: TextField(
                          controller: _otpController,
                          focusNode: _otpFocusNode,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          autofocus: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            setState(() {}); // Refresh UI boxes
                            if (value.length == 6) {
                              _handleOtpSubmit(value);
                            }
                          },
                        ),
                      ),
                    ),

                    // Visible OTP Display Boxes
                    IgnorePointer(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          final bool isFocused = _otpFocusNode.hasFocus &&
                              (_otpController.text.length == index ||
                                  (_otpController.text.length == 6 && index == 5));
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            height: 50,
                            width: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6FA),
                              borderRadius: BorderRadius.circular(12),
                              border: isFocused
                                  ? Border.all(color: Colors.blue, width: 2)
                                  : Border.all(color: Colors.transparent, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  blurRadius: 2,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              index < _otpController.text.length
                                  ? _otpController.text[index]
                                  : "",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),
            GetBuilder<OtpController>(
              builder: (controller) {
                return Text.rich(
                  TextSpan(
                    text: "Don’t receive code? ",
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    children: [
                      TextSpan(
                        text: controller.resendTimer > 0
                            ? "Wait ${controller.resendTimer}s"
                            : (controller.isResending ? "Sending..." : "Request again"),
                        style: TextStyle(
                            color: controller.resendTimer > 0 || controller.isResending ? Colors.grey : Colors.blue,
                            fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          if (controller.resendTimer == 0 && !controller.isResending) {
                            controller.resendOtp(widget.number, onVerificationIdReceived: (id) {
                              setState(() {
                                verificationId = id;
                              });
                            });
                          }
                        },
                      ),
                    ],
                  ),
                );
              }
            ),
            const SizedBox(height: 25),

            GestureDetector(
              onTap: () {
                _handleOtpSubmit(_otpController.text);
              },
              child: GetBuilder<OtpController>(
                builder: (controller) {
                  final bool isActive = _otpController.text.length == 6;
                  return (controller.isLoading || _isVerifying)
                      ? const CircularProgressIndicator()
                      : Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: (isActive && !_isVerifying) ? Colors.blue : Colors.blue[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Verify and Create Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

}