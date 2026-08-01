import 'package:get/get.dart';
import '../../../models/app/getSpareResponseModel.dart';

class ServiceDetailController extends GetxController {
  List<Data> categories = [];
  int selectedIndex = 0;

  // Option images can be dynamically assigned later if needed
  Map<String, String> optionImages = {};

  // Track added items for each grid
  List<int> isAdded = [];

  void setCategories(List<Data> categoryList) {
    categories = categoryList;
    update();
  }

  void selectCategory(int index) {
    selectedIndex = index;
    update();
  }

  void toggleAdd(int index) {
    if (isAdded.contains(index)) {
      isAdded.remove(index);
    } else {
      isAdded.add(index);
    }
    update();
  }

  void showInfoDialog() {
    // Your info dialog logic
  }
}
