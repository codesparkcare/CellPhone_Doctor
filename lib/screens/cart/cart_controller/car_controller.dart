import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CartController extends GetxController {
  int selectedType = -1; // -1 = None, 0 = Pickup, 1 = Visit Store, 2 = Onsite Service
  int selectedStoreIndex = 0;

  final List<File> uploadedImages = [];
  final picker = ImagePicker();

  void selectServiceType(int value) {
    selectedType = value;
    if (value == 0) selectedStoreIndex = 0;
    update();
  }

  void selectStore(int index) {
    selectedStoreIndex = index;
    update();
  }

  Future<void> pickImages({bool multiple = true}) async {
    if (multiple) {
      final images = await picker.pickMultiImage();
      for (var img in images) {
        uploadedImages.add(File(img.path));
      }
    } else {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        uploadedImages.add(File(image.path));
      }
    }
    update();
  }

  String _selectedPaymentMethod = "Cash On Delivery";
  String get selectedPaymentMethod => _selectedPaymentMethod;
  set selectedPaymentMethod(String val) => _selectedPaymentMethod = val;

  void selectPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    update();
  }

  void removeImage(int index) {
    uploadedImages.removeAt(index);
    update();
  }

  void clearImages() {
    uploadedImages.clear();
    update();
  }
}
