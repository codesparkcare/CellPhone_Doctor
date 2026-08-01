class WhyChooseCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const WhyChooseCard({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Stack(
        children: [
          /// 🔹 Title (top-left)
          Positioned(
            top: 8.h,
            left: 8.w,
            right: 8.w,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),

          /// 🔹 Icon (bottom-right)
          Positioned(
            bottom: 8.h,
            right: 10.w,
            child: Icon(
              icon,
              color: Colors.blue,
              size: 35.sp,
            ),
          ),
        ],
      ),
    );
  }
}
