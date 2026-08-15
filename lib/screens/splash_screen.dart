import 'dart:async';
import 'dart:convert';
import 'package:cellphone_doctor/ApiService/ApiService.dart';
import 'package:cellphone_doctor/models/app/getHomeListModel.dart';
import 'package:cellphone_doctor/screens/Auth/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cellphone_doctor/screens/home_view__/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../helpers/auth_helper.dart';
import '../services/splash/splash_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashServices _splashServices = SplashServices();
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  Widget? _targetScreen;
  bool _hasNavigated = false;
  bool _shouldNavigateWhenTargetReady = false;
  Timer? _fallbackTimer;

  bool _isMuted = kIsWeb;

  @override
  void initState() {
    super.initState();
    _prefetchHomeData();
    _initVideoAndAuth();
  }

  Future<void> _prefetchHomeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await ApiService.getData(
        uri: "/home",
        isAuthorized: true,
        context: null,
      );
      if (result != null && result != "failed" && result is Map<String, dynamic>) {
        await prefs.setString('home_api_cache_v1', jsonEncode(result));
        debugPrint("✅ Background Prefetch: /home data cached successfully");

        if (mounted) {
          final model = GetHomeListModel.fromJson(result);
          setGlobalHomeMemoryCache(model);
          final imagesToPrecache = <String>[];

          for (var b in (model.banner ?? []).take(3)) {
            if (b.image != null && b.image!.startsWith('http')) imagesToPrecache.add(b.image!);
          }
          for (var c in (model.categories ?? []).take(8)) {
            if (c.imageUrl != null && c.imageUrl!.startsWith('http')) imagesToPrecache.add(c.imageUrl!);
          }
          for (var s in (model.spare ?? []).take(10)) {
            final url = s.logoUrl ?? s.imageUrl;
            if (url != null && url.startsWith('http')) imagesToPrecache.add(url);
          }

          for (final url in imagesToPrecache) {
            try {
              precacheImage(CachedNetworkImageProvider(url), context);
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      debugPrint("Splash /home prefetch error: $e");
    }
  }

  Future<void> _initVideoAndAuth() async {
    // 1. Initialize Video Player (Web & Mobile Native)
    _controller = VideoPlayerController.asset("assets/Splash_Video/cellphone.mp4");

    _controller.initialize().then((_) async {
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        if (kIsWeb) {
          // Web browsers require muted volume (0.0) for video autoplay
          await _controller.setVolume(0.0);
          _isMuted = true;
        } else {
          await _controller.setVolume(1.0);
          _isMuted = false;
        }
        try {
          await _controller.play();
        } catch (e) {
          debugPrint("Splash Video play error: $e, retrying muted");
          await _controller.setVolume(0.0);
          _isMuted = true;
          await _controller.play();
        }
        // Listen for video completion
        _controller.addListener(_videoListener);
      }
    }).catchError((e) {
      debugPrint("Splash Video initialization error: $e");
      _shouldNavigateWhenTargetReady = true;
      if (_targetScreen != null) {
        _navigateToNextScreen();
      }
    });

    // 2. Fallback timer in case video hangs
    _fallbackTimer = Timer(const Duration(seconds: 15), () {
      _shouldNavigateWhenTargetReady = true;
      _navigateToNextScreen();
    });

    // 3. Perform background auth/profile check simultaneously while video is playing
    try {
      var isOnBoard = await AuthHelper.getBool("isShowOnBoard") ?? false;
      if (mounted) {
        Widget target = await _splashServices.getTargetScreen(context, isOnBoard);
        _targetScreen = target;
        if (_shouldNavigateWhenTargetReady) {
          _navigateToNextScreen();
        }
      }
    } catch (e) {
      debugPrint("Splash target fetch error: $e");
      _targetScreen = const LoginScreen();
      if (_shouldNavigateWhenTargetReady) {
        _navigateToNextScreen();
      }
    }
  }

  void _toggleMute() async {
    if (!_controller.value.isInitialized) return;
    if (_isMuted || _controller.value.volume == 0) {
      await _controller.setVolume(1.0);
      if (mounted) {
        setState(() {
          _isMuted = false;
        });
      }
    } else {
      await _controller.setVolume(0.0);
      if (mounted) {
        setState(() {
          _isMuted = true;
        });
      }
    }
  }

  void _videoListener() {
    if (!_controller.value.isInitialized) return;

    final duration = _controller.value.duration;
    final position = _controller.value.position;

    // Only trigger completion when video has actually played to completion
    if (duration > Duration.zero && position > const Duration(milliseconds: 500)) {
      if (position >= duration - const Duration(milliseconds: 250)) {
        _shouldNavigateWhenTargetReady = true;
        _navigateToNextScreen();
      }
    }
  }

  void _navigateToNextScreen() {
    if (_hasNavigated) return;

    if (_targetScreen != null && _shouldNavigateWhenTargetReady) {
      _hasNavigated = true;
      _fallbackTimer?.cancel();
      try {
        _controller.removeListener(_videoListener);
        _controller.pause();
      } catch (_) {}
      Get.off(() => _targetScreen!);
    } else {
      _shouldNavigateWhenTargetReady = true;
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    try {
      _controller.removeListener(_videoListener);
      _controller.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isMuted) {
          _toggleMute();
        } else {
          _navigateToNextScreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Video Player
            Positioned.fill(
              child: _isVideoInitialized
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio > 0
                            ? _controller.value.aspectRatio
                            : (9 / 16),
                        child: VideoPlayer(_controller),
                      ),
                    )
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),

            // Mute / Unmute Floating Sound Button Badge
            if (_isVideoInitialized)
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleMute,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isMuted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isMuted ? "Click for Sound" : "Sound On",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}



/*
class HomeScreen1 extends StatefulWidget {
  const HomeScreen1({Key? key}) : super(key: key);

  @override
  State<HomeScreen1> createState() => _HomeScreen1State();
}

class _HomeScreen1State extends State<HomeScreen1> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Text(
          'Selected Index: $_selectedIndex',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 70),
            painter: BottomNavPainter(),
          ),
          SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_repair_service_outlined,
                  label: 'Services',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.star_border,
                  label: 'Reviews',
                  index: 1,
                ),
                const SizedBox(width: 60), // Space for center button
                _buildNavItem(
                  icon: Icons.menu_book_outlined,
                  label: 'Courses',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  index: 4,
                ),
              ],
            ),
          ),
          // Center elevated button
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 30,
            top: 5,
            child: GestureDetector(
              onTap: () => onItemTapped(2),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          // "Live" text below center button
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 15,
            bottom: 8,
            child: Text(
              'Live',
              style: TextStyle(
                fontSize: 12,
                color: selectedIndex == 2
                    ? const Color(0xFF2196F3)
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey[600],
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF2196F3) : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();

    // Start from left
    path.moveTo(0, 20);

    // Left curve going up to the notch
    path.lineTo(size.width / 2 - 50, 20);

    // Create the circular notch for the center button
    path.quadraticBezierTo(
      size.width / 2 - 45, 20,
      size.width / 2 - 40, 15,
    );

    path.quadraticBezierTo(
      size.width / 2 - 30, 5,
      size.width / 2, 5,
    );

    path.quadraticBezierTo(
      size.width / 2 + 30, 5,
      size.width / 2 + 40, 15,
    );

    path.quadraticBezierTo(
      size.width / 2 + 45, 20,
      size.width / 2 + 50, 20,
    );

    // Right side
    path.lineTo(size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow
    canvas.drawPath(path, shadowPaint);

    // Draw the navigation bar
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}*/
