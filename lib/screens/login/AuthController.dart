import 'package:cellphone_doctor/screens/login/model/common_response_model.dart';
import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../../ApiService/ApiService.dart';
import '../otp___/otpView.dart';

class AuthController extends GetxController {
  String phoneNumber = "";
  bool isLoading = false;

  final ApiService apiService = ApiService();

  // Add digit
  void addDigit(String num) {
    if (phoneNumber.length < 10) {
      phoneNumber += num;
      update();
    }
  }

  // Remove digit
  void removeDigit() {
    if (phoneNumber.isNotEmpty) {
      phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
      update();
    }
  }


}
