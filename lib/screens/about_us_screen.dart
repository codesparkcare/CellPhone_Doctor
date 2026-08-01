import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade700),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "About Us",
          style: TextStyle(
            color: Colors.blue.shade900,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Hero Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE8F0FE), Color(0xFFD2E3FC)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 20.h, bottom: 40.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/cell_logo.png',
                          width: 120.w,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Text(
                            "TCD",
                            style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "Registered Multi Brand Mobile Service Centre",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          height: 3,
                          width: 40,
                          color: Colors.blue.shade600,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "We are a professional and trusted mobile, tablet & laptop service center with 12+ branches across Tamil Nadu.",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.blue.shade900,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 4,
                    child: Image.asset(
                      'assets/images/store_img.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.store, size: 80.sp, color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -25),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    // Stats Row
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(Icons.calendar_today, Colors.blue, "Since", "2019"),
                          _buildStatItem(Icons.business, Colors.green, "12+", "Branches"),
                          _buildStatItem(Icons.group, Colors.orange, "50,000+", "Happy\nCustomers"),
                          _buildStatItem(Icons.verified, Colors.purple, "100%", "Trusted\nService"),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // What We Do Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 30.w, height: 1, color: Colors.blue.shade300),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Text(
                            "What We Do",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(width: 30.w, height: 1, color: Colors.blue.shade300),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Services Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 1.15,
                      children: [
                        _buildServiceCard(Icons.phone_android, Colors.blue, "Mobile Repair", "All types of mobile repairs with expert technicians"),
                        _buildServiceCard(Icons.laptop_chromebook, Colors.green, "Laptop Repair", "Professional laptop service & hardware solutions"),
                        _buildServiceCard(Icons.tablet_mac, Colors.purple, "Tablet Repair", "Specialized tablet repair with original parts"),
                        _buildServiceCard(Icons.security, Colors.orange, "Warranty Support", "Up to 1 Year warranty on selected services"),
                        _buildServiceCard(Icons.new_releases, Colors.red, "Original Parts", "We use original & high quality parts for every repair"),
                        _buildServiceCard(Icons.two_wheeler, Colors.blue.shade800, "Doorstep Service", "Pick Up & Drop service available at your doorstep"),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Our Promise
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9), // Light green
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check, color: Colors.white, size: 24.sp),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Our Promise",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "Quality service, transparent pricing and 100% customer satisfaction is our top priority.",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Icon(Icons.handshake, color: Colors.green.shade200, size: 60.sp),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Footer
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.favorite_border, color: Colors.blue.shade700, size: 24.sp),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Colors.black87, fontSize: 12.sp, height: 1.4),
                                    children: [
                                      const TextSpan(text: "Thank you for choosing "),
                                      TextSpan(text: "THE CELLPHONE DOCTOR.\n", style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                                      const TextSpan(text: "We look forward to serving you!"),
                                    ],
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String title, String subtitle) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(IconData icon, Color color, String title, String description) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6.h),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
