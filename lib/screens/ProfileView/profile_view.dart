import 'package:cellphone_doctor/screens/about_us_screen.dart';
import 'package:cellphone_doctor/screens/help_support_screen.dart';
import 'package:cellphone_doctor/screens/ReviewView/review_view.dart';
import 'package:cellphone_doctor/screens/contact_us_screen.dart';
import 'package:cellphone_doctor/screens/Auth/login_screen.dart';
import 'package:cellphone_doctor/screens/ProfileView/profile_controller/profile-controller.dart';
import 'package:cellphone_doctor/screens/ProfileView/update_profile.dart';
import 'package:cellphone_doctor/screens/ServiceHistory/service_history_view.dart';
import 'package:cellphone_doctor/screens/WebScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:cellphone_doctor/controller/navBar_controller.dart';
import '../../ApiService/ApiService.dart';
import '../../helpers/auth_helper.dart';
import '../../models/app/getProfileResponseModel.dart';
import '../service_detail/service_detail_view.dart';
import 'create_profile.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLoading = false;
  GetProfileResponseModel? getProfileResponseModel;

  final ProfileController controller = Get.put(ProfileController());

  /// ✅ LOGIN STATUS
  Future<void> isLogin() async {
    bool status = await AuthHelper.getBool("isShowOnBoard") ?? false;
    if (status) {
      controller.isExpanded = true;
      controller.update();
      getProfile(); // ✅ call API only if logged in
    } else {
      controller.isExpanded = false;
      controller.update();
    }
  }

  /// ✅ API CALL WITH LOADER
  Future<void> getProfile() async {
    setState(() => _isLoading = true);

    try {
      final successResult = await ApiService.getData(
        uri: "/customer/profile",
        isAuthorized: true,
        context: context,
      );

      if (successResult != null) {
        getProfileResponseModel =
            GetProfileResponseModel.fromJson(successResult);
      }
    } catch (e) {
      debugPrint("API Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    isLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade700),
          onPressed: () {
            Get.find<NavController>().changePage(0);
          },
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),

      ),

      /// ✅ MAIN LOADER
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: GetBuilder<ProfileController>(
                  builder: (controller) {
                    final profile = getProfileResponseModel;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ✅ PROFILE CARD
                        _buildProfileCard(controller, profile),

                        SizedBox(height: 24.h),

                        /// ✅ ACCOUNT SECTION HEADER
                        Text(
                          "ACCOUNT",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        /// ✅ MENU ITEMS
                        if (controller.isExpanded) ...[
                          _buildMenuItem(
                            icon: Icons.history_rounded,
                            title: "Service History",
                            subtitle: "View your service orders and status",
                            onTap: () => Get.to(() => ServiceHistoryScreen()),
                          ),
                          _buildMenuItem(
                            icon: Icons.person_outline_rounded,
                            title: "Profile Settings",
                            subtitle: "Manage your personal information",
                            onTap: () async {
                              final result = await Get.to(() => UpdateProfile(
                                  getProfileResponseModel: getProfileResponseModel));
                              if (result != null && result is Map && result["success"] == "success") {
                                getProfile();
                              }
                            },
                          ),

                        ],
                        
                        _buildMenuItem(
                          icon: Icons.call_outlined,
                          title: "Contact Us",
                          subtitle: "Get in touch with our support team",
                          onTap: () {
                            Get.to(() => ContactUsScreen());
                          },
                        ),

                        _buildMenuItem(
                          icon: Icons.star_outline_rounded,
                          title: "Rate Our App",
                          subtitle: "Share your experience with us",
                          onTap: () {
                            Get.to(() => const ReviewView());
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.info_outline_rounded,
                          title: "About",
                          subtitle: "About The Cellphone Doctor",
                          onTap: () {
                            Get.to(() => const AboutUsScreen());
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.help_outline_rounded,
                          title: "Help",
                          subtitle: "FAQs, Policies & Support",
                          onTap: () {
                            Get.to(() => const HelpSupportScreen());
                          },
                        ),
                        
                        if (controller.isExpanded) ...[
                          _buildMenuItem(
                            icon: Icons.logout_rounded,
                            title: "Logout",
                            subtitle: "Sign out from your account",
                            isLast: true,
                            onTap: () {
                              showDialog(
                                context: Get.context!,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    title: const Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text("Logout Account"),
                                      ],
                                    ),
                                    content: const Text("Are you sure you want to logout your account?"),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await AuthHelper.setBool("isShowOnBoard", false);
                                          await AuthHelper.setString("token", "");
                                          Get.off(() => LoginScreen());
                                        },
                                        child: const Text("Logout"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ] else ...[
                          _buildMenuItem(
                            icon: Icons.login_rounded,
                            title: "Login / Signup",
                            subtitle: "Sign in to access all features",
                            isLast: true,
                            onTap: () {
                              Get.off(() => LoginScreen());
                            },
                          ),
                        ],
                        SizedBox(height: 30.h),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard(ProfileController controller, GetProfileResponseModel? profile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.isExpanded ? (profile?.name ?? "User") : "Welcome!",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (controller.isExpanded)
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final result = await Get.to(() => UpdateProfile(getProfileResponseModel: getProfileResponseModel));
                              if (result != null && result is Map && result["success"] == "success") {
                                getProfile();
                              }
                            },
                            icon: Icon(Icons.edit_outlined, size: 14.sp, color: Colors.blue.shade700),
                            label: Text("Edit Profile", style: TextStyle(color: Colors.blue.shade700, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.blue.shade700, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 0),
                              minimumSize: Size(0, 32.h),
                            ),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () => Get.off(() => LoginScreen()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            minimumSize: Size(0, 36.h),
                          ),
                          child: Text("Login", style: TextStyle(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  if (controller.isExpanded) ...[
                    _buildProfileDetailRow(Icons.phone_outlined, profile?.phone ?? "N/A"),
                    SizedBox(height: 10.h),
                    _buildProfileDetailRow(Icons.email_outlined, profile?.email ?? "N/A"),
                  ] else ...[
                    Text("Login or Sign up to view your profile details and manage your account.", style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: const BoxDecoration(
            color: Color(0xFFF0F5FE), // Light blue circle
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14.sp, color: Colors.blue.shade700),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: EdgeInsets.all(10.w),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F7FC), // Very light blue
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 24.sp),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: Colors.grey.shade400),
          onTap: onTap,
        ),
        if (!isLast) Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
      ],
    );
  }
}
