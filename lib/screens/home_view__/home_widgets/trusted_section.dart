import 'package:cellphone_doctor/models/app/getHomeListModel.dart';
import 'package:cellphone_doctor/utils/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Main Trusted Section Widget
class TrustedSection extends StatelessWidget {
  final List<Review>? reviews;
  const TrustedSection({super.key, this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews == null || reviews!.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Trusted by 35K+ Customers',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          // Subtitle
          Text(
            'Real reviews from real customers who love our service',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 20.h),

          // Rating Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.grey.shade800),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGoogleIcon(18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "4.9",
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(width: 8.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) => Icon(Icons.star, color: Colors.amber, size: 18.sp)),
                  ),
                  SizedBox(width: 12.w),
                  Container(width: 1, height: 18.h, color: Colors.grey.shade700),
                  SizedBox(width: 12.w),
                  Text(
                    "35,000+",
                    style: TextStyle(fontSize: 13.sp, color: Colors.blue.shade400, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    " Happy Customers",
                    style: TextStyle(fontSize: 13.sp, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Horizontal Scrollable Testimonials
          SizedBox(
            height: 300.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: reviews!.length,
              separatorBuilder: (context, index) => SizedBox(width: 16.w),
              itemBuilder: (context, index) {
                final review = reviews![index];
                return TestimonialCard(
                  testimonialText: review.description ?? '',
                  customerName: review.name ?? '',
                  customerImage: review.image,
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  static Widget _buildGoogleIcon(double size) {
    return Image.network(
      "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png",
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          "G",
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Fallback if image fails
          ),
        );
      },
    );
  }
}

class TestimonialCard extends StatelessWidget {
  final String testimonialText;
  final String customerName;
  final String? customerImage;

  const TestimonialCard({
    super.key,
    required this.testimonialText,
    required this.customerName,
    this.customerImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290.w,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF121212), // Very dark grey
        border: Border.all(color: Colors.grey.shade800),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote Icon
          Icon(
            Icons.format_quote_rounded,
            color: Colors.blue.shade500,
            size: 44.sp,
          ),

          // Testimonial Text
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                testimonialText,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.4,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          
          Divider(color: Colors.grey.shade800, height: 1),
          SizedBox(height: 12.h),

          // Customer Info (BOTTOM)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(customerName, customerImage),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      customerName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text(
                    "Verified",
                    style: TextStyle(fontSize: 12.sp, color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, String? image) {
    final hasImage = image != null &&
        image.trim().isNotEmpty &&
        image.trim() != "null" &&
        image.trim() != "failed";
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : "";

    // Vibrant avatar colors based on name
    const colors = [
      Color(0xFF2563EB), // Blue
      Color(0xFF7C3AED), // Purple
      Color(0xFF059669), // Green
      Color(0xFFD97706), // Amber
      Color(0xFFDC2626), // Red
      Color(0xFF0891B2), // Cyan
      Color(0xFF4F46E5), // Indigo
      Color(0xFFDB2777), // Pink
    ];
    final color = colors[name.hashCode.abs() % colors.length];

    return Container(
      width: 36.r,
      height: 36.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: ClipOval(
        child: hasImage
            ? buildAppNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                width: 36.r,
                height: 36.r,
                placeholder: (context, url) => Container(
                  color: color,
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: color,
                  alignment: Alignment.center,
                  child: initial.isNotEmpty
                      ? Text(
                          initial,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Icon(Icons.person, color: Colors.white, size: 18.sp),
                ),
              )
            : Container(
                color: color,
                alignment: Alignment.center,
                child: initial.isNotEmpty
                    ? Text(
                        initial,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Icon(Icons.person, color: Colors.white, size: 18.sp),
              ),
      ),
    );
  }
}