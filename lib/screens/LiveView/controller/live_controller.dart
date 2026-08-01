import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cellphone_doctor/ApiService/ApiService.dart';
import 'package:cellphone_doctor/models/app/live_banner_model.dart';
import 'package:video_player/video_player.dart';
import 'package:cellphone_doctor/controller/navBar_controller.dart';

class LiveController extends GetxController {
  bool isLoading = false;
  List<LiveBannerData> liveBanners = [];
  List<dynamic> liveVideos = [];
  bool isPlaying = false;
  VideoPlayerController? videoController;
  int? currentPlayingIndex;
  bool isLoadingVideos = false;

  String currentTime = "";
  String currentDate = "";
  Timer? _timer;

  ScrollController bannerScrollController = ScrollController();
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
    _startBannerAutoScroll();
    getLiveBanners();
    fetchLiveVideos();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      currentTime = DateFormat('hh:mm:ss a').format(now);
      currentDate = DateFormat('dd-MM-yyyy').format(now);
      update();
    });
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (bannerScrollController.hasClients && liveBanners.isNotEmpty) {
        _currentBannerIndex++;
        if (_currentBannerIndex >= liveBanners.length) {
          _currentBannerIndex = 0;
          bannerScrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
          );
        } else {
          // The item width is 85% of screen width plus 12 logical pixels for margin
          double itemWidth = Get.width * 0.85 + 12;
          bannerScrollController.animateTo(
            _currentBannerIndex * itemWidth,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    _bannerTimer?.cancel();
    bannerScrollController.dispose();
    if (videoController != null) {
      videoController!.dispose();
    }
    super.onClose();
  }


  Future<void> getLiveBanners() async {
    isLoading = true;
    update();
    try {
      var response = await ApiService.getRequest("livebanner");
      if (response != null && response['status'] == true) {
        LiveBannerModel bannerModel = LiveBannerModel.fromJson(response);
        if (bannerModel.data != null) {
          liveBanners = bannerModel.data!;
        }
      }
    } catch (e) {
      debugPrint("Error fetching live banners: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> fetchLiveVideos() async {
    isLoadingVideos = true;
    update();
    try {
      var response = await ApiService.getRequest("video");
      if (response != null && response['status'] == true && response['data'] != null) {
        List data = response['data'];
        liveVideos = data.where((v) => v['type'] == "Live Video").toList();
        if (liveVideos.isNotEmpty) {
          initializeVideo(liveVideos[0]['url'], 0);
        }
      }
    } catch (e) {
      debugPrint("Error fetching live videos: $e");
    } finally {
      isLoadingVideos = false;
      update();
    }
  }

  void initializeVideo(String url, int index) {
    if (currentPlayingIndex == index && videoController != null) {
      togglePlay();
      return;
    }

    // Dispose previous controller if any
    if (videoController != null) {
      videoController!.dispose();
      videoController = null;
      isPlaying = false;
      currentPlayingIndex = null;
    }

    try {
      videoController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          currentPlayingIndex = index;
          // Only play if on the Live tab (index 2)
          if (Get.find<NavController>().currentIndex == 2) {
            videoController!.play();
            isPlaying = true;
          }
          update();
        });
    } catch (e) {
      debugPrint("Error initializing video: $e");
    }
  }

  void togglePlay() {
    if (videoController != null && videoController!.value.isInitialized) {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
        isPlaying = false;
      } else {
        videoController!.play();
        isPlaying = true;
      }
      update();
    }
  }

  void pauseVideo() {
    if (videoController != null && videoController!.value.isPlaying) {
      videoController!.pause();
      isPlaying = false;
      update();
    }
  }

  void playVideo() {
    if (videoController != null && videoController!.value.isInitialized) {
      videoController!.play();
      isPlaying = true;
      update();
    }
  }

}
