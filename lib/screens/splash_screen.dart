// $file
import 'package:cellphone_doctor/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../helpers/auth_helper.dart';
import '../services/splash/splash_services.dart';




class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final SplashServices _splashServices = SplashServices();

  @override
  void initState() {
    super.initState();
    getLoginStatus();
  }

  getLoginStatus() async {
    var isOnBoard = await AuthHelper.getBool("isShowOnBoard")??false;
    setState(() {});
    if (mounted) {
      _splashServices.isLogin(context, isOnBoard ?? false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/Icon/Icon.png",
          width: 250.w,
          height: 250.w,
          fit: BoxFit.contain,
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
