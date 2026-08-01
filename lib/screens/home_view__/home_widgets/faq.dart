import 'package:cellphone_doctor/models/app/getHomeListModel.dart';
import 'package:cellphone_doctor/screens/home_view__/home_controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class FaqSection extends StatelessWidget {
   FaqSection({super.key, this.faqs, this.contentPadding, this.title = "FAQs", this.titleStyle});
   final List<Faq>? faqs;
   final EdgeInsetsGeometry? contentPadding;
   final String title;
   final TextStyle? titleStyle;
  final HomeController controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    if (faqs == null || faqs!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: contentPadding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle ?? TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          GetBuilder<HomeController>(
            builder: (controller) {
              return Column(
                children: [
                  ...List.generate(
                    faqs!.length > controller.visibleFaqsCount 
                        ? controller.visibleFaqsCount 
                        : faqs!.length,
                        (index) {
                      final faq = faqs![index];
                      return FaqItem(
                        question: faq.question ?? '',
                        answer: faq.answer ?? '',
                        isExpanded: controller.expandedIndex == index,
                        onTap: () => controller.toggleExpand(index),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (controller.visibleFaqsCount > 3)
                        TextButton(
                          onPressed: () => controller.seeLessFaqs(),
                          child: const Text(
                            "See Less",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (controller.visibleFaqsCount > 3 && faqs!.length > controller.visibleFaqsCount)
                        const SizedBox(width: 20),
                      if (faqs!.length > controller.visibleFaqsCount)
                        TextButton(
                          onPressed: () => controller.loadMoreFaqs(),
                          child: const Text(
                            "Load More FAQs",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}





class FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  const FaqItem({
    super.key,
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 6.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      answer,
                      style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const Divider(height: 1, color: Colors.black26),
      ],
    );
  }
}
