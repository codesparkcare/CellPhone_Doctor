import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:cellphone_doctor/controller/navBar_controller.dart';
import 'package:cellphone_doctor/utils/app_network_image.dart';
import 'controller/live_controller.dart';

class LiveView extends StatelessWidget {
  const LiveView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GetBuilder<LiveController>(
      init: LiveController(),
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
              "Live Video",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.circle, color: Colors.white, size: 8.sp),
                                        SizedBox(width: 4.w),
                                        Text(
                                          "LIVE",
                                          style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 2.w),
                                        Icon(Icons.sensors, color: Colors.white, size: 14.sp),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(fontSize: 27.sp, fontWeight: FontWeight.w900, height: 1.15),
                                      children: [
                                        TextSpan(text: "Live ", style: TextStyle(color: Colors.blue.shade700)),
                                        TextSpan(text: "from Our\n", style: TextStyle(color: Colors.black)),
                                        TextSpan(text: "Service Hub", style: TextStyle(color: Colors.blue.shade700)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.settings, color: Colors.blue.shade700, size: 16.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "Real People. Real Repairs. Real Transparency.",
                                    style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade400,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4.r),
                            topRight: Radius.circular(4.r),
                            bottomLeft: Radius.circular(45.r),
                            bottomRight: Radius.circular(45.r),
                          ),
                        ),
                        child: Container(
                          width: 75.w,
                          padding: EdgeInsets.only(top: 8.h, bottom: 24.h, left: 4.w, right: 4.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade900,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4.r),
                              topRight: Radius.circular(4.r),
                              bottomLeft: Radius.circular(45.r),
                              bottomRight: Radius.circular(45.r),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check, color: Colors.blue.shade700, size: 14.sp, weight: 900),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                "TRUSTED BY",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                "50,000+",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900),
                              ),
                              Text(
                                "CUSTOMERS",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  controller.isLoadingVideos
                      ? SizedBox(
                          height: size.height * 0.25,
                          child: const Center(child: CircularProgressIndicator()),
                        )
                      : controller.liveVideos.isEmpty
                          ? SizedBox(
                              height: size.height * 0.25,
                              child: const Center(
                                  child: Text("No live content available")),
                            )
                          : SizedBox(
                              height: size.height * 0.25,
                              child: PageView.builder(
                                itemCount: controller.liveVideos.length,
                                itemBuilder: (context, index) {
                                  final video = controller.liveVideos[index];
                                  final isPlaying =
                                      controller.currentPlayingIndex == index &&
                                          controller.videoController != null &&
                                          controller.videoController!.value
                                              .isInitialized;

                                  return Container(
                                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (controller.currentPlayingIndex == index && controller.videoController != null) {
                                              controller.togglePlay();
                                            } else if (video['url'] != null) {
                                              controller.initializeVideo(video['url']!, index);
                                            }
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(14.r),
                                            child: SizedBox(
                                              height: double.infinity,
                                              width: double.infinity,
                                              child: isPlaying
                                                  ? AspectRatio(
                                                      aspectRatio: controller
                                                          .videoController!
                                                          .value
                                                          .aspectRatio,
                                                      child: VideoPlayer(controller
                                                          .videoController!),
                                                    )
                                                  : Image.asset(
                                                      "assets/images/live_thumbNail.png",
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                        ),
                                        if (isPlaying && !controller.isPlaying)
                                          GestureDetector(
                                            onTap: controller.togglePlay,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.4),
                                                shape: BoxShape.circle,
                                              ),
                                              padding: EdgeInsets.all(12.w),
                                              child: Icon(
                                                Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 50.sp,
                                              ),
                                            ),
                                          )
                                        else if (!isPlaying)
                                          GestureDetector(
                                            onTap: () {
                                              if (video['url'] != null) {
                                                controller.initializeVideo(
                                                    video['url']!, index);
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                shape: BoxShape.circle,
                                              ),
                                              padding: EdgeInsets.all(12.w),
                                              child: Icon(
                                                Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 50.sp,
                                              ),
                                            ),
                                          ),
                                        /// 🔹 Current Date & Time Overlay (Top Left)
                                        Positioned(
                                          top: 10.h,
                                          left: 10.w,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.4),
                                              borderRadius: BorderRadius.circular(6.r),
                                            ),
                                            child: Text(
                                              "${controller.currentDate}  ${controller.currentTime}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 10.h,
                                          right: 10.w,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(20.r),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.circle,
                                                    color: Colors.white,
                                                    size: 10),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  "REC",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        /// 🔹 Viewers count (Bottom Left)
                                        Positioned(
                                          bottom: 10.h,
                                          left: 10.w,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(6.r),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.circle, color: Colors.green, size: 10.sp),
                                                SizedBox(width: 4.w),
                                                Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                                                SizedBox(width: 8.w),
                                                Icon(Icons.remove_red_eye, color: Colors.white, size: 12.sp),
                                                SizedBox(width: 4.w),
                                                Text("245 Watching", style: TextStyle(color: Colors.white, fontSize: 10.sp)),
                                              ],
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                  SizedBox(height: 20.h),
                  /// 🔹 Features Row 1
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFeatureItem(Icons.verified_user, "Expert\nEngineers"),
                        _buildVerticalDivider(),
                        _buildFeatureItem(Icons.settings, "Advanced\nEquipment"),
                        _buildVerticalDivider(),
                        _buildFeatureItem(Icons.workspace_premium, "Quality\nProcess"),
                        _buildVerticalDivider(),
                        _buildFeatureItem(Icons.lock, "100%\nSecure"),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  /// 🔹 Text Description
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(text: "At The Cellphone Doctor, we believe in complete transparency. "),
                        const TextSpan(text: "Watch your device repair ", style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: "LIVE ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        const TextSpan(text: "from our main service hub.\n", style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: "See every step, in real-time.", style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  /// 🔹 Features Row 2
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSmallFeatureItem(Icons.shield_outlined, "Upto 1 Year\nWarranty"),
                        _buildSmallVerticalDivider(),
                        _buildSmallFeatureItem(Icons.verified, "Genuine &\nReliable Parts"),
                        _buildSmallVerticalDivider(),
                        _buildSmallFeatureItem(Icons.security, "Data Safe\n& Secure"),
                        _buildSmallVerticalDivider(),
                        _buildSmallFeatureItem(Icons.timer_outlined, "Fast &\nReliable"),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  /// 🔹 Disclaimer
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Disclaimer: This video does not represent your mobile service.",
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontSize: 11.5.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.blue.shade900, thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          "Highlights of Our Services",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.blue.shade900, thickness: 1)),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: size.height * 0.22,
                    child: controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : controller.liveBanners.isEmpty
                            ? const Center(child: Text("No highlights available"))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                controller: controller.bannerScrollController,
                                itemCount: controller.liveBanners.length,
                                itemBuilder: (context, index) {
                                  final banner = controller.liveBanners[index];
                                  return Container(
                                    margin: EdgeInsets.only(right: 12.w),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Stack(
                                        children: [
                                          (banner.url != null && banner.url!.trim().isNotEmpty)
                                              ? buildAppNetworkImage(
                                                  imageUrl: banner.url!,
                                                  width: size.width * 0.85,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorWidget: (context, error, stackTrace) => itemPlaceholder(size),
                                                )
                                              : itemPlaceholder(size),
                                          Container(
                                            width: size.width * 0.85,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                  SizedBox(height: 50.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 28.sp),
        SizedBox(height: 8.h),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40.h,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildSmallFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade900, size: 20.sp),
        SizedBox(width: 6.w),
        Text(
          text,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallVerticalDivider() {
    return Container(
      height: 24.h,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget itemPlaceholder(Size size) {
    return Container(
      width: size.width * 0.65,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey.shade400,
        size: 32.sp,
      ),
    );
  }
}
