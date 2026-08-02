import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OurProcessSection extends StatelessWidget {
  const OurProcessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 12.w, right: 12.w, top: 2.h, bottom: 10.h),
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.h, bottom: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xfff1f8fe),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              "Our Process",
              style: TextStyle(
                fontSize: 21.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              "assets/images/Process/Our-Process.png",
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}




