import 'package:cellphone_doctor/screens/CourseView/controller/course_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void showDetailsDialog(BuildContext context) {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final placeController = TextEditingController();
  final CourseController controller = Get.find<CourseController>();
  int? selectedCourseId;

  // Initialize selectedCourseId if courses are available
  if (controller.courses.isNotEmpty) {
    selectedCourseId = controller.courses[0].id;
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Center(
                     child: Text(
                        "Enter your details",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                   ),
                  SizedBox(height: 20.h),
                  buildTextField("Name", nameController),
                  SizedBox(height: 12.h),
                  buildTextField("Mobile No", mobileController,
                      keyboardType: TextInputType.phone),
                  SizedBox(height: 12.h),
                  buildTextField("Place", placeController),
                  SizedBox(height: 12.h),
                  
                  // Course Selection
                  Text(
                    "Select Course",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: selectedCourseId,
                        hint: Text("Select Type", style: TextStyle(fontSize: 14.sp)),
                        items: controller.courses.map((course) {
                          return DropdownMenuItem<int>(
                            value: course.id,
                            child: Text(course.title ?? "No Title", style: TextStyle(fontSize: 14.sp)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCourseId = value;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                  GetBuilder<CourseController>(
                    builder: (v) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: v.isSubmitting ? null : () {
                            if (nameController.text.trim().isEmpty ||
                                mobileController.text.trim().isEmpty ||
                                placeController.text.trim().isEmpty ||
                                selectedCourseId == null) {
                              Get.snackbar(
                                "Error",
                                "Please fill all fields",
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            if (mobileController.text.length < 10) {
                               Get.snackbar(
                                "Error",
                                "Enter valid mobile number",
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            v.submitCourseDetails(
                              name: nameController.text.trim(),
                              mobile: mobileController.text.trim(),
                              place: placeController.text.trim(),
                              courseId: selectedCourseId.toString(),
                            );
                          },
                          child: v.isSubmitting 
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget buildTextField(String hint, TextEditingController controller,
    {TextInputType keyboardType = TextInputType.text}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
      ),
    ),
  );
}
