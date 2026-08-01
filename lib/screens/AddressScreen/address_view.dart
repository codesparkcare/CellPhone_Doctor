import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'Address_Controller/address_controller.dart';

class SelectAddressScreen extends StatelessWidget {
  String type = "";
  SelectAddressScreen({super.key,required this.type});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SelectAddressController>(
      init: SelectAddressController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FBFF),
            appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: Text(
              type == "pick" ? "Select Pickup Address" : "Select Delivery Address",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),

          body: Column(
            children: [
              SizedBox(
                height: !controller.showFullForm
                    ? MediaQuery.of(context).size.height * 0.45
                    : MediaQuery.of(context).size.height * 0.25,
                width: double.infinity,
                child: controller.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1E88E5),
                        ),
                      )
                    : Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: controller.centerLocation,
                              zoom: 16,
                            ),
                            onMapCreated: controller.onMapCreated,
                            onCameraMove: controller.onCameraMove,
                            onCameraIdle: () async {
                              await controller.onCameraIdle();
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            padding: const EdgeInsets.only(top: 60), // Push map controls down
                          ),
      
                          // ✅ CENTER PIN
                          const Center(
                            child: Icon(
                              Icons.location_pin,
                              size: 50,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   controller.showFullForm
                      //       ? "Enter address Details"
                      //       : "Selected your pick up Location",
                      //   style: TextStyle(
                      //     fontSize: 16.sp,
                      //     fontWeight: FontWeight.w700,
                      //     color: Colors.black87,
                      //   ),
                      // ),
                      // SizedBox(height: 14.h),

                      if (controller.showFullForm) ...[
                        // Text(
                        //   "Complete Address*",
                        //   style: TextStyle(
                        //     color: Colors.grey[600],
                        //     fontSize: 13.sp,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                        // SizedBox(height: 6.h),
                        // buildTextField(
                        //   "House no/ Flat no/ Floor no/ Building",
                        //   onChanged: (v) => controller.updateAddress(v),
                        // ),

                        // SizedBox(height: 14.h),
                        // Text(
                        //   "How to reach (optional)",
                        //   style: TextStyle(
                        //     color: Colors.grey[600],
                        //     fontSize: 13.sp,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                        // SizedBox(height: 6.h),
                        // buildTextField(
                        //   "Landmark / Nearby place",
                        //   onChanged: (v) => controller.updateLandmark(v),
                        // ),

                        SizedBox(height: 14.h),
                        Text(
                          "Door number with street address",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        buildTextField(
                          "Enter door number and street",
                          onChanged: (v) => controller.updateDoorNumber(v),
                        ),

                        SizedBox(height: 14.h),
                        Text(
                          "Area Name",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        buildTextField(
                          "Enter area name",
                          onChanged: (v) => controller.updateAreaName(v),
                        ),

                        SizedBox(height: 14.h),
                        Text(
                          "Phone Number",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        buildTextField(
                          "Enter phone number",
                          onChanged: (v) => controller.updatePhoneNumber(v),
                          keyboardType: TextInputType.phone,
                        ),

                        SizedBox(height: 20.h),
                        Text(
                          "Tag this location for later",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10.h),

                        Wrap(
                          spacing: 14.w,
                          runSpacing: 10.h,
                          children: [
                            GestureDetector(
                                onTap: () => controller.selectTag("Home"),
                                child: tagButton("Home",
                                    selected: controller.selectedTag == "Home")),
                            GestureDetector(
                                onTap: () => controller.selectTag("Office"),
                                child: tagButton("Office",
                                    selected: controller.selectedTag == "Office")),
                            GestureDetector(
                                onTap: () => controller.selectTag("Other"),
                                child: tagButton("Other",
                                    selected: controller.selectedTag == "Other")),
                          ],
                        ),
                        SizedBox(height: 24.h),
                      ],
                      
                      Text(
                        "Your Location",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6.h),

                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.blue.withOpacity(0.1)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, color: Colors.blue, size: 20),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                controller.selectedAddress,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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

              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (!controller.showFullForm) {
                      controller.toggleForm();
                    } else {
                      if (controller.doorNumber.trim().isEmpty || 
                          controller.areaName.trim().isEmpty || 
                          controller.phoneNumber.trim().isEmpty) {
                        Get.snackbar("Validation Error", "Please fill in Door Number, Area Name, and Phone Number",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900);
                        return;
                      }
                      
                      String detailedAddress = "${controller.doorNumber}, ${controller.areaName}, ${controller.selectedAddress}";

                      Get.back(result: {
                        "lat": controller.centerLocation.latitude,
                        "lng": controller.centerLocation.longitude,
                        "address": detailedAddress,
                        "complete_address": controller.completeAddress,
                        "landmark": controller.landmark,
                        "phone": controller.phoneNumber,
                        "tag": controller.selectedTag,
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    controller.showFullForm
                        ? "Save Address"
                        : "Confirm Location & Proceed",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildTextField(String hint, {Function(String)? onChanged, TextInputType? keyboardType}) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 13.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        border: const UnderlineInputBorder(),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1E88E5), width: 1.5),
        ),
      ),
    );
  }

  Widget tagButton(String label, {bool selected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1E88E5) : Colors.transparent,
        border: Border.all(color: const Color(0xFF1E88E5), width: 1.2),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : const Color(0xFF1E88E5),
        ),
      ),
    );
  }
}
