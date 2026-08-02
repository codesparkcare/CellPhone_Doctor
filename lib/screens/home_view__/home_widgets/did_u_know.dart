import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cellphone_doctor/models/app/getHomeListModel.dart';
import 'package:cellphone_doctor/utils/app_network_image.dart';

class DidUKnow extends StatelessWidget {
  final List<Blog>? blogs;
  const DidUKnow({super.key, this.blogs});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    // Use only blog images from API
    final List<String> imageUrls = (blogs ?? [])
        .map((b) => (b.image ?? '').trim())
        .where((url) => url.isNotEmpty)
        .toList();

    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 12.w, top: 0, bottom: 0),
          padding: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.only(left: 12.w, top: 2.h, right: 8.w, bottom: 0),
            child: Text(
              "DID YOU KNOW?",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: size.height * 0.20,
          child: PageView.builder(
            itemCount: imageUrls.length,
            controller: PageController(viewportFraction: 0.9),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: buildAppNetworkImage(
                    imageUrl: imageUrls[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
