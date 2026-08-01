
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cellphone_doctor/utils/app_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../home_controller/home_controller.dart';

class CarouselHome extends StatelessWidget {
  final bool autoscroll;
  final bool showIndicator;
  final List<String>? imageUrls;
  final bool isLoading;

  const CarouselHome({super.key, this.autoscroll = true,this.showIndicator = true, this.imageUrls, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      global: false,
      id: 'carousel',
      init: HomeController(initialImages: imageUrls ?? [])..autoscroll = autoscroll,
      builder: (controller) {
        final provided = (imageUrls ?? const <String>[])
            .map((u) => u)
            .where((u) => u.startsWith('http'))
            .toList();
        print('CAROUSEL DEBUG: imageUrls length is ${imageUrls?.length}');
        print('CAROUSEL DEBUG: provided length is ${provided.length}');
        print('CAROUSEL DEBUG: controller.images length is ${controller.images.length}');
        // Use postFrameCallback to avoid updating state during build
        if (provided.isNotEmpty && !listEquals(provided, controller.images)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.setImages(provided);
          });
        }
        final bool showSkeleton = isLoading || controller.images.isEmpty;
        if (showSkeleton) {
          return Column(
            children: [
              SizedBox(
                height: 180.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              if (showIndicator)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final bool isActive = index == 0;
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      height: 4.h,
                      width: isActive ? 22.w : 8.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    );
                  }),
                ),
            ],
          );
        }
        return Column(
          children: [
            SizedBox(
              height: 180.h,
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.images.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  final raw = controller.images[index];
                  final src = raw;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: buildAppNetworkImage(
                          imageUrl: src,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    );
                },
              ),
            ),

            SizedBox(height: 10.h),
            if (showIndicator)
              GetBuilder<HomeController>(
                global: false,
                id: 'indicator',
                init: controller,
                builder: (ctrl) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(ctrl.images.length, (index) {
                      bool isActive = ctrl.currentPage == index;
                      return AnimatedContainer(
                        key: ValueKey(index), // 🩹 helps Flutter track widgets
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        height: 4.h,
                        width: isActive ? 22.w : 8.w,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.grey
                              : Colors.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      );
                    }),
                  );
                },
              ),

          ],
        );
      },
    );
  }
}
