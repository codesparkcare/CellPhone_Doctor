import 'package:get/get.dart';
import '../helpers/auth_helper.dart';
import '../screens/CourseView/controller/course_controller.dart';
import '../screens/LiveView/controller/live_controller.dart';
import '../screens/ReviewView/controller/review_controller.dart';
import '../screens/home_view__/home_screen.dart';
import '../screens/service__/service_view.dart';

class NavController extends GetxController {

  int currentIndex = 0;
  static const String _storageKey = "last_nav_index";

  @override
  void onInit() {
    super.onInit();
    _loadLastIndex();
  }

  Future<void> _loadLastIndex() async {
    int? savedIndex = await AuthHelper.getInt(_storageKey);
    if (savedIndex != null) {
      currentIndex = savedIndex;
      update();
    }
  }

  void changePage(int index) {
    pauseVideosFromOutside();
    currentIndex = index;
    AuthHelper.setInt(_storageKey, index); // Save current tab
    playVideosOnReturn(index);
    update();
  }

  void pauseVideosFromOutside() {
    if (Get.isRegistered<ReviewController>()) {
      Get.find<ReviewController>().pauseVideo();
    }
    if (Get.isRegistered<LiveController>()) {
      Get.find<LiveController>().pauseVideo();
    }
    if (Get.isRegistered<CourseController>()) {
      Get.find<CourseController>().pauseAllVideos();
    }
  }

  void playVideosOnReturn(int index) {
    if (index == 1 && Get.isRegistered<ReviewController>()) {
      var reviewController = Get.find<ReviewController>();
      reviewController.playVideo();
      reviewController.shuffleList();
    } else if (index == 2 && Get.isRegistered<LiveController>()) {
      Get.find<LiveController>().playVideo();
    } else if (index == 3 && Get.isRegistered<CourseController>()) {
      var controller = Get.find<CourseController>();
      controller.playVideoAt(controller.currentVideoIndex);
    }
  }

  final pages = [
    HomeScreen(),
    HomeScreen()
  ];
}
