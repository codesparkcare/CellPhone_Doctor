import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cellphone_doctor/screens/home_view__/home_widgets/StorySection/story_controller.dart';
import 'package:cellphone_doctor/models/app/getStoryListReponseModel.dart';
import 'package:cellphone_doctor/ApiService/ApiService.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class StoryViewScreen extends StatefulWidget {
  final List<Customer> stories;
  final int initialIndex;

  const StoryViewScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStoryComplete() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.stories.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return StoryItemView(
            key: ValueKey(widget.stories[index].id ?? index),
            story: widget.stories[index],
            onComplete: _onStoryComplete,
            isActive: _currentIndex == index,
            itemIndex: index,
            currentIndex: _currentIndex,
          );
        },
      ),
    );
  }
}

class StoryItemView extends StatefulWidget {
  final Customer story;
  final VoidCallback onComplete;
  final bool isActive;
  final int itemIndex;
  final int currentIndex;

  const StoryItemView({
    super.key,
    required this.story,
    required this.onComplete,
    required this.isActive,
    required this.itemIndex,
    required this.currentIndex,
  });

  @override
  State<StoryItemView> createState() => _StoryItemViewState();
}

class _StoryItemViewState extends State<StoryItemView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late AnimationController _progressController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideo = false;
  bool _isStarted = false;
  bool _isInitialized = false;
  late String _fullUrl;

  @override
  void initState() {
    super.initState();
    final url = widget.story.url ?? "";
    _fullUrl = url;
    if (_fullUrl.isNotEmpty && !_fullUrl.startsWith('http')) {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      _fullUrl = _fullUrl.startsWith('/') 
          ? '$baseUrl$_fullUrl' 
          : '$baseUrl/$_fullUrl';
    }
    _isVideo = _fullUrl.toLowerCase().endsWith('.mp4') ||
               _fullUrl.toLowerCase().endsWith('.mov') ||
               _fullUrl.toLowerCase().endsWith('.avi');


    _progressController = AnimationController(
        vsync: this, duration: const Duration(seconds: 5));
    
    // Aggressive Preload: Boosted to 4 stories for near-instant playback
    if ((widget.itemIndex - widget.currentIndex).abs() <= 4) {
      _initializeMedia();
    }

    if (widget.isActive) {
      _startStory();
    }
  }

  @override
  void didUpdateWidget(StoryItemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if we should preload now (Increased distance for faster swipes)
    final distance = (widget.itemIndex - widget.currentIndex).abs();
    if (!_isInitialized && distance <= 4) {
      _initializeMedia();
    }
    
    // Memory Management: Dispose distant controllers to prevent memory pressure
    if (_isInitialized && distance > 5 && !widget.isActive) {
      _disposeMedia();
    }

    if (widget.isActive && !_isStarted) {
      _startStory();
    } else if (!widget.isActive && _isStarted) {
      _stopStory();
    }
  }

  void _initializeMedia() {
    if (_isInitialized) return;
    if (_isVideo) {
      _initializeVideo();
    } else {
      _isInitialized = true;
    }
  }


  void _startStory() {
    _isStarted = true;
    if (_isVideo) {
      _playVideo();
    } else {
      _startImageStory();
    }
  }

  void _stopStory() {
    _isStarted = false;
    _progressController.stop();
    _progressController.reset();
    _videoController?.pause();
    _videoController?.seekTo(Duration.zero);
  }

  Future<void> _initializeVideo() async {
    if (_videoController != null) return;
    
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(_fullUrl));

      // Aggressive buffering: enable fast start options
      await _videoController!.initialize();
      _isInitialized = true;
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        showControls: false,
        autoInitialize: true, // Native optimization
      );
      
      if (mounted) {
        setState(() {});
        if (widget.isActive) {
          // Video initialized, sync the progress bar duration
          if (_videoController!.value.duration.inSeconds > 0) {
            final elapsed = _progressController.value * _progressController.duration!.inMilliseconds;
            _progressController.duration = _videoController!.value.duration;
            _progressController.forward(from: elapsed / _progressController.duration!.inMilliseconds);
          }
          _playVideo();
        }
      }
    } catch (e) {
      debugPrint("Video init error: $e");
      if (widget.isActive) widget.onComplete();
    }
  }

  void _disposeMedia() {
    _isInitialized = false;
    _isStarted = false;
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _chewieController?.dispose();
    _videoController = null;
    _chewieController = null;
    if (mounted) setState(() {});
  }

  void _playVideo() {
    // Start progress bar immediately with a default duration (15s) if video metadata not yet ready
    // This provides instant feedback to the user
    if (!_progressController.isAnimating) {
      _progressController.duration = (_videoController != null && _videoController!.value.isInitialized)
          ? _videoController!.value.duration
          : const Duration(seconds: 15);
      _progressController.forward(from: 0);
    }

    if (_videoController != null && _videoController!.value.isInitialized) {
      _videoController!.play();
      _videoController!.removeListener(_videoListener);
      _videoController!.addListener(_videoListener);
      setState(() {});
    } else if (!_isInitialized) {
      _initializeVideo();
    }
  }

  void _videoListener() {
    if (_videoController != null && 
        _videoController!.value.position >= _videoController!.value.duration) {
      _videoController!.removeListener(_videoListener);
      if (widget.isActive) widget.onComplete();
    }
  }

  void _startImageStory() {
    if (mounted && widget.isActive) {
      _progressController.forward(from: 0).whenComplete(() {
        if (mounted && widget.isActive) {
          widget.onComplete();
        }
      });
      setState(() {});
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Stack(
      children: [
        // Content
        Positioned.fill(
          child: _isVideo
              ? (_videoController != null && _videoController!.value.isInitialized
                  ? (_chewieController != null 
                      ? Chewie(key: const ValueKey('video'), controller: _chewieController!) 
                      : const SizedBox())
                  : const Center(child: CircularProgressIndicator()))
              : CachedNetworkImage(
                  key: const ValueKey('image'),
                  imageUrl: _fullUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
        ),

        // Top Controls
        Positioned(
          top: 40.h,
          left: 10.w,
          right: 10.w,
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressController.value,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 3.h,
                  );
                },
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close, color: Colors.white, size: 22.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
