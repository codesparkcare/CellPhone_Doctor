import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../ApiService/ApiService.dart';
import '../../login/model/common_response_model.dart';

class AuthController extends GetxController {
  TextEditingController phoneNumber = TextEditingController();
  bool isLoading = false;

  final ApiService apiService = ApiService();

  void addDigit(String digit) {
    if (phoneNumber.text.length < 10) {
      phoneNumber.text += digit;
      update();
    }
  }

  void removeDigit() {
    if (phoneNumber.text.isNotEmpty) {
      phoneNumber.text = phoneNumber.text.toString().substring(0, phoneNumber.text.toString().length - 1);
      update();
    }
  }

  void clear() {
    phoneNumber.text = "";
    update();
  }


}