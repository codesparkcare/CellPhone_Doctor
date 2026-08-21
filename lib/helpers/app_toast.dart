import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppToast {
  static void showSuccess(String message, {String title = "Success"}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFF10B981), // Emerald Green
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError(String message, {String title = "Error"}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFFEF4444), // Crimson Red
      icon: Icons.error_rounded,
    );
  }

  static void showInfo(String message, {String title = "Info"}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFF3B82F6), // Blue
      icon: Icons.info_rounded,
    );
  }

  static void showWarning(String message, {String title = "Warning"}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFFF59E0B), // Amber
      icon: Icons.warning_rounded,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    if (message.trim().isEmpty) return;

    try {
      // Instantly dismiss any existing snackbar without waiting
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }

      Get.rawSnackbar(
        titleText: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        messageText: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        icon: Icon(icon, color: Colors.white, size: 22),
        backgroundColor: backgroundColor,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 12,
        duration: const Duration(milliseconds: 1800),
        animationDuration: const Duration(milliseconds: 220),
        forwardAnimationCurve: Curves.easeOutCubic,
        reverseAnimationCurve: Curves.easeInCubic,
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
        shouldIconPulse: false,
      );
    } catch (_) {
      // Fallback if Get overlay is unavailable
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).clearSnackBars();
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1800),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
