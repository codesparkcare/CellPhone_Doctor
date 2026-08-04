import 'dart:async';
import 'dart:io';

import 'package:cellphone_doctor/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import 'package:cellphone_doctor/utils/app_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cellphone_doctor/helpers/auth_helper.dart';
import 'package:cellphone_doctor/screens/home_view__/home_widgets/StorySection/story_controller.dart';
import 'package:cellphone_doctor/screens/home_view__/home_widgets/StorySection/story_viewer.dart';

import '../../../../models/app/getStoryListReponseModel.dart';
import '../../../Auth/login_screen.dart';
import 'package:cellphone_doctor/ApiService/ApiService.dart';
import 'StoryService.dart';
import 'dart:typed_data';

class StoriesSection extends StatefulWidget {
  StoriesSection({super.key});

  @override
  State<StoriesSection> createState() => _StoriesSectionState();
}

class _StoriesSectionState extends State<StoriesSection> {
  final storyController = Get.put(StoryController());
  final ScrollController _scrollController = ScrollController();
  bool _expandStories = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 24.w, right: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Stories",
                style: TextStyle(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Obx(() {
          if (storyController.isLoading.value && storyController.stories.isEmpty) {
            // Skeleton shimmer row while loading
            return SizedBox(
              height: 200.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: 5,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (context, index) => Skeletonizer(
                  enabled: true,
                  child: Container(
                    width: 120.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            );
          }

          return SizedBox(
            height: 200.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              cacheExtent: 1000,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: storyController.stories.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _CreateStoryCard();
                } else {
                  final story = storyController.stories[index - 1];
                  return StoryCard(
                    story: story,
                    allStories: storyController.stories,
                    initialIndex: index - 1,
                  );
                }
              },
            ),
          );
        }),
      ],
    );
  }
}

// In story_section.dart, update the _CreateStoryCard class
class _CreateStoryCard extends StatefulWidget {
  _CreateStoryCard({super.key});

  @override
  State<_CreateStoryCard> createState() => _CreateStoryCardState();
}

class _CreateStoryCardState extends State<_CreateStoryCard> {
  final storyController = Get.put(StoryController());

  bool isLogin = false;
  Timer? _timer;
  int _currentImageIndex = 0;
  final List<String> _backgroundImages = [
    "assets/images/story/upload_story.gif",
    "assets/images/story/creat_story.gif",
  ];

  @override
  void initState() {
    super.initState();
    // Delay timer start so GIF switching doesn't fire during critical first-load window
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _showVideoSourceOptions() async {
    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.video_library, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Get.back();
                  await _pickAndUploadVideo(ImageSource.gallery,context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.red),
                title: const Text('Record Video'),
                onTap: () async {
                  Get.back();
                  await _pickAndUploadVideo(ImageSource.camera,context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> requestVideoPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final camera = await Permission.camera.request();
      final mic = await Permission.microphone.request();
      return camera.isGranted && mic.isGranted;
    } else {
      final gallery = await Permission.photos.request(); // iOS
      final storage = await Permission.videos.request(); // Android
      return gallery.isGranted || storage.isGranted;
    }
  }

  Future<bool> requestGalleryPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.videos.request(); // Android 13+
      return status.isGranted;
    } else {
      final status = await Permission.photos.request(); // iOS
      return status.isGranted;
    }
  }

  Future<void> _pickAndUploadVideo(ImageSource source, BuildContext context) async {

    isLogin = await AuthHelper.getBool("isShowOnBoard") ?? false;
    if (isLogin) {
      try {
        // final hasPermission = await requestVideoPermission(source);
        final hasPermission1 =  await requestGalleryPermission();
        print("hasPermission$hasPermission1");

        if (!hasPermission1) {
          Get.snackbar(
            'Permission Required',
            'Please allow permission to continue',
          );
          return;
        }

        final videoFile = source == ImageSource.gallery
            ? await StoryService.pickVideoFromGallery()
            : await StoryService.recordVideo();

        if (videoFile != null) {
          // Get.dialog(
          //   const Center(child: CircularProgressIndicator()),
          //   barrierDismissible: false,
          // );

          await storyController.createStory(videoFile);

          // if (Get.isDialogOpen == true) Get.back();
        }
      } catch (e) {
        // if (Get.isDialogOpen == true) Get.back();
        Get.snackbar('Error', 'Failed to process video');
      }

    } else{
      showLoginDialog(context);
    }

  }

