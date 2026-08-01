import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navHeight = 70.h + bottomPadding;

    return Container(
      height: navHeight,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size(width, navHeight), painter: BottomNavPainter()),
          Positioned(
            bottom: bottomPadding,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Center(
                      child: buildItem(
                        0,
                        'Home',
                        'assets/images/bottom/guidance_tools.png',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: buildItem(
                        1,
                        'Reviews',
                        'assets/images/bottom/material-symbols-light_reviews-outline-rounded.png',
                      ),
                    ),
                  ),
                  const SizedBox(width: 70), // Center cutout for FAB
                  Expanded(
                    child: Center(
                      child: buildItem(
                        3,
                        'Courses',
                        'assets/images/bottom/ion_book-outline.png',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: buildItem(
                        4,
                        'Profile',
                        'assets/images/bottom/hugeicons_menu-square.png',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: -25,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: BlinkingCameraIcon(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(int index, String label, String? icon) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            icon ?? '',
            height: 25.h,
            color: isSelected ? const Color(0xFF1E88E5) : Colors.black87,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? const Color(0xFF1E88E5) : Colors.black87,
            ),
          ),
        ],
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

    final path = Path();
    final centerX = size.width / 2;
    const radius = 28.0; // smaller curve radius fits 65px circle

    path.moveTo(0, 0);
    path.lineTo(centerX - radius * 2 - 10, 0);

    // left curve (smooth entry)
    path.quadraticBezierTo(centerX - radius - 12, 0, centerX - radius - 6, 18);

    // main concave curve
    path.arcToPoint(
      Offset(centerX + radius + 6, 18),
      radius: const Radius.circular(radius + 8),
      clockwise: false,
    );

    // right curve (smooth exit)
    path.quadraticBezierTo(
      centerX + radius + 12,
      0,
      centerX + radius * 2 + 10,
      0,
    );

    // close shape
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.15), 6, true);
    // fill
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BlinkingCameraIcon extends StatefulWidget {
  const BlinkingCameraIcon({Key? key}) : super(key: key);

  @override
  _BlinkingCameraIconState createState() => _BlinkingCameraIconState();
}

class _BlinkingCameraIconState extends State<BlinkingCameraIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _colorAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(begin: Colors.white, end: Colors.red),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(begin: Colors.red, end: Colors.yellow),
        ),
      ],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              "assets/images/bottom/Group.png",
              scale: 4,
              color: Colors.white,
            ),
            Transform.translate(
              offset: const Offset(-3.5, 0),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
