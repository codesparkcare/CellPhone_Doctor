import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class TrackingOrderView extends StatefulWidget {
  const TrackingOrderView({super.key});

  @override
  State<TrackingOrderView> createState() => _TrackingOrderViewState();
}

class _TrackingOrderViewState extends State<TrackingOrderView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Track Order",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          children: [
            ServiceCard(
              id: "0001300826",
              name: "IPhone 16 Pro Max",
              brand: "Apple",
              price: "₹19,998",
              parts: [
                {
                  "name": "Original IPhone 16 Pro Max Display",
                  "price": "₹14,999",
                },
                {"name": "Original IPhone 16 Pro Max Battery", "price": "₹4,999"},
              ],
              statusSteps: [
                {"label": "Service Confirmed", "time": "29-08-2025 | 13:30 pm"},
                {
                  "label": "Device Picked",
                  "time": "29-08-2025 | 2:30 pm",
                  "address":
                  "38, Vallal Pari Nagar 6th St, Pallikaranai, Chennai, Tamil Nadu 600100",
                },
                {"label": "Service Started", "time": "29-08-2025 | 3:00 pm"},
                {
                  "label": "Device Delivered",
                  "address":
                  "NO.27, CP Ramaswamy Iyer Rd, Anandapuram Puram, Abiramapuram, Chennai",
                },
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String id, name, brand, price;
  final List<Map<String, String>> parts;
  final List<Map<String, String>> statusSteps;

  const ServiceCard({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.parts,
    required this.statusSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 55.h,
                    width: 55.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: const Color(0xFFF1F8FE),
                    ),
                    child: Image.asset(
                      "assets/images/modal/modal16.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Service ID: $id",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        brand,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Apx. Total",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),
          Text(
            "Parts",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),

          SizedBox(height: 10.h),
          ...parts.map((part) => PartItem(part)).toList(),

          SizedBox(height: 16.h),
          Text(
            "Service Status",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),

          SizedBox(height: 10.h),
          for (int i = 0; i < statusSteps.length; i++)
            StatusStep(
              statusSteps[i],
              isLast: i == statusSteps.length - 1,
              isCompleted: i <= 2,
            ),

          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add Service",
                style: TextStyle(
                  color: const Color(0xFF1E88E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 22.w,
                    vertical: 10.h,
                  ),
                ),
                onPressed: () {},
                child: const Text("Call Store",style: TextStyle(
                    color:Colors.white
                ),),
              ),
            ],
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget PartItem(Map<String, String> part) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: const Color(0xFFF9FBFD),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            part["name"]!,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
          Text(
            part["price"]!,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget StatusStep(
      Map<String, String> step, {
        bool isLast = false,
        bool isCompleted = true,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isCompleted ? Colors.green : Colors.grey,
                size: 22.sp,
              ),
              if (!isLast)
                Container(
                  width: 2.w,
                  height: 25.h,
                  color: isCompleted ? Colors.green : Colors.grey.shade300,
                ),
            ],
          ),
          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step["label"] ?? "",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: Colors.black,
                  ),
                ),
                if (step["address"] != null)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      step["address"]!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12.sp,
                        height: 1.3,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (step["time"] != null)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                step["time"]!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
              ),
            ),
        ],
      ),
    );
  }
}