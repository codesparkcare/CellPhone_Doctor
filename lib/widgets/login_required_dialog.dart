import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../screens/Auth/login_screen.dart';

void showLoginRequiredDialog(
  BuildContext context, {
  String title = "Login Required",
  String subtitle = "Please login to access this feature\nand continue with your booking.",
  VoidCallback? onLoginSuccess,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Illustration with Shield & Lock and Sparkles
                    SizedBox(
                      height: 90.h,
                      width: 120.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer soft blue glow circle
                          Container(
                            width: 76.r,
                            height: 76.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEBF3FE),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Decorative sparkles around the badge
                          Positioned(
                            top: 8.h,
                            left: 18.w,
                            child: Icon(
                              Icons.auto_awesome,
                              size: 14.sp,
                              color: const Color(0xFF93C5FD),
                            ),
                          ),
                          Positioned(
                            top: 4.h,
                            right: 28.w,
                            child: Container(
                              width: 7.r,
                              height: 7.r,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12.h,
                            left: 14.w,
                            child: Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: const BoxDecoration(
                                color: Color(0xFF93C5FD),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16.h,
                            right: 18.w,
                            child: Icon(
                              Icons.auto_awesome,
                              size: 13.sp,
                              color: const Color(0xFF93C5FD),
                            ),
                          ),
                          // Blue Shield with Lock
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.shield,
                                size: 52.sp,
                                color: const Color(0xFF2563EB),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 2.h),
                                child: Icon(
                                  Icons.lock_rounded,
                                  size: 20.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Subtitle
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // Benefits Card
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildFeatureRow(
                            icon: Icons.shield_outlined,
                            title: "Secure & Safe",
                            subtitle: "Your data is always protected",
                          ),
                          Divider(
                            height: 20.h,
                            thickness: 1,
                            color: const Color(0xFFE2E8F0),
                          ),
                          _buildFeatureRow(
                            icon: Icons.speed_rounded,
                            title: "Faster Experience",
                            subtitle: "Save time with your account",
                          ),
                          Divider(
                            height: 20.h,
                            thickness: 1,
                            color: const Color(0xFFE2E8F0),
                          ),
                          _buildFeatureRow(
                            icon: Icons.cloud_outlined,
                            title: "Sync Across Devices",
                            subtitle: "Access your bookings anywhere",
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Get.to(() => const LoginScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.login_rounded,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Footer Note
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified,
                          color: const Color(0xFF2563EB),
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            "We value your privacy and never share your data.",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Close Button (Top-Right)
              Positioned(
                top: 14.h,
                right: 14.w,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.r),
                    onTap: () => Navigator.pop(dialogContext),
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16.sp,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildFeatureRow({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(
        icon,
        color: const Color(0xFF2563EB),
        size: 22.sp,
      ),
      SizedBox(width: 14.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
