import 'package:cellphone_doctor/ApiService/ApiService.dart';
import 'package:cellphone_doctor/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../controller/navBar_controller.dart';

class CourseController extends GetxController {
  bool isLoading = true;
  bool isSubmitting = false;
  List<CourseData> courses = [];
  CourseModel? courseModel;

  final PageController videoPageController = PageController();
  List<VideoPlayerController> videoControllers = [];
  int currentVideoIndex = 0;

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
  }

  final List<IconData> tabIcons = [
    Icons.star,
    Icons.star,
    Icons.star_half,
    Icons.wb_sunny_outlined,
  ];
  int selectedTab = 0;



  Future<void> fetchCourses() async {
    isLoading = true;
    update();
    try {
      var response = await ApiService.getData(
          uri: '/course', isAuthorized: false, context: Get.context);
      if (response != null && response != "failed") {
        courseModel = CourseModel.fromJson(response);
        if (courseModel?.data != null) {
          courses = courseModel!.data!;
        }
        if (courseModel?.video != null && courseModel!.video!.isNotEmpty) {
          for (int i = 0; i < courseModel!.video!.length; i++) {
            var v = courseModel!.video![i];
            if (v.url != null) {
              VideoPlayerController controller =
                  VideoPlayerController.network(v.url!);
              videoControllers.add(controller);
              controller.initialize().then((_) {
                // Auto play the first video if we are on the course tab
                if (i == 0 &&
                    Get.isRegistered<NavController>() &&
                    Get.find<NavController>().currentIndex == 3) {
                  controller.play();
                }
                update();
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching courses: $e");
    } finally {
      isLoading = false;
      update();
    }
  }


  void changeTab(int index) {
    selectedTab = index;
    update();
  }

  void updatePage(int index) {
    selectedTab = index;
    update();
  }

  bool _wasPlayingBeforeScroll = false;
  bool _autoPausedByScroll = false;

  void onScrollAwayFromVideo() {
    if (currentVideoIndex < videoControllers.length) {
      var controller = videoControllers[currentVideoIndex];
      if (controller.value.isInitialized && controller.value.isPlaying) {
        _wasPlayingBeforeScroll = true;
        _autoPausedByScroll = true;
        controller.pause();
        update();
      }
    }
  }

  void onScrollBackToVideo() {
    if (_autoPausedByScroll) {
      _autoPausedByScroll = false;
      if (currentVideoIndex < videoControllers.length) {
        var controller = videoControllers[currentVideoIndex];
        if (controller.value.isInitialized && !controller.value.isPlaying && _wasPlayingBeforeScroll) {
          controller.play();
          update();
        }
      }
    }
  }

  void onVideoPageChanged(int index) {
    currentVideoIndex = index;
    _autoPausedByScroll = false;
    _wasPlayingBeforeScroll = true;
    pauseAllVideos();
    if (index < videoControllers.length &&
        videoControllers[index].value.isInitialized) {
      videoControllers[index].play();
    }
    update();
  }

  final List<Map<String, dynamic>> whyChooseUsList = [
    {"title": "Expert Hands-On Training", "icon": Icons.handyman_outlined},
    {"title": "Career Support", "icon": Icons.work_outline},
    {
      "title": "Recognized Certification",
      "icon": Icons.workspace_premium_outlined,
    },
    {"title": "Industry-Relevant Skills", "icon": Icons.school_outlined},
  ];

  void toggleVideoPlay(int index) {
    if (index < videoControllers.length) {
      var controller = videoControllers[index];
      if (controller.value.isInitialized) {
        if (controller.value.isPlaying) {
          controller.pause();
          _wasPlayingBeforeScroll = false;
          _autoPausedByScroll = false;
        } else {
          pauseAllVideos(); // ensure siblings are paused
          controller.play();
          _wasPlayingBeforeScroll = true;
          _autoPausedByScroll = false;
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

  void playVideoAt(int index) {
    if (index < videoControllers.length &&
        videoControllers[index].value.isInitialized) {
      videoControllers[index].play();
      _wasPlayingBeforeScroll = true;
      _autoPausedByScroll = false;
      update();
    }
  }

  Future<void> submitCourseDetails({
    required String name,
    required String mobile,
    required String place,
    required String courseId,
  }) async {
    isSubmitting = true;
    update();
    try {
      final response = await ApiService.postRequest(
          'course?name=$name&mobile=$mobile&place=$place&course_id=$courseId', {});
      if (response != null && response['status'] == true) {
        Get.back(); // Close dialog
        Get.snackbar(
          "Success",
          "Submitted Successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
        );
      } else {
        Get.snackbar(
          "Error",
          response['message'] ?? "Submission failed",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting = false;
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
}
