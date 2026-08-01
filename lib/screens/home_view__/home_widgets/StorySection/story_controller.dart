import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:cellphone_doctor/screens/home_view__/home_widgets/StorySection/story_modal.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../ApiService/ApiService.dart';
import '../../../../models/app/getStoryListReponseModel.dart';
import 'StoryService.dart';

class StoryController extends GetxController {
  final RxList<Customer> stories = <Customer>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, Uint8List> thumbnailCache = <String, Uint8List>{}.obs;

  static const String _cacheKey = 'stories_api_cache_v1';

  void updateThumbnail(String url, Uint8List data) {
    thumbnailCache[url] = data;
  }

  @override
  void onInit() {
    super.onInit();
    loadStories();
  }

  Future<void> loadStories() async {
    try {
      isLoading.value = true;

      // 1. Show cached stories immediately so UI feels instant
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null && stories.isEmpty) {
        try {
          final decoded = jsonDecode(cachedData) as Map<String, dynamic>;
          final List<dynamic> cachedList = decoded['customer'] ?? [];
          final parsedCachedList = cachedList.map((item) => Customer.fromJson(item)).toList();
          parsedCachedList.shuffle();
          stories.assignAll(parsedCachedList);
          isLoading.value = false;
        } catch (_) {
          // Ignore stale/corrupt cache
        }
      }

      // 2. Fetch fresh data in background
      final response = await ApiService.getData(
        uri: '/customer/story',
        isAuthorized: true,
        context: Get.context!,
      );

      if (response is Map && response['message'] == "Success") {
        // Save fresh response to cache
        prefs.setString(_cacheKey, jsonEncode(response));

        final List<dynamic> data = response['customer'] ?? [];
        final parsedDataList = data.map((item) => Customer.fromJson(item)).toList();
        parsedDataList.shuffle();
        stories.assignAll(parsedDataList);
        update();
        // Only preload thumbnails lazily, not full videos
        _generateVisibleThumbnails();
      }
    } catch (e) {
      debugPrint('StoryController load error: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> createStory(File videoFile) async {
    try {
      isLoading.value = true;
      final success = await StoryService.uploadStory(videoFile);
      if (success) {
        isLoading.value = false;
        await loadStories();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create story: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Only pre-generate thumbnails for first 5 visible stories,
  /// not download full video files (the old _preloadVideos was too heavy).
  void _generateVisibleThumbnails() {
    // Thumbnails are generated on-demand by each StoryCard widget.
    // We do nothing here to avoid heavy network usage at startup.
  }
}