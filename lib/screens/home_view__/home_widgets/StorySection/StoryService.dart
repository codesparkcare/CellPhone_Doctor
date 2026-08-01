// lib/services/story_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../../ApiService/ApiService.dart';
import '../../../../helpers/auth_helper.dart';


class StoryService {
  static final ImagePicker _picker = ImagePicker();

  // Pick video from gallery
  static Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );
      if (video != null) {
        return File(video.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick video: $e');
    }
    return null;
  }

  // Record video using camera
  static Future<File?> recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );
      if (video != null) {
        return File(video.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to record video: $e');
    }
    return null;
  }

  // Upload video to server
  static Future<bool> uploadStory(File videoFile) async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/customer/story');

      var request = http.MultipartRequest('POST', url);

      // Add authorization header
      final token = await AuthHelper.getString("token");
      request.headers['Authorization'] = 'Bearer $token';

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'video',
        videoFile.path,
      ));

      // Send request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Story uploaded successfully!');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to upload story: ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload story: $e');
      return false;
    }
  }
}