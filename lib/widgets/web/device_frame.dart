import 'package:flutter/material.dart';

class DeviceFrame extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  const DeviceFrame({
    super.key,
    required this.child,
    this.width = 450.0,
    this.height = 900.0,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Phone Device Container
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B), // Dark bezel background
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.25),
                  blurRadius: 50,
                  spreadRadius: 2,
                  offset: const Offset(0, 25),
                ),
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  blurRadius: 35,
                  spreadRadius: -5,
                  offset: const Offset(0, 15),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF334155),
                width: 2.5,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Left Side Volume Buttons
                Positioned(
                  left: -6,
                  top: 110,
                  child: Container(
                    width: 4,
                    height: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Positioned(
                  left: -6,
                  top: 155,
                  child: Container(
                    width: 4,
                    height: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Right Side Power Button
                Positioned(
                  right: -6,
                  top: 130,
                  child: Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Screen Inner Area
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      color: Colors.white,
                      child: Stack(
                        children: [
                          // Flutter App View scaled cleanly to Phone Viewport
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final innerWidth = constraints.maxWidth;
                                final innerHeight = constraints.maxHeight;

                                return MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    size: Size(innerWidth, innerHeight),
                                    padding: const EdgeInsets.only(
                                      top: 36,
                                      bottom: 20,
                                    ),
                                    devicePixelRatio: 3.0,
                                    textScaler: TextScaler.noScaling,
                                  ),
                                  child: SizedBox(
                                    width: innerWidth,
                                    height: innerHeight,
                                    child: child,
                                  ),
                                );
                              },
                            ),
                          ),

                          // Dynamic Island / Camera Notch Top
                          Positioned(
                            top: 8,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Center(
                                child: Container(
                                  width: 105,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(width: 12),
                                      // Camera lens
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1E1E2C),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 4,
                                            height: 4,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF0D47A1),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      // Speaker sensor
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF151522),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Bottom Home Indicator Bar
                          Positioned(
                            bottom: 6,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Center(
                                child: Container(
                                  width: 120,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Curved Callout Annotations on Right Side with smooth Red -> White -> Yellow animation
          const _AnimatedCalloutSection(),
        ],
      ),
    );
  }
}

// Stateful Widget to animate callout color continuously: Red -> White -> Yellow -> Red
class _AnimatedCalloutSection extends StatefulWidget {
  const _AnimatedCalloutSection();

  @override
  State<_AnimatedCalloutSection> createState() => _AnimatedCalloutSectionState();
}

class _AnimatedCalloutSectionState extends State<_AnimatedCalloutSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(
          begin: const Color(0xFF00E676), // Bright Emerald Green
          end: Colors.white, // Pure White
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: Colors.white, // Pure White
          end: const Color(0xFFFFD600), // Vibrant Golden Yellow
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: const Color(0xFFFFD600), // Vibrant Golden Yellow
          end: const Color(0xFF00E676), // Bright Emerald Green
        ),
        weight: 1.0,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
        final currentColor = _colorAnimation.value ?? Colors.white;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upper Callout
            Row(
              children: [
                CustomPaint(
                  size: const Size(32, 32),
                  painter: _CurvedArrowPainter(
                    isTop: true,
                    color: currentColor,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 230,
                  child: Text(
                    "Book your\nrepair service\ndirectly inside\nthe app!",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: currentColor,
                      height: 1.25,
                      shadows: const [
                        Shadow(
                          color: Color(0x44000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // Lower Callout
            Row(
              children: [
                CustomPaint(
                  size: const Size(32, 32),
                  painter: _CurvedArrowPainter(
                    isTop: false,
                    color: currentColor,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 230,
                  child: Text(
                    "Choose, Schedule\n& Track – All in\none place.",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: currentColor,
                      height: 1.25,
                      shadows: const [
                        Shadow(
                          color: Color(0x44000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// Custom Painter for curved animated callout arrows
class _CurvedArrowPainter extends CustomPainter {
  final bool isTop;
  final Color color;

  _CurvedArrowPainter({required this.isTop, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isTop) {
      // Curved arrow pointing left & down
      path.moveTo(size.width, 0);
      path.quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.2,
        0,
        size.height,
      );
      canvas.drawPath(path, paint);

      // Arrow head
      final headPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final headPath = Path()
        ..moveTo(0, size.height)
        ..lineTo(7, size.height - 5)
        ..lineTo(5, size.height - 9)
        ..close();
      canvas.drawPath(headPath, headPaint);
    } else {
      // Curved arrow pointing left & up
      path.moveTo(size.width, size.height);
      path.quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.8,
        0,
        0,
      );
      canvas.drawPath(path, paint);

      // Arrow head
      final headPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final headPath = Path()
        ..moveTo(0, 0)
        ..lineTo(7, 5)
        ..lineTo(5, 9)
        ..close();
      canvas.drawPath(headPath, headPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedArrowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isTop != isTop;
}
