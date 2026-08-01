import 'package:cellphone_doctor/screens/home_view__/home_controller/home_controller.dart';
import 'package:cellphone_doctor/models/app/getHomeListModel.dart';
import 'package:cellphone_doctor/screens/service__/service_view.dart';
import 'package:cellphone_doctor/utils/app-sizes.dart';
import 'package:cellphone_doctor/utils/app_colors.dart';
import 'package:cellphone_doctor/utils/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../service__/select_modal.dart';

class TopBrandSection extends StatelessWidget {
  final List<Brands>? brands;
  const TopBrandSection({super.key, this.brands});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        final List<Brands> allBrands = brands ?? const <Brands>[];
        final bool isLaptopTab = controller.selectedBrandTab == 1;
        final List<Brands> filteredBrands = allBrands
            .where((b) => isLaptopTab ? (b.category == 2) : (b.category == 1))
            .toList()
          ..sort((a, b) {
            final num aSeq = a.sequence ?? 0;
            final num bSeq = b.sequence ?? 0;
            return aSeq.compareTo(bSeq);
          });
        return Container(
          margin: EdgeInsets.only(left: 12.w, right: 12.w, top: 2.h, bottom: 10.h),
          padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.w, top: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xfff1f8fe),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Top Brands",
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
                  // GestureDetector(
                  //   onTap: filteredBrands.length > 8
                  //       ? () {
                  //           controller.toggleShowAllBrands();
                  //         }
                  //       : null,
                  //   child: filteredBrands.length > 8
                  //       ? Text(
                  //           controller.showAllBrands ? "See less" : "See more",
                  //           style: TextStyle(
                  //             color: Colors.blue,
                  //             fontSize: 13.sp,
                  //             fontWeight: FontWeight.w500,
                  //           ),
                  //         )
                  //       : const SizedBox.shrink(),
                  // ),
                ],
              ),
              kHeight12,
              /// 🔹 Brand Grid
               SizedBox(
                height: 85.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredBrands.length,
                  separatorBuilder: (context, index) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    final brand = filteredBrands[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => SelectModelScreen(
                              brandId: brand.id,
                              categoryid: brand.category,
                            ));
                      },
                      child: BrandItem(
                        title: _formatTitle(brand.name ?? ''),
                        imageUrl: brand.logoUrl ?? '',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 Reusable tab button
  Widget tabButton(String label, int index, HomeController controller) {
    final bool active = controller.selectedBrandTab == index;
    return GestureDetector(
      onTap: () => controller.switchBrandTab(index),
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

  String _formatTitle(String input) {
    if (input.isEmpty) return input;
    final String withSpaces = input.replaceAll('-', ' ');
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }
}


class BrandItem extends StatelessWidget {
  final String title;
  final String imageUrl;

  const BrandItem({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: buildAppNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          memCacheHeight: 150,
        ),
      ),
    );
  }
}
