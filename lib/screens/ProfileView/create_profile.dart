import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../ApiService/ApiService.dart';
import '../../helpers/app_toast.dart';
import '../../helpers/auth_helper.dart';
import '../main_screen.dart';
import 'widgets/animated_location_button.dart';

class CreateProfileScreen extends StatefulWidget {
  final String token;
  final String number;

  const CreateProfileScreen({
    super.key,
    required this.token,
    required this.number,
  });

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  bool isLoadingProducts = false;
  bool isDetectingLocation = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Future<void> submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoadingProducts = true;
    });

    List<MultipartRequestService> multipartFields = [];
    await AuthHelper.setString("token", widget.token);

    // Add form fields
    multipartFields.add(MultipartRequestService(
      fieldName: "name",
      fieldValue: nameController.text.trim(),
      isField: true,
      isFile: false,
    ));

    multipartFields.add(MultipartRequestService(
      fieldName: "phone",
      fieldValue: widget.number,
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

    setState(() {
      isLoadingProducts = false;
    });

    if (result != null && result != "failed") {
      await AuthHelper.saveSession(token: widget.token);
      Get.offAll(() => MainScreen());
      AppToast.showSuccess("Profile Created Successfully", title: "Success");
    } else {
      AppToast.showError("Please try again later", title: "Failed");
    }
  }

  Future<String?> _getAddressFromCoordinates(double lat, double lon) async {
    // 1. Native geocoding on Mobile if available
    if (!kIsWeb) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          List<String> addressParts = [
            if (place.street != null && place.street!.isNotEmpty) place.street!,
            if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality!,
            if (place.locality != null && place.locality!.isNotEmpty) place.locality!,
            if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) place.administrativeArea!,
            if (place.postalCode != null && place.postalCode!.isNotEmpty) place.postalCode!,
          ];
          String formatted = addressParts.join(", ");
          if (formatted.isNotEmpty) return formatted;
        }
      } catch (e) {
        debugPrint("Native geocoding error: $e, falling back to reverse API");
      }
    }

    // 2. HTTP Reverse Geocoding API (Works on Web and Mobile)
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'TheCellPhoneDoctor/1.0',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final road = address['road'] ?? address['street'] ?? '';
          final suburb = address['suburb'] ?? address['neighbourhood'] ?? address['subdistrict'] ?? '';
          final city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? '';
          final state = address['state'] ?? '';
          final postcode = address['postcode'] ?? '';

          final parts = [road, suburb, city, state, postcode]
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toSet()
              .toList();

          if (parts.isNotEmpty) {
            return parts.join(", ");
          }
        }
        if (data['display_name'] != null && data['display_name'].toString().isNotEmpty) {
          return data['display_name'].toString();
        }
      }
    } catch (e) {
      debugPrint("HTTP Reverse geocoding error: $e");
    }

    return "$lat, $lon";
  }

  /// Detect GPS Location Automatically (Works across Web and Mobile)
  Future<void> _detectLocation() async {
    setState(() => isDetectingLocation = true);
    try {
      if (!kIsWeb) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          AppToast.showInfo("Opening location settings to enable GPS...", title: "Enable GPS");
          await Geolocator.openLocationSettings();
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            if (mounted) setState(() => isDetectingLocation = false);
            return;
          }
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        AppToast.showWarning("Please grant Location permission in settings", title: "Permission Required");
        if (!kIsWeb) {
          await Geolocator.openAppSettings();
        }
        if (mounted) setState(() => isDetectingLocation = false);
        return;
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position? position;
        try {
          position = await Geolocator.getLastKnownPosition();
        } catch (_) {}

        position ??= await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 4),
          ),
        );

        String? formattedAddress = await _getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (formattedAddress != null && formattedAddress.isNotEmpty) {
          addressController.text = formattedAddress;
          AppToast.showSuccess("Address filled automatically!", title: "Location Detected");
        } else {
          addressController.text = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
          AppToast.showInfo("Coordinates captured: ${addressController.text}", title: "Location Detected");
        }
      } else {
        AppToast.showWarning("Location access was denied. Please enter address manually.", title: "Permission Denied");
      }
    } catch (e) {
      debugPrint("Location detection error: $e");
      AppToast.showInfo("Could not auto-fetch address. You can type your address directly.", title: "Notice");
    } finally {
      if (mounted) {
        setState(() => isDetectingLocation = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    phoneController.text = widget.number;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.snackbar(
          "Profile Required",
          "Please fill in your details to continue to the main app",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            "Create Profile",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
        ),
        body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: AutofillGroup(
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
                    autofillHints: const [AutofillHints.name],
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
                    autofillHints: const [AutofillHints.telephoneNumber],
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
                    label: "Email Address *",
                    icon: Icons.email_outlined,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Enter email";
                      final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                      if (!emailRegex.hasMatch(v.trim())) return "Enter valid email";
                      return null;
                    },
                  ),
          
                  SizedBox(height: 16.h),
          
                  /// ADDRESS
                  customTextField(
                    label: "Address *",
                    icon: Icons.location_on_outlined,
                    controller: addressController,
                    autofillHints: const [AutofillHints.fullStreetAddress],
                    customSuffixIcon: AnimatedLocationButton(
                      isDetecting: isDetectingLocation,
                      onTap: _detectLocation,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Enter your address";
                      if (v.trim().length < 5) return "Address must be at least 5 characters";
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
                              "Save",
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
    Iterable<String>? autofillHints,
    Widget? customSuffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      validator: validator,
      readOnly: readOnly,
      maxLines: maxLines,
      style: TextStyle(fontSize: 15.sp),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue, size: 22.sp),
        suffixIcon: customSuffixIcon ??
            (isLocked ? Icon(Icons.lock_outline, color: Colors.grey, size: 20.sp) : null),
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
