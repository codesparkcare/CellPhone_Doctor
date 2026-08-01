
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeController extends GetxController {
  // carousel part sujin
  HomeController({List<String> initialImages = const []}) {
    images = List<String>.from(initialImages);
  }

  final PageController pageController = PageController(viewportFraction: 1.0);
  int currentPage = 0;
  bool autoscroll = true;
  Timer? autoTimer;

  List<String> images = [];





  @override
  void onInit() {
    super.onInit();
    startAutoScroll();
    // if (images.isNotEmpty) {
    //   precacheCarouselImages();
    // }
  }

  /// Called when page changes
  void onPageChanged(int index) {
    currentPage = index;
    update(['indicator']);
  }

  /// Toggle auto-scroll manually
  void toggleAutoScroll(bool value) {
    autoscroll = value;
    if (value) {
      startAutoScroll();
    } else {
      autoTimer?.cancel();
    }
    update();
  }

  void startAutoScroll() {
    autoTimer?.cancel();
    autoTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!autoscroll || !pageController.hasClients || images.isEmpty || images.length == 1) return;

      int nextPage = (currentPage + 1) % images.length;
      pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  /// Pre-cache images: first 3 immediately, then the rest.
  void precacheCarouselImages() {
    if (images.isEmpty || Get.context == null) return;

    // 1. Pre-cache first 3 images immediately
    for (int i = 0; i < images.length && i < 3; i++) {
      precacheImage(CachedNetworkImageProvider(images[i]), Get.context!);
    }

    // 2. Pre-cache remaining images after a short delay
    if (images.length > 3) {
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.context == null) return;
        for (int i = 3; i < images.length; i++) {
          precacheImage(CachedNetworkImageProvider(images[i]), Get.context!);
        }
      });
    }
  }
  void setImages(List<String> newImages) {
    if (listEquals(images, newImages)) return;
    images = List<String>.from(newImages);
    update(['carousel', 'indicator']);
    startAutoScroll();
    // if (images.isNotEmpty) {
    //   precacheCarouselImages();
    // }
  }

  int selectedTab = 0; 
  bool showAllSpares = false; 

  final List<Map<String, String>> mobileServices = [
    {"title": "Broken Display", "image": "assets/images/Group 3.png"},
    {"title": "Audio Issue", "image": "assets/images/Group 3.png"},
    {"title": "Charging Issue", "image": "assets/images/Group 3.png"},
    {"title": "Network Issue", "image": "assets/images/Group 3.png"},
    {"title": "Dead Phone", "image": "assets/images/Group 3.png"},
    {"title": "Water Damage", "image": "assets/images/Group 3.png"},
  ];

  final List<Map<String, String>> laptopServices = [
    {"title": "Battery Issue", "image": "assets/images/Group 3.png"},
    {"title": "Keyboard Issue", "image": "assets/images/Group 3.png"},
    {"title": "Display Issue", "image": "assets/images/Group 3.png"},
    {"title": "Motherboard", "image": "assets/images/Group 3.png"},
    {"title": "HDD Failure", "image": "assets/images/Group 3.png"},
    {"title": "Wi-Fi Issue", "image": "assets/images/Group 3.png"},
  ];

  void switchTab(int index) {
    selectedTab = index;
    showAllSpares = false; // reset on tab change
    update();
  }

  List<Map<String, String>> get currentServices =>
      selectedTab == 0 ? mobileServices : laptopServices;

  void toggleShowAllSpares() {
    showAllSpares = !showAllSpares;
    update();
  }


  //top brands

  int selectedBrandTab = 0;
  bool showAllBrands = false;


  final List<Map<String, String>> mobileBrands = [
    {"title": "Apple", "image": "assets/images/Brand/brand10.png"},
    {"title": "Mi", "image": "assets/images/Brand/brand13.png"},
    {"title": "Samsung", "image": "assets/images/Brand/brand1.png"},
    {"title": "Vivo", "image": "assets/images/Brand/brand14.png"},
    {"title": "OnePlus", "image": "assets/images/Brand/brand2.png"},
    {"title": "Oppo", "image": "assets/images/Brand/brand3.png"},
    {"title": "Honor", "image": "assets/images/Brand/brand5.png"},
    {"title": "Tcl", "image": "assets/images/Brand/brand12.png"},
  ];
//brand 3 sony
//brand 5 honor
  // 6 nothing
  //8 coolpad
  //9 asus
  //12 tcl
  final List<Map<String, String>> laptopBrands = [
    {"title": "Asus", "image": "assets/images/Brand/brand9.png"},
    {"title": "CoolPad", "image": "assets/images/Brand/brand8.png"},
    {"title": "Samsung", "image": "assets/images/Brand/brand1.png"},
    {"title": "Vivo", "image": "assets/images/Brand/brand14.png"},
    {"title": "OnePlus", "image": "assets/images/Brand/brand2.png"},
    {"title": "Oppo", "image": "assets/images/Brand/brand3.png"},
    {"title": "Honor", "image": "assets/images/Brand/brand5.png"},
    {"title": "Tcl", "image": "assets/images/Brand/brand12.png"},
  ];

  void switchBrandTab(int index) {
    selectedBrandTab = index;
    showAllBrands = false; // reset on brand tab change
    update();
  }

  List<Map<String, String>> get currentBrands =>
      selectedBrandTab == 0 ? mobileBrands : laptopBrands;

  void toggleShowAllBrands() {
    showAllBrands = !showAllBrands;
    update();
  }


  ///FAq Section Sujin--------------------------------------------------------------------
  final faqs = [
    {
      'question': 'What type of Mobile Phone repair does The Cell Phone Doctor Offer?',
      'answer': 'We offer repairs for all major brands including screen replacement, battery, camera, and software issues.'
    },
    {
      'question': 'Does TCP use genuine parts for repair?',
      'answer': 'Yes, we only use high-quality genuine and OEM parts for all repairs.'
    },
    {
      'question': 'Can I get my mobile phone repaired online?',
      'answer': 'Yes, you can schedule a repair online, and our technician will handle the pickup and delivery.'
    },
  ];


  int? expandedIndex;

  void toggleExpand(int index) {
    if (expandedIndex == index) {
      expandedIndex = null;
    } else {
      expandedIndex = index;
    }
    update();
  }

  int visibleFaqsCount = 3;

  void loadMoreFaqs() {
    visibleFaqsCount += 3;
    update();
  }

  void seeLessFaqs() {
    visibleFaqsCount = 3;
    update();
  }


  @override
  void onClose() {
    autoTimer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