  void showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Please Login"),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: Colors.grey),
              )
            ],
          ),
          content: const Text(
            "You need to login first to continue.",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to Login Screen
                Get.to(() => LoginScreen());
              },
              child: const Text("Login"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showVideoSourceOptions,
      child: Container(
        width: 120.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                _backgroundImages[_currentImageIndex],
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60.h,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 8.h,
              left: 0,
              right: 0,
              child: Text(
                "Create Story",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoryCard extends StatefulWidget {
  final Customer story;
  final List<Customer> allStories;
  final int initialIndex;

  const StoryCard({
    super.key,
    required this.story,
    required this.allStories,
    required this.initialIndex,
  });

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool _isVideo = false;
  late String _fullImageUrl;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _fullImageUrl = widget.story.url ?? "";
    if (_fullImageUrl.isNotEmpty && !_fullImageUrl.startsWith('http')) {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      _fullImageUrl = _fullImageUrl.startsWith('/') 
          ? '$baseUrl$_fullImageUrl' 
          : '$baseUrl/$_fullImageUrl';
    }
    _checkIfVideo();
  }

  @override
  void didUpdateWidget(covariant StoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    String newUrl = widget.story.url ?? "";
    if (newUrl.isNotEmpty && !newUrl.startsWith('http')) {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      newUrl = newUrl.startsWith('/') 
          ? '$baseUrl$newUrl' 
          : '$baseUrl/$newUrl';
    }
    
    if (oldWidget.story.url != widget.story.url) {
      _fullImageUrl = newUrl;
      _videoController?.dispose();
      _videoController = null;
      _checkIfVideo();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _checkIfVideo() {
    final lowerUrl = _fullImageUrl.toLowerCase();
    _isVideo = lowerUrl.contains('.mp4') ||
               lowerUrl.contains('.mov') ||
               lowerUrl.contains('.avi') ||
               lowerUrl.contains('.mkv');

    if (_isVideo) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(_fullImageUrl));
      _videoController!.initialize().then((_) {
        if (mounted) {
          _videoController!.setVolume(0);
          _videoController!.setLooping(true);
          // Do NOT play automatically, just setState so the first frame renders
          setState(() {});
        }
      }).catchError((e) {
        debugPrint("Story preview video init error: $e");
      });
    }
  }

  void _startPreview() {
    if (!_isVideo || _videoController == null) return;
    if (_videoController!.value.isInitialized) {
      _videoController!.play();
    }
  }

  void _stopPreview() {
    if (!_isVideo || _videoController == null) return;
    if (_videoController!.value.isInitialized) {
      _videoController!.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        Get.to(() => StoryViewScreen(
          stories: widget.allStories,
          initialIndex: widget.initialIndex,
        ));
      },
      onLongPress: () {
        if (_isVideo) _startPreview();
      },
      onLongPressUp: () {
        if (_isVideo) _stopPreview();
      },
      onLongPressCancel: () {
        if (_isVideo) _stopPreview();
      },
      child: Container(
        width: 120.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Background Image/Video Thumbnail
            Positioned.fill(
              child: _isVideo
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        (_videoController != null && _videoController!.value.isInitialized)
                            ? FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _videoController!.value.size.width,
                                  height: _videoController!.value.size.height,
                                  child: VideoPlayer(_videoController!),
                                ),
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              ),
                      ],
                    )
                  : buildAppNetworkImage(
                      imageUrl: _fullImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
            ),
            
      
            // Gradient Overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60.h,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
      
            // Gradient Overlay at bottom
            Positioned(
              bottom: 8.h,
              left: 8.w,
              right: 8.w,
              child: Text(
                widget.story.name ?? "No Name",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}