import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cellphone_doctor/screens/home_view__/home_widgets/faq.dart';
import 'package:cellphone_doctor/models/app/getHomeListModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cellphone_doctor/ApiService/ApiService.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  List<Faq>? faqs;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  void _loadFaqs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('home_api_cache_v1');
      if (cachedData != null && cachedData != "failed") {
        final decoded = jsonDecode(cachedData);
        if (decoded is Map<String, dynamic>) {
          final cachedModel = GetHomeListModel.fromJson(decoded);
          if (mounted) {
            setState(() {
              faqs = cachedModel.faq;
            });
          }
        }
      }
      
      final successResult = await ApiService.getData(
        uri: "/home",
        isAuthorized: true,
        context: context,
      );
      if (successResult != null && successResult != "failed" && successResult is Map<String, dynamic>) {
        final freshModel = GetHomeListModel.fromJson(successResult);
        if (mounted) {
          setState(() {
            faqs = freshModel.faq;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading FAQs: $e");
    }
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
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blue.shade900),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Help & Support",
          style: TextStyle(
            color: Colors.blue.shade900,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE3EFFF), Color(0xFFF1F6FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "How can we\nhelp you today?",
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.blue.shade900,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Find answers to common questions or reach out to our support team.",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.blue.shade800,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Image.asset(
                        'assets/images/Chat Bot.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.headset_mic_rounded,
                          size: 70.sp,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Quick Help Title
              Text(
                "Quick Help",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),

              // Quick Help Cards
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildQuickHelpCard(Icons.verified_user_outlined, "Warranty\nInformation", "Know about warranty\n& claim process")),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildQuickHelpCard(Icons.credit_card_outlined, "Payment &\nBilling", "Payment methods\n& billing queries")),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildQuickHelpCard(Icons.local_shipping_outlined, "Pickup &\nDelivery", "Doorstep pickup\n& delivery info")),
                ],
              ),
              SizedBox(height: 24.h),

              // FAQ Section from Home Screen
              // FAQ Section from API/Cache
              if (faqs != null && faqs!.isNotEmpty)
                FaqSection(
                  faqs: faqs, 
                  contentPadding: EdgeInsets.zero, 
                  title: "Frequently Asked Questions",
                  titleStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              SizedBox(height: 24.h),

              // Policies Title
              Text(
                "Policies",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),

              // Policies Cards
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildPolicyCard(Icons.description_outlined, "Terms & Conditions", "Read our terms and\nconditions"),
                    _buildPolicyCard(Icons.lock_outline_rounded, "Privacy Policy", "Learn how we protect\nyour data"),
                    _buildPolicyCard(Icons.verified_outlined, "Warranty Policy", "Know about our warranty\nterms & conditions"),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Still Need Help Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.blue.shade50),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Still Need Help?",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Our support team is here to assist you",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final Uri url = Uri(scheme: 'tel', path: '+918825888258');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.blue.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.call, color: Colors.blue.shade700, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Call Support",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                      Text(
                                        "09:00 AM - 10:00 PM",
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final Uri url = Uri.parse('https://wa.me/918825888258');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade600,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat, color: Colors.white, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "WhatsApp Support",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "Chat with us instantly",
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: Colors.blue.shade100,
                                        ),
                                      ),
                                    ],
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
              SizedBox(height: 16.h),

              // Footer Disclaimer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, size: 14.sp, color: Colors.grey.shade600),
                  SizedBox(width: 6.w),
                  Text(
                    "We are committed to providing you the best support experience.",
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickHelpCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 24.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.grey.shade600,
              height: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.arrow_forward, color: Colors.blue.shade700, size: 16.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(IconData icon, String title, String subtitle) {
    return Container(
      width: 180.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.grey.shade600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.arrow_forward, color: Colors.blue.shade700, size: 16.sp),
          ),
        ],
      ),
    );
  }
}
