import 'package:cellphone_doctor/widgets/viewstore_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../screens/main_screen.dart';
import '../screens/tracking/tracking_order_view.dart';

void showBookingConfirmedDialog(String status) {
  Get.dialog(
    Center(
      child: Container(
        width: 300.w,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                height: 80.h,
                width: 80.h,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 50.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                "Your booking is\nconfirmed",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 10.h),

              Text(
                "Thank you for your booking. The store person will contact you soon about the service you're looking for.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 25.h),


              // SizedBox(
              //   width: double.infinity,
              //   height: 46.h,
              //   child: ElevatedButton(
              //     onPressed: () async{
              //
              //       if(status == "1"){
              //         Get.back();
              //         await Future.delayed(const Duration(milliseconds: 200));
              //         showStoreInfoDialog();
              //       }else{
              //         Get.back();
              //         await Future.delayed(const Duration(milliseconds: 200));
              //         Get.off(() =>  TrackingOrderView());
              //       }
              //
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.blue,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(25.r),
              //       ),
              //     ),
              //     child: Text(
              //       status == "1"?"View Store":"Track Order",
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 15.sp,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(height: 12.h),

              GestureDetector(
                onTap: () {
                  Get.offAll(() => MainScreen());
                },
                child: Text(
                  "Go to Home",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}
