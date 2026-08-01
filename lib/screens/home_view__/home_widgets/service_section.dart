import 'package:cellphone_doctor/screens/home_view__/home_controller/home_controller.dart';
import 'package:cellphone_doctor/models/app/getHomeListModel.dart';
import 'package:cellphone_doctor/screens/service__/service_view.dart';
import 'package:cellphone_doctor/utils/app-sizes.dart';
import 'package:cellphone_doctor/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../models/app/getHomeListModel.dart' as home;

class ServiceSection extends StatelessWidget {
  final List<Spare>? spares;
  final List<home.Categories>? categoryList;
  ServiceSection({super.key, this.spares,required this.categoryList});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      tag: 'service',
      init: HomeController(),
      builder: (controller) {
        final List<Spare> allSpares = spares ?? const <Spare>[];
        final bool isLaptopTab = controller.selectedTab == 1; // 1 = Laptop, 0 = Mobile
        final List<Spare> filteredSpares = allSpares
            .where((s) => (isLaptopTab ? s.type == "2" : s.type == "1"))
            .where((s) => s.isFeatured == true)
            .toList()
          ..sort((a, b) {
            final num aSeq = a.sequence ?? 0;
            final num bSeq = b.sequence ?? 0;
            return aSeq.compareTo(bSeq);
          });

        return Container(
          margin: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 10.h, top: 0.h),
          padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 6.h, bottom: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8FE),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Services",
                        style: TextStyle(
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: tabButton("Mobile", 0, controller),
                      ),
                      SizedBox(width: 16.w),
                      Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: tabButton("Laptop", 1, controller),
                      ),
                    ],
                  ),
                  if (filteredSpares.length > 6)
                    GestureDetector(
                      onTap: () {
                        controller.toggleShowAllSpares();
                      },
                      child: Text(
                        controller.showAllSpares ? "See less" : "See more",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              kHeight12,

              // 🔹 Services Grid
              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.showAllSpares
                    ? (filteredSpares.length > 9 ? 9 : filteredSpares.length)
                    : (filteredSpares.length > 6 ? 6 : filteredSpares.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14.w,
                  mainAxisSpacing: 14.h,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final spare = filteredSpares[index];
                  return ServiceItem(
                    title: _formatTitle(spare.title ?? ''),
                    imageUrl: spare.logoUrl ?? '',
                    onTap: () {
                      int selectPosition=0;
                      if(spare.type.toString() == "1"){
                        selectPosition = 0;
                      } else{
                        selectPosition = 1;
                      }
                      Get.to(() => ServiceView(
                        categoryList: categoryList,
                        initialIndex: selectPosition,
                        spareID: int.parse(spare.id.toString()),
                      ));
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTitle(String input) {
    if (input.isEmpty) return input;
    final String withSpaces = input.replaceAll('-', ' ');
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }

  Widget tabButton(String label, int index, HomeController controller) {
    final bool active = controller.selectedTab == index;
    return GestureDetector(
      onTap: () => controller.switchTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: active ? Colors.black : Colors.black54,
            ),
          ),
          SizedBox(height: 4.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 2.h,
            width: active ? 35.w : 0,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback? onTap;

  const ServiceItem({
    super.key,
    required this.title,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            placeholder: (context, url) => Skeletonizer(
              enabled: true,
              child: Container(color: Colors.grey.shade100),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
