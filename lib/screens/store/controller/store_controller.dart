import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreController extends GetxController {
  final String storeName = "Rich Street near subway";
  final String address =
      "New Door No. AA-72, Old Door No. AA-107, Ground Floor, Shanthi Colony Main Road, IVth Avenue, Anna Nagar, Chennai - 600040, Ph:9289309109";
  final String timing = "10:00 AM - 10:00 PM";
  final String openDays = "All Days";
  final String launched = "4 Months Ago";
  final String emi = "No Cost EMI & Cards";
  final double rating = 4.7;

  final List<Map<String, dynamic>> achievements = [
    {"icon": Icons.emoji_emotions_outlined, "count": "23K+", "title": "Happy Customers"},
    {"icon": Icons.build_circle_outlined, "count": "21K+", "title": "Device Repaired"},
    {"icon": Icons.storefront_outlined, "count": "20+", "title": "Stores"},
  ];

  final String historyText =
      "The mobile repair shop industry has transformed remarkably over the past few decades, responding to the exponential rise in mobile device ownership and rapidly advancing technology. Initially, repair shops focused on basic repairs like battery replacements and simple fixes, often dealing with only a few brands. However, as smartphones became more sophisticated, the need for skilled technicians and specialized tools grew. Modern mobile repair businesses now offer comprehensive services for a wide array of brands and device models, handling everything from screen replacements to software troubleshooting and water damage recovery. These shops invest heavily in training, inventory management, and customer service to meet the high expectations of today’s tech-savvy consumers. Digital marketing, online bookings, and value-added services like accessory sales have become integral to their operation.";

  final List<Map<String, dynamic>> moreStores = [
    {
      "name": "RICH STREET",
      "city": "Chennai",
      "address":
      "New Door No. AA-72, Old Door No. AA-107, Ground Floor, Shanthi Colony Main Road, IVth Avenue, Anna Nagar, Chennai - 600040, Ph:9289309109",
      "timing": "11:00 AM - 10:00 PM",
    },
    {
      "name": "ANNA NAGAR",
      "city": "Chennai",
      "address":
      "New Door No. AA-72, Old Door No. AA-107, Ground Floor, Shanthi Colony Main Road, IVth Avenue, Anna Nagar, Chennai - 600040, Ph:9289309109",
      "timing": "11:00 AM - 10:00 PM",
    },
  ];
}
