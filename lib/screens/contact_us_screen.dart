import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade700),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Text(
              "Contact Us",
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "We are here to help you!",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Top Blue Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.headset_mic_rounded, size: 60.sp, color: Colors.white),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "We're here for you!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Reach out to our support team through any of the options below.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            _buildBannerTag(Icons.verified_user, "Trusted Support", "Reliable & Fast"),
                            SizedBox(width: 12.w),
                            _buildBannerTag(Icons.access_time_filled, "Quick Response", "We care for you"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Contact Options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildContactOption(
                    icon: Icons.phone,
                    iconColor: Colors.green,
                    iconBgColor: Colors.green.shade50,
                    title: "Call Us",
                    subtitle: "Talk to our customer support",
                    trailingText: "+91 88258 88258",
                    trailingColor: Colors.green,
                    onTap: () async {
                      final Uri url = Uri(scheme: 'tel', path: '+918825888258');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildContactOption(
                    icon: Icons.message, // Placeholder for WhatsApp
                    iconColor: Colors.green.shade600,
                    iconBgColor: Colors.green.shade50,
                    title: "WhatsApp Support",
                    subtitle: "Chat with us on WhatsApp",
                    trailingText: "+91 88258 88258",
                    trailingColor: Colors.green,
                    onTap: () async {
                      final Uri url = Uri.parse('https://wa.me/918825888258');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildContactOption(
                    icon: Icons.email_outlined,
                    iconColor: Colors.blue.shade700,
                    iconBgColor: Colors.blue.shade50,
                    title: "Email Support",
                    subtitle: "Send us an email anytime",
                    trailingText: "support@tcdindia.in",
                    trailingColor: Colors.blue.shade700,
                    onTap: () async {
                      final Uri url = Uri(
                        scheme: 'mailto',
                        path: 'support@tcdindia.in',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Working Hours
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7FC), // Light blue background
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.blue.shade700, size: 24.sp),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Working Hours", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                          Text("We are available all days", style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp)),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Divider(color: Colors.blue.shade100, height: 1),
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.blue.shade700, size: 24.sp),
                      SizedBox(width: 12.w),
                      Text("Monday - Sunday", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                      const Spacer(),
                      Text("09:00 AM - 10:00 PM", style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Service Request 24/7
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F1), // Light green background
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.green.shade300, width: 1.5),
                              ),
                              child: Text("24/7", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 10.sp)),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                "Service Request Available 24/7",
                                style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        _buildChecklistText("You can place your service request anytime, even during night hours."),
                        SizedBox(height: 8.h),
                        _buildChecklistText("Our team will review and process your request between 09:00 AM to 10:00 PM."),
                        SizedBox(height: 8.h),
                        _buildChecklistText("Requests placed at night will be attended and worked on the next day."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Note
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E6), // Light orange/yellow background
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notifications_active, color: Colors.orange.shade400, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Note", style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                        SizedBox(height: 2.h),
                        Text(
                          "You will receive updates and our team will contact you as soon as possible.",
                          style: TextStyle(color: Colors.black87, fontSize: 11.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerTag(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 12.sp),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.white70, fontSize: 8.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String trailingText,
    required Color trailingColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  SizedBox(height: 2.h),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp)),
                ],
              ),
            ),
            Text(trailingText, style: TextStyle(color: trailingColor, fontWeight: FontWeight.bold, fontSize: 13.sp)),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: Colors.green.shade600, size: 16.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.black87, fontSize: 11.sp, height: 1.4),
          ),
        ),
      ],
    );
  }
}
