import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrandTrustBanner extends StatelessWidget {
  const BrandTrustBanner({super.key});

  static const Color goldColor = Color(0xFFF3C042);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: const Color(0xFF090909), // Sleek black background
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// 🔹 1. Warranty Section
            Expanded(
              child: _buildBannerItem(
                graphic: const _ShieldGraphic(),
                text: "Upto 1 Year\nWarranty",
              ),
            ),
            _buildDivider(),

            /// 🔹 2. Service Centers Section
            Expanded(
              child: _buildBannerItem(
                graphic: const _StoreGraphic(),
                text: "15+ Service\nCenters",
              ),
            ),
            _buildDivider(),

            /// 🔹 3. Google Rating Section
            Expanded(
              child: _buildBannerItem(
                graphic: const _GoogleRatingGraphic(),
                text: "4.9 ★ Google\nCustomer Rating",
              ),
            ),
            _buildDivider(),

            /// 🔹 4. Doorstep Service Section
            Expanded(
              child: _buildBannerItem(
                graphic: const _DoorstepTruckGraphic(),
                text: "Doorstep Service\nAvailable",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1.w,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      color: Colors.white24,
    );
  }

  Widget _buildBannerItem({
    required Widget graphic,
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 52.h,
            child: Center(child: graphic),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "✓ ",
                style: TextStyle(
                  color: goldColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 1. SHIELD GRAPHIC (Gold Shield with White Checkmark)
/// ---------------------------------------------------------------------------
class _ShieldGraphic extends StatelessWidget {
  const _ShieldGraphic();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(44.w, 48.h),
      painter: _ShieldPainter(),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Outer Shield Path
    final Path path = Path()
      ..moveTo(w * 0.5, 0)
      ..cubicTo(w * 0.85, 0, w, h * 0.1, w, h * 0.25)
      ..cubicTo(w, h * 0.65, w * 0.5, h * 0.95, w * 0.5, h)
      ..cubicTo(w * 0.5, h * 0.95, 0, h * 0.65, 0, h * 0.25)
      ..cubicTo(0, h * 0.1, w * 0.15, 0, w * 0.5, 0)
      ..close();

    // Gold Outer Fill & Border
    final Paint goldPaint = Paint()
      ..color = const Color(0xFFF3C042)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, goldPaint);

    // Inner Dark Shield
    final Path innerPath = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..cubicTo(w * 0.8, h * 0.08, w * 0.9, h * 0.18, w * 0.9, h * 0.3)
      ..cubicTo(w * 0.9, h * 0.62, w * 0.5, h * 0.88, w * 0.5, h * 0.92)
      ..cubicTo(w * 0.5, h * 0.88, w * 0.1, h * 0.62, w * 0.1, h * 0.3)
      ..cubicTo(w * 0.1, h * 0.18, w * 0.2, h * 0.08, w * 0.5, h * 0.08)
      ..close();

    final Paint darkPaint = Paint()
      ..color = const Color(0xFF0F0F0F)
      ..style = PaintingStyle.fill;
    canvas.drawPath(innerPath, darkPaint);

    // White Checkmark
    final Path checkPath = Path()
      ..moveTo(w * 0.32, h * 0.46)
      ..lineTo(w * 0.46, h * 0.62)
      ..lineTo(w * 0.72, h * 0.32);

    final Paint checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ---------------------------------------------------------------------------
/// 2. STORE GRAPHIC (Storefront Building with Location Pin)
/// ---------------------------------------------------------------------------
class _StoreGraphic extends StatelessWidget {
  const _StoreGraphic();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(52.w, 50.h),
      painter: _StorePainter(),
    );
  }
}

class _StorePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Color gold = const Color(0xFFF3C042);

    final Paint fillGold = Paint()..color = gold;
    final Paint strokeGold = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Building Base Structure
    final double buildingTop = h * 0.48;
    final double buildingLeft = w * 0.08;
    final double buildingRight = w * 0.92;

    // Building Wall Fill
    final RRect buildingRect = RRect.fromLTRBR(
      buildingLeft, buildingTop, buildingRight, h * 0.98, Radius.circular(3.r),
    );
    canvas.drawRRect(buildingRect, fillGold);

    // Roof Signboard Box
    final RRect signRect = RRect.fromLTRBR(
      w * 0.22, h * 0.38, w * 0.78, h * 0.52, Radius.circular(2.r),
    );
    canvas.drawRRect(signRect, strokeGold);
    final Paint fillDark = Paint()..color = const Color(0xFF141414);
    canvas.drawRRect(signRect, fillDark);
    canvas.drawRRect(signRect, strokeGold);

    // Windows / Doors grid inside Building
    final Paint windowPaint = Paint()..color = const Color(0xFF141414);
    // Left Window
    canvas.drawRRect(
      RRect.fromLTRBR(w * 0.16, h * 0.58, w * 0.34, h * 0.88, Radius.circular(2.r)),
      windowPaint,
    );
    // Door
    canvas.drawRRect(
      RRect.fromLTRBR(w * 0.42, h * 0.58, w * 0.58, h * 0.98, Radius.circular(1.r)),
      windowPaint,
    );
    // Right Window
    canvas.drawRRect(
      RRect.fromLTRBR(w * 0.66, h * 0.58, w * 0.84, h * 0.88, Radius.circular(2.r)),
      windowPaint,
    );

    // Location Pin on top
    final double pinX = w * 0.5;
    final double pinY = h * 0.22;
    final double pinR = h * 0.18;

    final Path pinPath = Path()
      ..moveTo(pinX, h * 0.42)
      ..cubicTo(pinX - pinR * 1.1, pinY + pinR * 0.4, pinX - pinR, pinY, pinX - pinR, pinY)
      ..addArc(Rect.fromCircle(center: Offset(pinX, pinY), radius: pinR), 3.14, 3.14)
      ..cubicTo(pinX + pinR, pinY, pinX + pinR * 1.1, pinY + pinR * 0.4, pinX, h * 0.42)
      ..close();

    canvas.drawPath(pinPath, fillGold);

    // Inner Hole of Location Pin
    canvas.drawCircle(Offset(pinX, pinY), pinR * 0.45, fillDark);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ---------------------------------------------------------------------------
/// 3. GOOGLE RATING GRAPHIC (Official Google G Logo + 4.9 ★)
/// ---------------------------------------------------------------------------
const String _googleSvg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.28-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24s.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
</svg>''';

class _GoogleRatingGraphic extends StatelessWidget {
  const _GoogleRatingGraphic();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.string(
          _googleSvg,
          width: 28.w,
          height: 28.h,
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "4.9 ",
              style: TextStyle(
                color: BrandTrustBanner.goldColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            Icon(
              Icons.star,
              color: BrandTrustBanner.goldColor,
              size: 13.sp,
            ),
          ],
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// 4. DOORSTEP TRUCK GRAPHIC (Fast Delivery Truck with Gear)
/// ---------------------------------------------------------------------------
class _DoorstepTruckGraphic extends StatelessWidget {
  const _DoorstepTruckGraphic();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(54.w, 46.h),
      painter: _TruckPainter(),
    );
  }
}

class _TruckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Color gold = const Color(0xFFF3C042);

    final Paint strokeGold = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint fillDark = Paint()..color = const Color(0xFF090909);
    final Paint fillWhite = Paint()..color = Colors.white;

    // Motion Speed Lines on left
    canvas.drawLine(Offset(0, h * 0.3), Offset(w * 0.12, h * 0.3), strokeGold);
    canvas.drawLine(Offset(w * 0.04, h * 0.45), Offset(w * 0.14, h * 0.45), strokeGold);
    canvas.drawLine(Offset(0, h * 0.6), Offset(w * 0.1, h * 0.6), strokeGold);

    // Truck Cargo Body Outline
    final Path truckPath = Path()
      ..moveTo(w * 0.18, h * 0.22)
      ..lineTo(w * 0.72, h * 0.22)
      ..lineTo(w * 0.72, h * 0.35)
      // Cabin Slope
      ..lineTo(w * 0.88, h * 0.35)
      ..lineTo(w * 0.98, h * 0.55)
      ..lineTo(w * 0.98, h * 0.75)
      ..lineTo(w * 0.88, h * 0.75)
      // Front Wheel Arch
      ..addArc(Rect.fromCircle(center: Offset(w * 0.8, h * 0.75), radius: w * 0.08), math.pi, -math.pi)
      ..lineTo(w * 0.42, h * 0.75)
      // Rear Wheel Arch
      ..addArc(Rect.fromCircle(center: Offset(w * 0.34, h * 0.75), radius: w * 0.08), math.pi, -math.pi)
      ..lineTo(w * 0.18, h * 0.75)
      ..close();

    canvas.drawPath(truckPath, strokeGold);

    // Cabin Window
    final Path windowPath = Path()
      ..moveTo(w * 0.74, h * 0.38)
      ..lineTo(w * 0.86, h * 0.38)
      ..lineTo(w * 0.93, h * 0.52)
      ..lineTo(w * 0.74, h * 0.52)
      ..close();
    canvas.drawPath(windowPath, strokeGold);

    // Gear Circle inside Cargo Body
    final Offset gearCenter = Offset(w * 0.45, h * 0.48);
    final double gearR = h * 0.18;
    canvas.drawCircle(gearCenter, gearR, strokeGold);

    // Gear Teeth (Settings Icon look inside circle)
    final Paint gearPaint = Paint()..color = gold;
    for (int i = 0; i < 6; i++) {
      final double angle = i * (math.pi / 3);
      final Offset toothCenter = gearCenter + Offset(math.cos(angle) * gearR, math.sin(angle) * gearR);
      canvas.drawCircle(toothCenter, 1.8, gearPaint);
    }
    canvas.drawCircle(gearCenter, gearR * 0.4, fillDark);
    canvas.drawCircle(gearCenter, gearR * 0.4, strokeGold);

    // Wheels (Rear & Front)
    void drawWheel(double cx, double cy) {
      canvas.drawCircle(Offset(cx, cy), w * 0.075, fillWhite);
      canvas.drawCircle(Offset(cx, cy), w * 0.075, strokeGold);
      canvas.drawCircle(Offset(cx, cy), w * 0.03, fillDark);
    }

    drawWheel(w * 0.34, h * 0.75);
    drawWheel(w * 0.8, h * 0.75);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
