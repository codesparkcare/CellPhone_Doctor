import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../home_view__/home_widgets/Strore_section.dart';
import '../home_view__/home_widgets/carousel_area.dart';
import 'controller/store_controller.dart';

class StoreView extends StatelessWidget {
  const StoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoreController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Our Stores",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18.sp),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.asset(
                  "assets/images/ourstore.png",
                  height: size.height * 0.16,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 12.h),

              CarouselHome(autoscroll: true, showIndicator: true),

              SizedBox(height: 14.h),

              Text(
                controller.storeName,
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6.h),
              Text(
                controller.address,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.sp,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 10.h),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40.h,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.call,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          "Call Store",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: SizedBox(
                      height: 40.h,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.blue,
                          size: 18,
                        ),
                        label: const Text(
                          "Get Direction",
                          style: TextStyle(color: Colors.black),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14.h),
              Divider(thickness: 1, color: Colors.black12),

              // 🔹 Store Info
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    infoColumn("Open", controller.openDays),
                    infoColumn("Timings", controller.timing),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  infoColumn("Launched", controller.launched),
                  infoColumn("EMI Available", controller.emi),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Text(
                    "Ratings",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  Text(
                    " ${controller.rating}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              Text(
                "Our Achievements",
                style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: controller.achievements
                    .map(
                      (a) =>
                          _achievementCard(context,a['icon'], a['count'], a['title'],),
                    )
                    .toList(),
              ),
              SizedBox(height: 20.h),

              // 🔹 Store History
              Text(
                "Store History",
                style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8.h),
              Text(
                controller.historyText,
                style: TextStyle(
                  fontSize: 15.sp,
                  height: 1.5,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 18.h),

              // 🔹 More Stores
              Text(
                "More Stores",
                style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10.h),

              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: size.height * 0.16,
                    width: size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),

                  Positioned(
                    top: size.height * 0.03,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: size.height * 0.23,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        children: const [
                          StoreCard(
                            title: "RICH STREET",
                            address:
                                "New Door No. AA-72, Old Door No. AA-107, Ground Floor, Shanthi Colony Main Road, IVth Avenue, Anna Nagar, Chennai - 600040, Ph: 9289390109",
                            timing: "11:00 AM - 10:00 PM",
                          ),
                          StoreCard(
                            title: "ANNA NAGAR",
                            address:
                                "New Door No. AA-72, Old Door No. AA-107, Ground Floor, Shanthi Colony Main Road, IVth Avenue, Anna Nagar, Chennai - 600040, Ph: 9289390109",
                            timing: "11:00 AM - 10:00 PM",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.black54, fontSize: 17.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19.sp),
        ),
      ],
    );
  }

  Widget _achievementCard(BuildContext context,IconData imagePath, String count, String title) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.18,
      width: 105.w,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            // blurRadius: 8,
            //offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 Black circular background with icon/image
          Container(
            height: 55.h,
            width: 55.h,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(10.w),
            child: Icon(
              imagePath,
              //fit: BoxFit.contain,
              color: Colors.white, // keep white icon style
            ),
          ),
          SizedBox(height: 8.h),

          // 🔹 Count
          Text(
            count,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 3.h),

          // 🔹 Subtitle
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
