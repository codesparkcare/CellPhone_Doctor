import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../ApiService/ApiService.dart';
import '../../helpers/auth_helper.dart';
import '../../models/app/getProfileResponseModel.dart';


class UpdateProfile extends StatefulWidget {
  final   GetProfileResponseModel? getProfileResponseModel;
  const UpdateProfile({super.key, this.getProfileResponseModel});


  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {

  bool isLoadingProducts = false;
  bool _isLoading = false;
  GetProfileResponseModel? getProfileResponseModel;

  final _formKey = GlobalKey<FormState>();

  /// ✅ Controllers
  late  TextEditingController nameController = TextEditingController(text: widget.getProfileResponseModel!.name);
  late TextEditingController phoneController = TextEditingController(text: widget.getProfileResponseModel!.phone);
  late TextEditingController emailController = TextEditingController(text: widget.getProfileResponseModel!.email);
  late TextEditingController addressController = TextEditingController(text: widget.getProfileResponseModel!.address);

  /// Submit Profile API
  Future<void> submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoadingProducts = true);

    List<MultipartRequestService> multipartFields = [];

    // Add form fields
    multipartFields.add(MultipartRequestService(
      fieldName: "name",
      fieldValue: nameController.text.trim(),
      isField: true,
      isFile: false,
    ));

    multipartFields.add(MultipartRequestService(
      fieldName: "phone",
      fieldValue: phoneController.text.trim(),
      isField: true,
      isFile: false,
    ));

    multipartFields.add(MultipartRequestService(
      fieldName: "email",
      fieldValue: emailController.text.trim(),
      isField: true,
      isFile: false,
    ));

    multipartFields.add(MultipartRequestService(
      fieldName: "address",
      fieldValue: addressController.text.trim(),
      isField: true,
      isFile: false,
    ));

    var result = await ApiService.multipartRequest(
      uri: "/customer/profile",
      method: "POST",
      multipartRequestFields: multipartFields,
      context: context,
      isAuthorized: true,
    );

    setState(() => isLoadingProducts = false);


    print("result$result");
    if (result != null && result != "failed") {
        Navigator.pop(context, {"success": "success"});
        Get.snackbar("Success", "Update Successfully");
    } else {
      Get.snackbar("Failed", "Please try again later");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Personal Details",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    /// NAME
                    customTextField(
                      label: "Full Name *",
                      icon: Icons.person_outline,
                      controller: nameController,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Enter your name";
                        if (v.trim().length < 3) return "Name must be at least 3 characters";
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
            
                    /// PHONE
                    customTextField(
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      readOnly: true,
                      isLocked: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Enter phone number";
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(v.trim())) return "Enter valid 10-digit number";
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
            
                    /// EMAIL
                    customTextField(
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Enter email";
                        final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                        if (!emailRegex.hasMatch(v.trim())) return "Enter valid email";
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 40.h),

                    SizedBox(
                      height: 52.h,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoadingProducts ? null : submitProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: isLoadingProducts
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget customTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    bool isLocked = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      maxLines: maxLines,
      style: TextStyle(fontSize: 15.sp),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue, size: 22.sp),
        suffixIcon: isLocked ? Icon(Icons.lock_outline, color: Colors.grey, size: 20.sp) : null,
        filled: true,
        fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }
}
