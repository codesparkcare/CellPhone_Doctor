import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:cellphone_doctor/ApiService/ApiService.dart';
import 'package:cellphone_doctor/models/app/review_model.dart';

import '../../../controller/navBar_controller.dart';

class ReviewController extends GetxController {
  final PageController videoPageController = PageController();
  List<VideoPlayerController> videoControllers = [];
  int currentVideoIndex = 0;

  List<ReviewData> reviewList = [];
  bool isLoading = false;
  bool isExpanded = false;
  int displayedReviewsCount = 10;


  @override
  void onInit() {
    super.onInit();
    getReviews();
  }

  Future<void> getReviews() async {
    isLoading = true;
    update();
    try {
      var response = await ApiService.getRequest("review");
      if (response != null) {
        ReviewModel reviewModel = ReviewModel.fromJson(response);
        if (reviewModel.data != null) {
          reviewList = reviewModel.data!;
          shuffleList(); // Shuffle after loading
        }
        
        // Handle videos
        if (reviewModel.video != null && reviewModel.video!.isNotEmpty) {
          // Dispose existing controllers if any
          for (var controller in videoControllers) {
            controller.dispose();
          }
          videoControllers.clear();

          for (int i = 0; i < reviewModel.video!.length; i++) {
            var v = reviewModel.video![i];
            if (v.url != null) {
              String videoUrl = v.url!;
              if (!videoUrl.startsWith('http')) {
                final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
                videoUrl = videoUrl.startsWith('/') ? '$baseUrl$videoUrl' : '$baseUrl/$videoUrl';
              }
              
              // Append timestamp to bypass cache
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              videoUrl = videoUrl.contains('?') ? '$videoUrl&t=$timestamp' : '$videoUrl?t=$timestamp';
              
              VideoPlayerController controller = VideoPlayerController.network(videoUrl);
              videoControllers.add(controller);
              controller.initialize().then((_) {
                 // Auto play the first video if we are on the review tab
                if (i == 0 && Get.isRegistered<NavController>() && Get.find<NavController>().currentIndex == 1) {
                  controller.play();
                }
                update();
              }).catchError((error) {
                debugPrint("Video init error: $error for url: $videoUrl");
                update();
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  void shuffleList() {
    if (reviewList.isNotEmpty) {
      reviewList.shuffle();
      update();
    }
  }

  void loadMoreReviews() {
    displayedReviewsCount += 10;
    update();
  }

  void onVideoPageChanged(int index) {
    currentVideoIndex = index;
    pauseAllVideos();
    if (index < videoControllers.length &&
        videoControllers[index].value.isInitialized) {
      videoControllers[index].play();
    }
    update();
  }

  void toggleVideoPlay(int index) {
    if (index < videoControllers.length) {
      var controller = videoControllers[index];
      if (controller.value.isInitialized) {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          pauseAllVideos(); // ensure siblings are paused
          controller.play();
        }
        update();
      }
    }
  }

  void pauseAllVideos() {
    for (var controller in videoControllers) {
      if (controller.value.isInitialized && controller.value.isPlaying) {
        controller.pause();
      }
    }
    update();
  }

  void pauseVideo() {
    pauseAllVideos();
  }

  void playVideo() {
    playVideoAt(currentVideoIndex);
  }

  void playVideoAt(int index) {
    if (index < videoControllers.length &&
        videoControllers[index].value.isInitialized) {
      videoControllers[index].play();
      update();
    }
  }

  @override
  void onClose() {
    for (var controller in videoControllers) {
      controller.dispose();
    }
    videoPageController.dispose();
    super.onClose();
  }

  Future<void> addReview({
    required String name,
    required String description,
    required int rating,
    File? image,
  }) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      List<MultipartRequestService> fields = [
        MultipartRequestService(
          fieldName: 'name',
          fieldValue: name,
          isField: true,
          isFile: false,
        ),
        MultipartRequestService(
          fieldName: 'rating',
          fieldValue: rating.toString(),
          isField: true,
          isFile: false,
        ),
        MultipartRequestService(
          fieldName: 'description',
          fieldValue: description,
          isField: true,
          isFile: false,
        ),
      ];

      // Add image if provided
      if (image != null) {
        fields.add(MultipartRequestService(
          fieldName: 'image',
          fieldValue: image.path,
          isField: false,
          isFile: true,
        ));
      }

      final response = await ApiService.multipartRequest(
        multipartRequestFields: fields,
        context: Get.context!,
        uri: '/customer/review',
        method: 'POST',
      );

      Get.back(); // Close loading dialog

      if (response['status'] == true) {
        Get.snackbar(
          'Success',
          'Review added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh the reviews list
        await getReviews();
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to add review',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      debugPrint('Error adding review: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
