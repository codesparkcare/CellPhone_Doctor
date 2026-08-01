import 'package:cellphone_doctor/models/app/getHomeListModel.dart';
import 'package:cellphone_doctor/utils/app-sizes.dart';
import 'package:cellphone_doctor/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreSection extends StatefulWidget {
  final List<Store>? stores;
  
  const StoreSection({super.key, this.stores});

  @override
  State<StoreSection> createState() => _StoreSectionState();
}

class _StoreSectionState extends State<StoreSection> {
  String selectedCity = '';
  int selectedBranchIndex = 0;
  List<String> cities = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }
  
  @override
  void didUpdateWidget(covariant StoreSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stores != widget.stores) {
      _initData();
    }
  }

  void _initData() {
    if (widget.stores != null && widget.stores!.isNotEmpty) {
      cities = widget.stores!
          .map((s) => s.city ?? "")
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();
          
      if (cities.isNotEmpty && !cities.contains(selectedCity)) {
        selectedCity = cities.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Store> filteredStores = widget.stores != null
        ? widget.stores!.where((s) => (s.city ?? "") == selectedCity).toList()
        : [];
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 20.h),
          child: Text(
            "OUR STORES",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
        
        Padding(
          padding: EdgeInsets.only(left: 16.w, top: 12.h, bottom: 8.h),
          child: Row(
            children: [
              Icon(CupertinoIcons.location, color: Colors.blue, size: 18.sp),
              SizedBox(width: 4.w),
              Text(
                "Select City",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: cities.map((city) {
                      bool isSelected = city == selectedCity;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCity = city;
                            selectedBranchIndex = 0;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 8.w),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.white,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            city,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
          
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Branch in $selectedCity (${filteredStores.length} ${filteredStores.length == 1 ? 'Branch' : 'Branches'})",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 248.h,
          child: filteredStores.isEmpty
              ? Center(
                  child: Text(
                    "No stores available in $selectedCity",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: 16.w, right: 4.w),
                  itemCount: filteredStores.length,
                  itemBuilder: (context, index) {
                    final store = filteredStores[index];
                    return StoreCard(
                      title: store.title ?? "",
                      address: store.address ?? "",
                      timing: store.timing ?? "",
                      phone: store.phone,
                      mapUrl: store.map,
                      landmark: store.landmark,
                    );
                  },
                ),
        ),
        
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F5FF), // Light blue background
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(Icons.storefront_outlined, "10+", "Branches", topColor: Colors.blue.shade700, topSize: 13.sp),
              Container(width: 1, height: 24.h, color: Colors.grey.shade300),
              _buildStatItem(Icons.security, "Genuine", "Parts"),
              Container(width: 1, height: 24.h, color: Colors.grey.shade300),
              _buildStatItem(Icons.speed_outlined, "Fast &", "Reliable"),
              Container(width: 1, height: 24.h, color: Colors.grey.shade300),
              _buildStatItem(Icons.support_agent_outlined, "Expert", "Support"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String title1, String title2, {Color topColor = Colors.black87, double? topSize}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 24.sp),
        SizedBox(width: 6.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title1,
              style: TextStyle(fontSize: topSize ?? 11.sp, fontWeight: FontWeight.w800, color: topColor),
            ),
            Text(
              title2,
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ],
        )
      ],
    );
  }
}

class StoreCard extends StatelessWidget {
  final String title;
  final String address;
  final String timing;
  final String? city;
  final String? phone;
  final dynamic mapUrl;
  final String? landmark;
  final VoidCallback? onViewMore;
  final VoidCallback? onCallNow;
  final VoidCallback? onLocation;
  final bool isSelected;

  const StoreCard({
    super.key,
    required this.title,
    required this.address,
    required this.timing,
    this.city,
    this.phone,
    this.mapUrl,
    this.landmark,
    this.onViewMore,
    this.onCallNow,
    this.onLocation,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final VoidCallback? handleCall = (phone != null && phone!.isNotEmpty)
        ? () async {
            final Uri phoneUri = Uri.parse("tel:+91$phone");
            if (await canLaunchUrl(phoneUri)) {
              await launchUrl(phoneUri);
            }
          }
        : null;

    final VoidCallback? handleLocation = (mapUrl != null && mapUrl.toString().isNotEmpty)
        ? () async {
            final Uri mapUri = Uri.parse(mapUrl.toString());
            if (await canLaunchUrl(mapUri)) {
              await launchUrl(mapUri, mode: LaunchMode.externalApplication);
            }
          }
        : null;

    return Container(
      width: 320.w,
      margin: EdgeInsets.only(right: 12.w, bottom: 4.h, top: 4.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 28.w),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        "Open Hours",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.time, color: Colors.grey.shade500, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          timing,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(CupertinoIcons.location, color: Colors.grey, size: 14.sp),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        address,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                if (landmark != null && landmark!.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.only(left: 18.w),
                    child: Text(
                      "Landmark: $landmark",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
                const Spacer(),
                Row(
                  children: [
                    if (handleCall != null)
                      GestureDetector(
                        onTap: handleCall,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F0FF),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            CupertinoIcons.phone_fill,
                            color: Colors.blue.shade600,
                            size: 16.sp,
                          ),
                        ),
                      ),
                    if (handleCall != null) SizedBox(width: 8.w),
                    if (handleCall != null)
                      Expanded(
                        child: GestureDetector(
                          onTap: handleCall,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Call Now",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (handleCall != null) SizedBox(width: 8.w),
                    if (handleLocation != null)
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: handleLocation,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.location_solid,
                                  color: Colors.blue.shade700,
                                  size: 14.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "Get Directions",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
