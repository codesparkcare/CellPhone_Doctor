import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/web/device_frame.dart';

class WebLandingPage extends StatefulWidget {
  final Widget child;

  const WebLandingPage({
    super.key,
    required this.child,
  });

  @override
  State<WebLandingPage> createState() => _WebLandingPageState();
}

class _WebLandingPageState extends State<WebLandingPage> {
  int _activeNavIndex = 0;

  final List<String> _navItems = [
    'Home',
    'About Us',
    'Services',
    'Pricing',
    'Our Branches',
    'Contact Us',
  ];

  void _openCodeSpark() async {
    final Uri url = Uri.parse('https://codespark.online');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. Soft Ice-Blue Linear Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF8FAFC),
                    Color(0xFFEFF6FF),
                    Color(0xFFDBEAFE),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // 2. Soft Glowing Background Circle behind Left Headline
          Positioned(
            left: -80,
            top: 140,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE0F2FE).withValues(alpha: 0.6),
              ),
            ),
          ),
          Positioned(
            right: -80,
            bottom: -80,
            child: Container(
              width: 550,
              height: 550,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF60A5FA).withValues(alpha: 0.08),
              ),
            ),
          ),

          // 3. Custom Blue Curved Wave Background & Dot Grid Matrix
          Positioned.fill(
            child: CustomPaint(
              painter: WebBackgroundPainter(),
            ),
          ),

          // 4. Main Scrollable Page Body Content
          SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1720),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Navigation Header Bar
                        _buildHeader(context),

                        const SizedBox(height: 36),

                        // Main Hero Section (Left details + Right Device Frame)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column Details
                            Expanded(
                              flex: 6,
                              child: _buildLeftHeroContent(context),
                            ),

                            const SizedBox(width: 30),

                            // Right Area: Smartphone Frame (DeviceFrame contains phone + single callout set)
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: DeviceFrame(
                                  width: 530,
                                  height: 1040,
                                  child: widget.child,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Web Footer
                _buildWebFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Web Footer Component
  Widget _buildWebFooter() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF032042),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 40),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Feature Items Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 900;
                  if (isNarrow) {
                    return Wrap(
                      spacing: 24,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFooterFeature(
                          icon: Icons.storefront_outlined,
                          title: '15+',
                          subtitle: 'Service Centres',
                        ),
                        _buildFooterFeature(
                          icon: Icons.people_outline,
                          title: '50,000+',
                          subtitle: 'Happy Customers',
                        ),
                        _buildFooterFeature(
                          icon: Icons.verified_outlined,
                          title: 'Up to 1 Year',
                          subtitle: 'Warranty*',
                        ),
                        _buildFooterFeature(
                          icon: Icons.build_circle_outlined,
                          title: 'Genuine &',
                          subtitle: 'High Quality Parts',
                        ),
                        _buildFooterFeature(
                          icon: Icons.lock_outline,
                          title: 'Data Safe',
                          subtitle: '& Secure',
                        ),
                        _buildFooterFeature(
                          icon: Icons.local_shipping_outlined,
                          title: 'Doorstep',
                          subtitle: 'Service',
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFooterFeature(
                        icon: Icons.storefront_outlined,
                        title: '15+',
                        subtitle: 'Service Centres',
                      ),
                      _buildFooterDivider(),
                      _buildFooterFeature(
                        icon: Icons.people_outline,
                        title: '50,000+',
                        subtitle: 'Happy Customers',
                      ),
                      _buildFooterDivider(),
                      _buildFooterFeature(
                        icon: Icons.verified_outlined,
                        title: 'Up to 1 Year',
                        subtitle: 'Warranty*',
                      ),
                      _buildFooterDivider(),
                      _buildFooterFeature(
                        icon: Icons.build_circle_outlined,
                        title: 'Genuine &',
                        subtitle: 'High Quality Parts',
                      ),
                      _buildFooterDivider(),
                      _buildFooterFeature(
                        icon: Icons.lock_outline,
                        title: 'Data Safe',
                        subtitle: '& Secure',
                      ),
                      _buildFooterDivider(),
                      _buildFooterFeature(
                        icon: Icons.local_shipping_outlined,
                        title: 'Doorstep',
                        subtitle: 'Service',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              // Bottom Copyright & Branding Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© ${DateTime.now().year} The Cellphone Doctor. All Rights Reserved.',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  InkWell(
                    onTap: _openCodeSpark,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        children: [
                          TextSpan(text: 'Design By '),
                          TextSpan(
                            text: 'CODESPARK',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterDivider() {
    return Container(
      height: 36,
      width: 1,
      color: const Color(0xFF1E3A60),
    );
  }

  Widget _buildFooterFeature({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 34,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFFCBD5E1),
                height: 1.15,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Header Navigation Section (Exact typography matching image)
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand Logo & Title
        Row(
          children: [
            Image.asset(
              'assets/Icon/Icon.png',
              height: 95,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_android, color: Colors.white, size: 40),
                );
              },
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'THE',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Color(0xFF0F172A),
                    height: 1.1,
                  ),
                ),
                Text(
                  'CELLPHONE',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2563EB),
                    height: 1.05,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'DOCTOR',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    height: 1.05,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Hospital For Sick Mobile',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Navigation Links
        Row(
          children: [
            ...List.generate(_navItems.length - 1, (index) {
              final isSelected = _activeNavIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 36.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _activeNavIndex = index;
                    });
                  },
                  hoverColor: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _navItems[index],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 3,
                        width: isSelected ? 28 : 0,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // CTA Button for "Contact Us"
            InkWell(
              onTap: () {
                setState(() {
                  _activeNavIndex = _navItems.length - 1;
                });
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Contact Us',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Left Content Area
  Widget _buildLeftHeroContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // Trusted Tag Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: Color(0xFF2563EB),
              ),
              SizedBox(width: 8),
              Text(
                "India's Trusted Mobile Service Centre Since 2019",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D4ED8),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Main Headline (Exact sizing & colors matching close-up image)
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 64,
              fontWeight: FontWeight.w900,
              height: 1.1,
              color: Color(0xFF0F172A),
            ),
            children: [
              TextSpan(text: 'We Repair.\nWe Care.\n'),
              TextSpan(
                text: 'We Make It Better!',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Subtitle Description
        const Text(
          'Professional repair solutions for all your smartphones, tablets and laptops with genuine parts and expert technicians.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),

        const SizedBox(height: 28),

        // 4 Key Feature Badges Grid
        Row(
          children: [
            Expanded(
              child: _buildFeatureChip(
                icon: Icons.verified_user_rounded,
                title: 'Genuine Parts',
                subtitle: '100% Original',
              ),
            ),
            Expanded(
              child: _buildFeatureChip(
                icon: Icons.check_circle_rounded,
                title: 'Up to 1 Year',
                subtitle: 'Warranty*',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFeatureChip(
                icon: Icons.access_time_filled_rounded,
                title: 'Quick & Reliable',
                subtitle: 'Service',
              ),
            ),
            Expanded(
              child: _buildFeatureChip(
                icon: Icons.lock_rounded,
                title: 'Data Safe &',
                subtitle: 'Secure',
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Stats Container Card (Matching exact design image)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                iconWidget: const Icon(
                  Icons.groups_rounded,
                  size: 26,
                  color: Color(0xFF2563EB),
                ),
                value: '50,000+',
                label: 'Happy Customers',
              ),
              _buildDivider(),
              _buildStatItem(
                iconWidget: const Icon(
                  Icons.star_outline_rounded,
                  size: 26,
                  color: Color(0xFF2563EB),
                ),
                value: '12+',
                label: 'Service Centres',
              ),
              _buildDivider(),
              _buildStatItem(
                iconWidget: const Icon(
                  Icons.verified_rounded,
                  size: 26,
                  color: Color(0xFF2563EB),
                ),
                value: '12 Years+',
                label: 'Experience',
              ),
              _buildDivider(),
              _buildStatItem(
                iconWidget: SizedBox(
                  width: 24,
                  height: 24,
                  child: CustomPaint(
                    painter: _GoogleGLogoPainter(),
                  ),
                ),
                value: '4.9 ★',
                label: 'Google Rating',
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Bottom Platform Section with QR Codes (Matching exact reference image)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Experience The TCD Service on Every Platform',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 24),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPlatformBadge(
                      iconWidget: SizedBox(
                        width: 32,
                        height: 32,
                        child: CustomPaint(
                          painter: _GooglePlayStoreLogoPainter(),
                        ),
                      ),
                      title: 'Android App',
                      subPrefix: 'Get it on',
                      subBold: 'Google Play Store',
                    ),
                    const SizedBox(width: 28),
                    _buildVerticalDivider(),
                    const SizedBox(width: 28),
                    _buildPlatformBadge(
                      iconWidget: const Icon(
                        Icons.apple,
                        size: 36,
                        color: Color(0xFF0F172A),
                      ),
                      title: 'iOS App',
                      subPrefix: 'Coming Soon on',
                      subBold: 'App Store',
                    ),
                    const SizedBox(width: 28),
                    _buildVerticalDivider(),
                    const SizedBox(width: 28),
                    _buildPlatformBadge(
                      iconWidget: const Icon(
                        Icons.language,
                        size: 34,
                        color: Color(0xFF2563EB),
                      ),
                      title: 'Web Access',
                      subPrefix: 'Visit',
                      subBold: 'CellPhoneDoctor.com',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.sync_rounded,
                    size: 19,
                    color: Color(0xFF2563EB),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Install our app for the best experience and exclusive offers! 🤠',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Feature Chip
  Widget _buildFeatureChip({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
          ),
          child: Icon(
            icon,
            size: 28,
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Stat Item
  Widget _buildStatItem({
    required Widget iconWidget,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        iconWidget,
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 38,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }

  // Platform Badge Item (Matching exact reference image)
  Widget _buildPlatformBadge({
    required Widget iconWidget,
    required String title,
    required String subPrefix,
    required String subBold,
  }) {
    return Row(
      children: [
        iconWidget,
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              subPrefix,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.1,
              ),
            ),
            Text(
              subBold,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                height: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        // Realistic QR Code Box
        _buildQRCodeBox(),
      ],
    );
  }

  Widget _buildQRCodeBox() {
    return Container(
      width: 62,
      height: 62,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _QRCodePainter(),
      ),
    );
  }
}

// Custom Painter for Blue Organic Curved Background & Dot Matrix
class WebBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Blue Organic Curve Gradient (Matching Reference Image)
    final Paint wavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF60A5FA), // Bright sky blue
          Color(0xFF3B82F6), // Vibrant blue
          Color(0xFF2563EB), // Deep blue
        ],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final Path path = Path();
    path.moveTo(w * 0.95, 0);
    path.cubicTo(
      w * 0.85,
      h * 0.25,
      w * 0.65,
      h * 0.55,
      w * 0.60,
      h,
    );
    path.lineTo(w, h);
    path.lineTo(w, 0);
    path.close();

    canvas.drawPath(path, wavePaint);

    // 2. Draw 6x5 white dot matrix grid on bottom right of blue area
    final Paint dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    const int cols = 6;
    const int rows = 5;
    const double spacing = 16.0;
    const double dotRadius = 2.5;

    final double startX = w - 180;
    final double startY = h - 180;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final double x = startX + (c * spacing);
        final double y = startY + (r * spacing);
        if (x > 0 && x < w && y > 0 && y < h) {
          canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Official 4-color Google G Logo
class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 48.0;
    canvas.scale(scale);

    // Official Google 'G' brand colors
    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    // 1. Red Top Arc
    final pathRed = Path()
      ..moveTo(24, 9.5)
      ..cubicTo(29.08, 9.5, 33.35, 11.25, 36.6, 14.3)
      ..lineTo(43.5, 7.4)
      ..cubicTo(38.65, 2.8, 32.1, 0, 24, 0)
      ..cubicTo(14.65, 0, 6.6, 5.35, 2.7, 13.15)
      ..lineTo(10.65, 19.3)
      ..cubicTo(12.55, 13.6, 17.8, 9.5, 24, 9.5)
      ..close();
    canvas.drawPath(pathRed, paintRed);

    // 2. Yellow Left Arc
    final pathYellow = Path()
      ..moveTo(2.7, 13.15)
      ..cubicTo(1.0, 16.55, 0, 20.15, 0, 24)
      ..cubicTo(0, 27.85, 1.0, 31.45, 2.7, 34.85)
      ..lineTo(10.65, 28.7)
      ..cubicTo(9.9, 27.2, 9.5, 25.65, 9.5, 24)
      ..cubicTo(9.5, 22.35, 9.9, 20.8, 10.65, 19.3)
      ..lineTo(2.7, 13.15)
      ..close();
    canvas.drawPath(pathYellow, paintYellow);

    // 3. Green Bottom Arc
    final pathGreen = Path()
      ..moveTo(24, 38.5)
      ..cubicTo(17.8, 38.5, 12.55, 34.4, 10.65, 28.7)
      ..lineTo(2.7, 34.85)
      ..cubicTo(6.6, 42.65, 14.65, 48, 24, 48)
      ..cubicTo(31.35, 48, 37.5, 45.55, 41.8, 41.6)
      ..lineTo(34.25, 35.75)
      ..cubicTo(31.6, 37.55, 28.1, 38.5, 24, 38.5)
      ..close();
    canvas.drawPath(pathGreen, paintGreen);

    // 4. Blue Right Arc and Horizontal Crossbar
    final pathBlue = Path()
      ..moveTo(48, 24)
      ..cubicTo(48, 22.35, 47.1, 19.8, 45.5, 18.2)
      ..cubicTo(44.5, 17.2, 43.0, 16.5, 41.0, 16.5)
      ..lineTo(24, 16.5)
      ..lineTo(24, 26.5)
      ..lineTo(37.5, 26.5)
      ..cubicTo(36.5, 30.5, 33.8, 34.2, 29.5, 36.2)
      ..lineTo(34.25, 35.75)
      ..lineTo(41.8, 41.6)
      ..cubicTo(45.75, 37.95, 48, 31.6, 48, 24)
      ..close();
    canvas.drawPath(pathBlue, paintBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Realistic QR Code
class _QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final double w = size.width;
    final double h = size.height;

    // 3 Finder Pattern Squares
    // Top-Left
    canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.35, h * 0.35), strokePaint);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.15, h * 0.15), paint);

    // Top-Right
    canvas.drawRect(Rect.fromLTWH(w * 0.65, 0, w * 0.35, h * 0.35), strokePaint);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.75, h * 0.1, w * 0.15, h * 0.15), paint);

    // Bottom-Left
    canvas.drawRect(Rect.fromLTWH(0, h * 0.65, w * 0.35, h * 0.35), strokePaint);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.1, h * 0.75, w * 0.15, h * 0.15), paint);

    // Data Modules Matrix
    canvas.drawRect(Rect.fromLTWH(w * 0.45, w * 0.08, w * 0.12, w * 0.12), paint);
    canvas.drawRect(Rect.fromLTWH(w * 0.45, w * 0.28, w * 0.12, w * 0.25), paint);
    canvas.drawRect(Rect.fromLTWH(w * 0.08, w * 0.45, w * 0.25, w * 0.12), paint);
    canvas.drawRect(Rect.fromLTWH(w * 0.65, w * 0.45, w * 0.12, w * 0.12), paint);
    canvas.drawRect(Rect.fromLTWH(w * 0.85, w * 0.48, w * 0.12, w * 0.25), paint);
    canvas.drawRect(Rect.fromLTWH(w * 0.45, w * 0.65, w * 0.35, w * 0.12), paint);
    canvas.drawRect(Rect.fromLTWH(w * 0.65, w * 0.82, w * 0.2, w * 0.12), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Google Play Store Triangle Logo
class _GooglePlayStoreLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final paintGreen = Paint()
      ..color = const Color(0xFF00E676)
      ..style = PaintingStyle.fill;
    final paintBlue = Paint()
      ..color = const Color(0xFF00B0FF)
      ..style = PaintingStyle.fill;
    final paintYellow = Paint()
      ..color = const Color(0xFFFFD600)
      ..style = PaintingStyle.fill;
    final paintRed = Paint()
      ..color = const Color(0xFFFF3D00)
      ..style = PaintingStyle.fill;

    // Blue left triangle
    final pBlue = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.55, h * 0.5)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(pBlue, paintBlue);

    // Green top right
    final pGreen = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.55, h * 0.5)
      ..lineTo(w, h * 0.3)
      ..close();
    canvas.drawPath(pGreen, paintGreen);

    // Red bottom right
    final pRed = Path()
      ..moveTo(0, h)
      ..lineTo(w * 0.55, h * 0.5)
      ..lineTo(w, h * 0.7)
      ..close();
    canvas.drawPath(pRed, paintRed);

    // Yellow right tip
    final pYellow = Path()
      ..moveTo(w * 0.55, h * 0.5)
      ..lineTo(w, h * 0.3)
      ..lineTo(w * 0.9, h * 0.5)
      ..lineTo(w, h * 0.7)
      ..close();
    canvas.drawPath(pYellow, paintYellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
