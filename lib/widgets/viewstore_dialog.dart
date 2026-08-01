import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../screens/store/store_view.dart';

void showStoreInfoDialog() {
  Get.dialog(
    Center(
      child: Container(
        width: 320.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "RICH STREET ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(
                            text: "Chennai",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(4.w),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.red,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.asset(
                  "assets/images/store_img.png",
                  height: 120.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(height: 10.h),

              Text(
                "New Door No. AA-72, Old Door No. AA-107, Ground Floor, Shanthi Colony Main Road, IVth Avenue, Anna Nagar, Chennai - 600040, Ph: 9289390109",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12.5.sp,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 8.h),

              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.blue, size: 18.sp),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      "Timing: 11:00 AM - 10:00 PM",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40.h,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.call,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          "Call Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40.h,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.to(() => StoreView());
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.blue,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          "View More >>",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
