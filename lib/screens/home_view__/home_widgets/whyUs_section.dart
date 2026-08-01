import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cellphone_doctor/utils/app_colors.dart';

class WhyUsSection extends StatelessWidget {
  const WhyUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF2F8FC), // Very light blueish grey
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Why Us",
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),

          Container(
            decoration: BoxDecoration(
              // You can optionally add a box decoration if you want the whole grid to have a border
            ),
            child: Column(
              children: [
                _buildRow(
                  const WhyUsCard(
                    icon: Icons.business_center_rounded,
                    title: "14+ Years Experience",
                    description: "Trusted by thousands, delivering expert repairs since 2012.",
                  ),
                  const WhyUsCard(
                    icon: Icons.settings_suggest_rounded,
                    title: "Genuine &\nCompatible Parts",
                    description: "Quality spares chosen for durability and performance.",
                  ),
                ),
                _buildRow(
                  const WhyUsCard(
                    icon: Icons.speed_rounded,
                    title: "Fast Service",
                    description: "Most repairs done within hours, not days.",
                  ),
                  const WhyUsCard(
                    icon: Icons.verified_user_rounded,
                    title: "6–12 Months\nWarranty",
                    description: "Actual warranty included with every repair.",
                  ),
                ),
                _buildRow(
                  const WhyUsCard(
                    icon: Icons.fact_check_rounded,
                    title: "15-Point QC\nChecklist",
                    description: "Comprehensive check-lists ensure your device is flawless before return.",
                  ),
                  const WhyUsCard(
                    icon: Icons.lock_rounded,
                    title: "Data Security",
                    description: "Your privacy protected at every step.",
                  ),
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildRow(Widget left, Widget right, {bool isLast = false}) {
  return Column(
    children: [
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 16.h, bottom: 16.h, right: 16.w, left: 4.w),
                child: left,
              ),
            ),
            VerticalDivider(color: Colors.grey.shade300, width: 1, thickness: 1),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 16.h, bottom: 16.h, left: 16.w, right: 4.w),
                child: right,
              ),
            ),
          ],
        ),
      ),
      if (!isLast) Divider(color: Colors.grey.shade300, height: 1, thickness: 1),
    ],
  );
}

class WhyUsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const WhyUsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.blue.shade100.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            color: Colors.blue.shade600,
            size: 24.sp,
          ),
        ),
        SizedBox(height: 14.h),
        // Title
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        // Description
        Text(
          description,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
          maxLines: 3,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }
}
