import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../controller/navBar_controller.dart';



class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NavController>();
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GetBuilder<NavController>(
      builder: (_) {
        return SafeArea(
          top: false,
          bottom: true,
          child: Container(
            height: 80 + bottomPadding.clamp(0, 34), // Adjust for system navigation
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Background curved shape
                CustomPaint(
                  size: Size(size.width, 80 + bottomPadding.clamp(0, 34)),
                  painter: CurvedNavPainter(bottomPadding: bottomPadding.clamp(0, 34)),
                ),

                // Icons
                Positioned(
                  bottom: 10 + bottomPadding.clamp(0, 20),
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(Icons.handyman_outlined, "Home", 0, controller),
                      _buildNavItem(Icons.reviews_outlined, "Reviews", 1, controller),

                      // Placeholder for center button
                      const SizedBox(width: 60),

                      _buildNavItem(Icons.menu_book_outlined, "Courses", 3, controller),
                      _buildNavItem(Icons.grid_view_outlined, "Profile", 4, controller),
                    ],
                  ),
                ),

                // Center Curved Floating Button
                Positioned(
                  bottom: 25 + bottomPadding.clamp(0, 20),
                  child: GestureDetector(
                    onTap: () => controller.changePage( 2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.videocam_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, NavController controller) {
    final isActive = controller.currentIndex == index;
    return GestureDetector(
      onTap: () => controller.changePage(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.blue : Colors.black54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.blue : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}


class CurvedNavPainter extends CustomPainter {
  final double bottomPadding;
  
  CurvedNavPainter({required this.bottomPadding});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final path = Path();
    path.moveTo(0, bottomPadding);
    path.lineTo(size.width * 0.35, bottomPadding);
    path.quadraticBezierTo(
      size.width * 0.5, bottomPadding - 30, // <-- curve depth
      size.width * 0.65, bottomPadding,
    );
    path.lineTo(size.width, bottomPadding);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black26, 6, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
