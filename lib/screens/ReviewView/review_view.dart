import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cellphone_doctor/utils/app_colors.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:cellphone_doctor/models/app/review_model.dart';

import '../../helpers/auth_helper.dart';
import '../../utils/app-sizes.dart';
import 'package:cellphone_doctor/controller/navBar_controller.dart';
import 'controller/review_controller.dart';

class ReviewView extends StatefulWidget {
  const ReviewView({super.key});

  @override
  State<ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<ReviewView> {

  final ReviewController controller = Get.put(ReviewController());
  final ScrollController scrollController = ScrollController();

  /// ✅ LOGIN STATUS
  Future<void> isLogin() async {
    bool status = await AuthHelper.getBool("isShowOnBoard") ?? false;
    if (status) {
      controller.isExpanded = true;
      controller.update();
    } else {
      controller.isExpanded = false;
      controller.update();
    }
  }

  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 50) {
      if (controller.reviewList.length > controller.displayedReviewsCount) {
        controller.loadMoreReviews();
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLogin();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return GetBuilder<ReviewController>(
      init: ReviewController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
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
              "Customer Review's",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: null,
            onPressed: () => _showAddReviewDialog(context, controller),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Column(
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
                                                color: AppColors.primary
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
                                  child: const Text("No Review Video Available"),
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
                                    ? AppColors.primary
                                    : Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                kHeight10,

                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Testimonials",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                kHeight10,

                controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.reviewList.isEmpty
                        ? const Center(child: Text("No reviews found"))
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 20.h),
                            itemCount: controller.reviewList.length > controller.displayedReviewsCount
                                ? controller.displayedReviewsCount
                                : controller.reviewList.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12.h,
                              crossAxisSpacing: 12.w,

                              ///childAspectRatio: 0.90,
                            ),
                            itemBuilder: (context, index) {
                              final item = controller.reviewList[index];
                              return TestimonialCard(
                                name: item.name ?? "",
                                review: item.description ?? "",
                                rating: int.tryParse(item.rating ?? "0") ?? 0,
                                image: item.image ?? "",
                              );
                            },
                          ),
                SizedBox(height: 100.h), // Extra space for FAB and bottom navigation


                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Row(
                //       children: [
                //         Icon(Icons.share_outlined,
                //             color: AppColors.primary, size: 18.sp),
                //         SizedBox(width: 5.w),
                //         Text(
                //           "Share App",
                //           style: TextStyle(
                //             color: AppColors.primary,
                //             fontSize: 14.sp,
                //             fontWeight: FontWeight.w500,
                //           ),
                //         ),
                //       ],
                //     ),
                //     Row(
                //       children: [
                //         Text(
                //           "Add Testimonials",
                //           style: TextStyle(
                //             color: AppColors.primary,
                //             fontSize: 14.sp,
                //             fontWeight: FontWeight.w500,
                //           ),
                //         ),
                //         SizedBox(width: 5.w),
                //         Container(
                //           decoration: const BoxDecoration(
                //             color: AppColors.primary,
                //             shape: BoxShape.circle,
                //           ),
                //           padding: EdgeInsets.all(4.w),
                //           child: Icon(
                //             Icons.add,
                //             color: Colors.white,
                //             size: 16.sp,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        )
        );
      },
    );
  }

  void _showAddReviewDialog(BuildContext context, ReviewController controller) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    double rating = 0;
    File? selectedImage;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 
                          MediaQuery.of(context).padding.bottom,
                  left: 20.w,
                  right: 20.w,
                  top: 20.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add Rating",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      hintText: "Enter your name",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade600),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Select Rating",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 30.sp,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (value) {
                      setState(() {
                        rating = value;
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Description",
                      hintText: "Write your review...",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 40.h), // Align icon to top
                        child: Icon(Icons.description_outlined, color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Upload Image",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          selectedImage = File(pickedFile.path);
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 110.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                        borderRadius: BorderRadius.circular(12.r),
                        color: AppColors.primary.withOpacity(0.03),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 28.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "Tap to upload image",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () async {
                            if (nameController.text.isNotEmpty && 
                                descriptionController.text.isNotEmpty && 
                                rating > 0) {
                              setState(() {
                                isLoading = true;
                              });
                              
                              await controller.addReview(
                                name: nameController.text,
                                description: descriptionController.text,
                                rating: rating.toInt(),
                                image: selectedImage,
                              );
                              
                              setState(() {
                                isLoading = false;
                              });
                              
                              Navigator.of(context).pop();
                            } else {
                              Get.snackbar(
                                "Error",
                                "Please fill all fields and select a rating",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18.sp,
                                      height: 18.sp,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      "Adding...",
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  "Add Review",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ));
          },
        );
      },
    );
  }
}

class TestimonialCard extends StatelessWidget {
  final String name;
  final String review;
  final int rating;
  final String image;

  const TestimonialCard({
    super.key,
    required this.name,
    required this.review,
    required this.rating,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 14.r,
                  backgroundColor: Colors.white24,
                  backgroundImage: (image.isNotEmpty && image.startsWith("http"))
                      ? CachedNetworkImageProvider(image)
                      : null,
                  child: (image.isEmpty || !image.startsWith("http"))
                      ? Icon(Icons.person, size: 18.r, color: Colors.white)
                      : null,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                size: 14.sp,
                color: index < rating ? Colors.amber : Colors.white24,
              ),
            ),
          ),

          SizedBox(height: 8.h),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                review,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
