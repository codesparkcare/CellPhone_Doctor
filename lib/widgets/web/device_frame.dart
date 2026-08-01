import 'package:flutter/material.dart';

class DeviceFrame extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  const DeviceFrame({
    super.key,
    required this.child,
    this.width = 414.0,
    this.height = 840.0,
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

          // Curved Callout Annotations on Right Side
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upper Callout
              Row(
                children: [
                  CustomPaint(
                    size: const Size(24, 24),
                    painter: _CurvedArrowPainter(isTop: true),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 160,
                    child: Text(
                      "Book your\nrepair service\ndirectly inside\nthe app!",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 70),

              // Lower Callout
              Row(
                children: [
                  CustomPaint(
                    size: const Size(24, 24),
                    painter: _CurvedArrowPainter(isTop: false),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 160,
                    child: Text(
                      "Choose, Schedule\n& Track – All in\none place.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Painter for curved blue callout arrows
class _CurvedArrowPainter extends CustomPainter {
  final bool isTop;
  _CurvedArrowPainter({required this.isTop});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1D4ED8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
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
        ..color = const Color(0xFF1D4ED8)
        ..style = PaintingStyle.fill;

      final headPath = Path()
        ..moveTo(0, size.height)
        ..lineTo(6, size.height - 4)
        ..lineTo(4, size.height - 8)
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
        ..color = const Color(0xFF1D4ED8)
        ..style = PaintingStyle.fill;

      final headPath = Path()
        ..moveTo(0, 0)
        ..lineTo(6, 4)
        ..lineTo(4, 8)
        ..close();
      canvas.drawPath(headPath, headPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
