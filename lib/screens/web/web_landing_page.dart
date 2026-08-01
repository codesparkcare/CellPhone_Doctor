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

  void _openWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/919876543210');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Gradient & Soft Decorative Accents
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

          // Soft Background Decorative Circles
          Positioned(
            right: -100,
            bottom: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 400,
            top: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF60A5FA).withValues(alpha: 0.05),
              ),
            ),
          ),

          // Main Scrollable Page Body
          SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1380),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Navigation Bar
                    _buildHeader(context),

                    const SizedBox(height: 40),

                    // Main Hero Section (Left Details + Right Phone Frame)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Content Area
                        Expanded(
                          flex: 6,
                          child: _buildLeftHeroContent(context),
                        ),

                        const SizedBox(width: 40),

                        // Right Area: Smartphone Frame containing live app
                        Expanded(
                          flex: 5,
                          child: Center(
                            child: DeviceFrame(
                              width: 414,
                              height: 840,
                              child: widget.child,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header Navigation Section
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand Logo & Title
        Row(
          children: [
            Image.asset(
              'assets/images/cell_logo.png',
              height: 55,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_android, color: Colors.white),
                );
              },
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'THE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'CELLPHONE DOCTOR',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1D4ED8),
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hospital For Sick Mobile',
                  style: TextStyle(
                    fontSize: 11,
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
          children: List.generate(_navItems.length, (index) {
            final isSelected = _activeNavIndex == index;
            return Padding(
              padding: const EdgeInsets.only(left: 28.0),
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
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 2.5,
                      width: isSelected ? 24 : 0,
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
        ),
      ],
    );
  }

  // Left Side Main Hero Content
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

        // Main Headline
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 52,
              fontWeight: FontWeight.w900,
              height: 1.15,
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

        const SizedBox(height: 18),

        // Subtitle Description
        const Text(
          'Professional repair solutions for all your smartphones, tablets and laptops with genuine parts and expert technicians.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),

        const SizedBox(height: 32),

        // 4 Key Feature Badges Grid
        Row(
          children: [
            Expanded(
              child: _buildFeatureChip(
                icon: Icons.check_circle,
                title: 'Genuine Parts',
                subtitle: '100% Original',
              ),
            ),
            Expanded(
              child: _buildFeatureChip(
                icon: Icons.verified_user,
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
                icon: Icons.access_time_filled,
                title: 'Quick & Reliable',
                subtitle: 'Service',
              ),
            ),
            Expanded(
              child: _buildFeatureChip(
                icon: Icons.lock,
                title: 'Data Safe &',
                subtitle: 'Secure',
              ),
            ),
          ],
        ),

        const SizedBox(height: 36),

        // Stats Container Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.groups_rounded,
                value: '50,000+',
                label: 'Happy Customers',
              ),
              _buildDivider(),
              _buildStatItem(
                icon: Icons.storefront_rounded,
                value: '12+',
                label: 'Service Centres',
              ),
              _buildDivider(),
              _buildStatItem(
                icon: Icons.workspace_premium_rounded,
                value: '12 Years+',
                label: 'Experience',
              ),
              _buildDivider(),
              _buildStatItem(
                icon: Icons.star_rounded,
                value: '4.9 ★',
                label: 'Google Rating',
                valueColor: const Color(0xFF2563EB),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // WhatsApp Help Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Need Help?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Our support team is ready to help you!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _openWhatsApp,
                icon: const Icon(Icons.chat_bubble, size: 16),
                label: const Text('Chat on WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Bottom Platform Section with QR Codes
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            children: [
              const Text(
                'Experience The TCD Service on Every Platform',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildPlatformBadge(
                    icon: Icons.android,
                    title: 'Android App',
                    subtitle: 'Get it on Google Play Store',
                  ),
                  _buildPlatformBadge(
                    icon: Icons.apple,
                    title: 'iOS App',
                    subtitle: 'Coming Soon on App Store',
                  ),
                  _buildPlatformBadge(
                    icon: Icons.language,
                    title: 'Web Access',
                    subtitle: 'Visit CellPhoneDoctor.com',
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
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
    required IconData icon,
    required String value,
    required String label,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: const Color(0xFF2563EB)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
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

  // Platform QR Code Badge
  Widget _buildPlatformBadge({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, size: 28, color: const Color(0xFF1E293B)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // QR Code Box Representation
        Container(
          width: 36,
          height: 36,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
              9,
              (i) => Container(
                color: (i % 2 == 0) ? Colors.black : Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
