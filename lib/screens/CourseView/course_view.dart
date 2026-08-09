import 'package:cellphone_doctor/screens/CourseView/controller/course_controller.dart';
import '../../controller/navBar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:video_player/video_player.dart';

import '../../utils/app_colors.dart';
import 'package:cellphone_doctor/utils/app_network_image.dart';
import '../../widgets/course_confirm.dart';

class CourseView extends StatelessWidget {
  const   CourseView({super.key});

  @override 
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return GetBuilder<CourseController>(
      init: CourseController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
              onPressed: () {
                Get.find<NavController>().changePage(0);
              },
            ),
            title: Text(
              "Course",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                children: [
                  Container(
                    height: size.height * 0.25,
                    width: size.width,
                    child: controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : controller.videoControllers.isNotEmpty
                            ? PageView.builder(
                                controller: controller.videoPageController,
                                onPageChanged: controller.onVideoPageChanged,
                                itemCount: controller.videoControllers.length,
                                itemBuilder: (context, index) {
                                  var vController =
                                      controller.videoControllers[index];
                                  if (!vController.value.isInitialized) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: FittedBox(
                                            fit: BoxFit.cover,
                                            child: SizedBox(
                                              width:
                                                  vController.value.size.width,
                                              height:
                                                  vController.value.size.height,
                                              child: VideoPlayer(vController),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (!vController.value.isPlaying)
                                        GestureDetector(
                                          onTap: () => controller
                                              .toggleVideoPlay(index),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.blue
                                                  .withOpacity(0.3),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 55,
                                            ),
                                          ),
                                        )
                                      else
                                        GestureDetector(
                                          onTap: () => controller
                                              .toggleVideoPlay(index),
                                          child: Container(
                                            color: Colors.transparent,
                                            height: size.height * 0.25,
                                            width: size.width * 0.9,
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: const Text("No Course Video Available"),
                              ),
                  ),

                  if (controller.videoControllers.length > 1)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.videoControllers.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            height: 8.h,
                            width: controller.currentVideoIndex == index
                                ? 24.w
                                : 8.w,
                            decoration: BoxDecoration(
                              color: controller.currentVideoIndex == index
                                  ? Colors.blue
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 16.h),

                  Text(
                    "We provide advanced Mobile Service Chip Level Training in Chennai. Our in-depth syllabus gives you practical knowledge and real-time experience to make you a skilled and confident Mobile Service Engineer. Build your career with us and achieve success.",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12.sp,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFeatureCard(Icons.verified_user_outlined, "ISO Certificate", "Get ISO Certified Certificate upon successful completion."),
                        SizedBox(width: 12.w),
                        _buildFeatureCard(Icons.work_outline, "100% Job Placement", "We provide 100% job placement assistance to all our students."),
                        SizedBox(width: 12.w),
                        _buildFeatureCard(Icons.handshake_outlined, "Franchise Opportunity", "Get franchise opportunity to start your own service center."),
                        SizedBox(width: 12.w),
                        _buildFeatureCard(Icons.support_agent_outlined, "Lifetime Support", "Lifetime technical support even after course completion."),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Our Courses",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  GetBuilder<CourseController>(
                    builder: (v) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: List.generate(
                          v.courses.length,
                          (index) {
                            bool isSelected = v.selectedTab == index;
                            return GestureDetector(
                              onTap: () => v.changeTab(index),
                              child: Container(
                                margin: EdgeInsets.only(right: 8.w),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue.shade700 : Colors.white,
                                  border: Border.all(
                                    color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                  child: Text(
                                    v.courses[index].title ?? "N/A",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.white : Colors.black87,
                                    ),
                                  ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 18.h),

                  if (controller.courses.isNotEmpty)
                    GetBuilder<CourseController>(
                      builder: (v) {
                        final course = v.courses[v.selectedTab];
                        final topics = course.description?.split(',') ?? [];
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 🔹 Course Details Card
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: course.image != null && course.image!.isNotEmpty
                                        ? buildAppNetworkImage(
                                            imageUrl: course.image!,
                                            height: 100.h,
                                            width: 120.w,
                                            fit: BoxFit.cover,
                                            errorWidget: (context, error, stackTrace) => Image.asset(
                                              "assets/course/course_banner.png",
                                              height: 100.h,
                                              width: 120.w,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Image.asset(
                                            "assets/course/course_banner.png",
                                            height: 100.h,
                                            width: 120.w,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                course.title ?? "Basic Level Course",
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(10.r),
                                              ),
                                              child: Text(
                                                "For Beginners",
                                                style: TextStyle(fontSize: 8.sp, color: Colors.blue.shade700),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(
                                          "Perfect for beginners who want to start their journey in mobile repairing industry.",
                                          style: TextStyle(fontSize: 10.sp, color: Colors.black87, height: 1.2),
                                        ),
                                        SizedBox(height: 12.h),
                                        Wrap(
                                          spacing: 6.w,
                                          runSpacing: 6.h,
                                          children: [


                                            _buildTag(Icons.precision_manufacturing_outlined, "Hands-On"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24.h),

                            Text(
                              "Topics We Cover",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 12.h),

                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: topics.length,
                              separatorBuilder: (context, _) => Divider(color: Colors.grey.shade200),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 24.w,
                                        width: 24.w,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade700,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          (index + 1).toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Text(
                                          topics[index].trim(),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),

                  SizedBox(height: 20.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ready to start your career in Mobile Repairing?",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "Join thousands of successful service engineers today!",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 40.h,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showDetailsDialog(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Join Now",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Icon(Icons.arrow_forward, color: Colors.white, size: 16.sp),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.verified_user_outlined, color: Colors.blue.shade700, size: 14.sp),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      "Trusted by 50,000+ Students",
                                      style: TextStyle(fontSize: 8.sp, color: Colors.black54),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Reusable Feature Card
Widget _buildFeatureCard(IconData icon, String title, String description) {
  return Container(
    width: 125.w,
    height: 205.h,
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade200),
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue.shade700, size: 26.sp),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 36.h,
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 24.w,
          height: 2.h,
          color: Colors.grey.shade300,
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: Center(
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.black54,
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// Reusable Tag Widget
Widget _buildTag(IconData icon, String text) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.05),
      border: Border.all(color: Colors.blue.withOpacity(0.1)),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 12.sp),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            color: Colors.blue.shade700,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
