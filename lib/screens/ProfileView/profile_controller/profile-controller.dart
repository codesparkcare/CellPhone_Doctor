import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ProfileController extends GetxController {
  bool aboutExpanded = false;
  bool referExpanded = false;
  bool helpExpanded = false;
  bool isExpanded =false;

  void toggleAbout() {
    aboutExpanded = !aboutExpanded;
    update();
  }

  void toggleRefer() {
    referExpanded = !referExpanded;
    update();
  }

  void toggleHelp() {
    helpExpanded = !helpExpanded;
    update();
  }

  bool serviceHistoryExpanded = false;
  bool servicesExpanded = false;
  bool settingsExpanded = false;

  void toggleServiceHistory() {
    serviceHistoryExpanded = !serviceHistoryExpanded;
    update();
  }

  void toggleServices() {
    servicesExpanded = !servicesExpanded;
    update();
  }

  void toggleSettings() {
    settingsExpanded = !settingsExpanded;
    update();
  }
}
