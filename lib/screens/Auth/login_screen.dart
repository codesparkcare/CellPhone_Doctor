import 'package:cellphone_doctor/screens/Auth/controller/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:upgrader/upgrader.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cellphone_doctor/ApiService/ApiService.dart';
import 'package:cellphone_doctor/models/app/getHomeListModel.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../main_screen.dart';
import '../otp___/otpView.dart';
import '../otp___/OtpController/otp_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  late String otpVerificationId;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _prefetchHomeData();
  }

  Future<void> _prefetchHomeData() async {
    try {
      final successResult = await ApiService.getData(
        uri: "/home",
        isAuthorized: true,
        context: context,
      );

      if (successResult != null && successResult != "failed" && successResult is Map<String, dynamic>) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('home_api_cache_v1', jsonEncode(successResult));
        debugPrint("✅ Background Prefetch: /home data cached successfully");

        if (mounted) {
          final model = GetHomeListModel.fromJson(successResult);
          
          // 1. First 2 banners (above the fold)
          final bannerUrls = (model.banner ?? [])
              .map((b) => b.image ?? '')
              .where((u) => u.startsWith('http'))
              .take(2)
              .toList();

          // 2. First 4 category icons (above the fold)
          final categoryUrls = (model.categories ?? [])
              .map((c) => c.imageUrl ?? '')
              .where((u) => u.startsWith('http'))
              .take(4)
              .toList();

          // 3. Featured spares (above the fold)
          final mobileSpares = (model.spare ?? [])
              .where((s) => s.isFeatured == true && s.type == "1")
              .toList()
            ..sort((a, b) => (a.sequence ?? 0).compareTo(b.sequence ?? 0));
              
          final spareUrls = mobileSpares
              .map((s) => s.logoUrl ?? s.imageUrl ?? '')
              .where((u) => u.startsWith('http'))
              .take(9)
              .toList();

          // Precache images
          for (final url in bannerUrls) {
            precacheImage(CachedNetworkImageProvider(url), context);
          }
          for (final url in categoryUrls) {
            precacheImage(
              CachedNetworkImageProvider(url),
              context,
            );
          }
          for (final url in spareUrls) {
            precacheImage(
              CachedNetworkImageProvider(url),
              context,
            );
          }
          debugPrint("✅ Background Prefetch: Precached banner, category, and spare images");
        }
      }
    } catch (e) {
      debugPrint("Background Prefetch Error: $e");
    }
  }

  Future<void> sendOtp(String phone) async {
    setState(() {
      loading = true;
    });

    String formattedPhone =
    phone.startsWith('+') ? phone : "+91$phone";
    print("formattedPhone$formattedPhone");
    
    if (kIsWeb) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      Get.to(() => OtpView(
            number: phone,
            id: "web_otp",
          ));
      return;
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: formattedPhone,

      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          final OtpController otpController = Get.put(OtpController());
          otpController.phoneNumber = phone;
          await otpController.login();
        } catch (e) {
          print("Auto sign-in error: $e");
          Get.snackbar("Error", "Auto-verification failed.");
        }
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      },

      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          loading = false;
        });
        print("OTP Error Code: ${e.code}");
        print("OTP Error Message: ${e.message}");
      },

      codeSent: (String verificationId, int? resendToken) {
        otpVerificationId = verificationId;
        print("✅ OTP Sent Successfully");
        setState(() {
          loading = false;
        });
        Get.to(() => OtpView(number: phone,id:verificationId));
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        print("Auto Retrieval Timeout");
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      },
    );
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      print("Synchronous error during verifyPhoneNumber: $e");
      Get.snackbar("Error", "Could not request OTP: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _formKey = GlobalKey<FormState>();
    final AuthController controller = Get.put(AuthController());

    final double aspectRatio =
    (size.height < 700) ? 0.9 : (size.height < 800 ? 1.1 : 1.3);

    return UpgradeAlert(
      showIgnore: false,
      showLater: true,
      upgrader: Upgrader(
        debugLogging: true,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          automaticallyImplyLeading: false,
          title: Text(
            "Login / Signup",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: TextButton(
                onPressed: () => Get.off(() => MainScreen()),
                child: Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: BottomWavePainter(),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
              SizedBox(height: 10.h),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 40.w),
                child: Image.asset(
                  "assets/images/login.png",
                  height: size.height * 0.22,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "You’ll receive 6 digit code to verify next",
                style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: GetBuilder<AuthController>(
                  builder: (controller) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 15,
                            spreadRadius: 2,
                            offset: const Offset(0, 4), // Shadow position
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              "+91",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextFormField(
                              controller: controller.phoneNumber,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              decoration: InputDecoration(
                                counterText: "", // hides counter
                                border: InputBorder.none,
                                hintText: "Enter mobile number",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter mobile number";
                                }
                                if (value.length != 10) {
                                  return "Enter valid 10-digit number";
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () {
                              if (controller.phoneNumber.text.isEmpty) {
                                showTopSnackBar(
                                  Overlay.of(context),
                                  const CustomSnackBar.error(message: "Enter Mobile number"),
                                );
                              } else if (controller.phoneNumber.text.length != 10) {
                                showTopSnackBar(
                                  Overlay.of(context),
                                  const CustomSnackBar.error(message: "Invalid Number"),
                                );
                              } else {
                                sendOtp(controller.phoneNumber.text);
                              }
                            },
                            child: loading
                                ? Container(
                                    height: 44.h,
                                    width: 100.w,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade600,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    alignment: Alignment.center,
                                    child: const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    ),
                                  )
                                : Container(
                                    height: 44.h,
                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade600,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Continue",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 30.h),
              
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 2.1,
                    children: [
                      _buildFeatureCardRich(
                        customIcon: Icon(Icons.business_rounded, color: Colors.blue.shade600, size: 28.sp),
                        textSpan: TextSpan(
                          children: [
                            TextSpan(text: '15+\n', style: TextStyle(color: Colors.blue.shade700, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            TextSpan(text: 'Service\nCenters'),
                          ],
                        ),
                      ),
                      _buildFeatureCardRich(
                        customIcon: Icon(Icons.star_rounded, color: Colors.amber.shade500, size: 32.sp),
                        textSpan: TextSpan(
                          children: [
                            TextSpan(text: '4.9 ', style: TextStyle(color: Colors.blue.shade700, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            WidgetSpan(child: Icon(Icons.star, color: Colors.amber, size: 14.sp), alignment: PlaceholderAlignment.middle),
                            const TextSpan(text: '\nCustomer\nRating'),
                          ],
                        ),
                      ),
                      _buildFeatureCardRich(
                        customIcon: Icon(Icons.verified_user_rounded, color: Colors.green.shade600, size: 28.sp),
                        textSpan: TextSpan(
                          children: [
                            const TextSpan(text: 'Up to\n'),
                            TextSpan(text: '1 Year\n', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                            const TextSpan(text: 'Warranty'),
                          ],
                        ),
                      ),
                      _buildFeatureCardRich(
                        customIcon: Icon(Icons.settings_rounded, color: Colors.blue.shade800, size: 28.sp),
                        textSpan: TextSpan(
                          children: [
                            const TextSpan(text: 'Original &\n'),
                            TextSpan(text: 'High-Quality\n', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                            const TextSpan(text: 'Parts'),
                          ],
                        ),
                      ),
                      _buildFeatureCardRich(
                        customIcon: Icon(Icons.lock_rounded, color: Colors.blue.shade600, size: 28.sp),
                        textSpan: TextSpan(
                          children: [
                            const TextSpan(text: 'Your Data is\n'),
                            TextSpan(text: 'Safe & Secure', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      _buildFeatureCardRich(
                        customIcon: Icon(Icons.delivery_dining_rounded, color: Colors.blue.shade600, size: 28.sp),
                        textSpan: TextSpan(
                          children: [
                            TextSpan(text: 'Doorstep\n', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                            const TextSpan(text: 'Service\nAvailable'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
  
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCardRich({
    Widget? customIcon,
    required InlineSpan textSpan,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FC), // very light blue
              shape: BoxShape.circle,
            ),
            child: customIcon ?? const SizedBox(),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.3,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter', // Default fallback
                ),
                children: [textSpan],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Lightest blue wave
    final paint1 = Paint()
      ..color = const Color(0xFFEDF3FD)
      ..style = PaintingStyle.fill;
      
    // Slightly darker blue wave
    final paint2 = Paint()
      ..color = const Color(0xFFDFEAFD)
      ..style = PaintingStyle.fill;

    // Darkest blue wave (still very light)
    final paint3 = Paint()
      ..color = const Color(0xFFD0E0FB)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.82);
    path1.quadraticBezierTo(
        size.width * 0.3, size.height * 0.95, size.width * 0.7, size.height * 0.88);
    path1.quadraticBezierTo(
        size.width * 0.9, size.height * 0.84, size.width, size.height * 0.87);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    final path2 = Path();
    path2.moveTo(0, size.height * 0.88);
    path2.quadraticBezierTo(
        size.width * 0.4, size.height * 1.0, size.width * 0.8, size.height * 0.92);
    path2.quadraticBezierTo(
        size.width * 0.95, size.height * 0.89, size.width, size.height * 0.91);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    final path3 = Path();
    path3.moveTo(0, size.height * 0.95);
    path3.quadraticBezierTo(
        size.width * 0.4, size.height * 0.90, size.width * 0.7, size.height * 0.96);
    path3.quadraticBezierTo(
        size.width * 0.9, size.height * 1.0, size.width, size.height * 0.95);
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
