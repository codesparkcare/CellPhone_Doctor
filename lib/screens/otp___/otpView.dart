import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';

import '../../helpers/app_toast.dart';
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
    
    // Auto-focus on OTP field & listen for automatic SMS retrieval
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();

      final OtpController controller = Get.put(OtpController());
      controller.onCodeAutoFilled = (code) {
        if (mounted) {
          setState(() {
            _otpController.text = code;
          });
          _handleOtpSubmit(code);
        }
      };
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

    final OtpController controller = Get.find<OtpController>();
    String activeId = verificationId.isNotEmpty ? verificationId : controller.verificationId;

    if (activeId.isEmpty && !kIsWeb) {
      AppToast.showWarning("OTP code is still being generated. Please wait a moment.", title: "Please Wait");
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      controller.phoneNumber = widget.number;
      controller.otp = otpCode.trim();

      if (activeId != "web_otp" && FirebaseAuth.instance.currentUser == null) {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: activeId,
          smsCode: otpCode.trim(),
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      await controller.login();
      print("✅ Login Success");
    } catch (e) {
      print("❌ OTP VERIFY ERROR: $e");
      if (mounted && FirebaseAuth.instance.currentUser == null) {
        AppToast.showError("Incorrect OTP: $e", title: "Failed");
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
                          autofillHints: const [AutofillHints.oneTimeCode],
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
                            if (value.length == 6 && !_isVerifying) {
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
            const SizedBox(height: 30),

            // Stable non-blinking Verify button with embedded loading spinner
            GetBuilder<OtpController>(
              builder: (controller) {
                final bool isBusy = controller.isLoading || _isVerifying;
                final bool isComplete = _otpController.text.trim().length == 6;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (isComplete && !isBusy)
                          ? () => _handleOtpSubmit(_otpController.text)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        disabledBackgroundColor: const Color(0xFF90CAF9),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isBusy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Verify and Create Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

}