import 'package:get/get.dart';

class ServiceHistoryController extends GetxController {
  int selectedTab = 0;

  void switchTab(int index) {
    selectedTab = index;
    update();
  }
}