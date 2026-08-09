import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cellphone_doctor/screens/AddressScreen/address_view.dart';
import 'package:cellphone_doctor/utils/app_colors.dart';
import 'package:cellphone_doctor/utils/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../ApiService/ApiService.dart';
import '../../helpers/auth_helper.dart';
import '../../models/app/GetCartListResponseModel.dart';
import '../../models/app/getNearByStoreResponseModel.dart';
import '../../widgets/confirm_dialog.dart';
import 'cart_controller/car_controller.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/app/getProfileResponseModel.dart';
import '../home_view__/home_widgets/Strore_section.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  GetCartListResponseModel? getHomeListModel;
  GetNearByStoreResponseModel? getNearByStoreResponseModel;
  GetProfileResponseModel? profileDetails;
  bool isDeliverySameAsPickup = false;
  bool _isLoading = true;
  int randomHeaderIndex = 1;
  String parentName = '';
  String subName = '';
  String image = '';
  bool? serviceEnabled;
  late Razorpay razorpay;
  String? selectedCityFilter;

  Future<void> getProfile() async {
    try {
      final successResult = await ApiService.getData(
        uri: "/customer/profile",
        isAuthorized: true,
        context: context,
      );

      if (successResult != null) {
        setState(() {
          profileDetails = GetProfileResponseModel.fromJson(successResult);
        });
      }
    } catch (e) {
      debugPrint("API Error: $e");
    }
  }

  Future<String> createOrder(double amount, String name) async {
    var headers = {
      'Authorization': 'Basic ' +
          base64Encode(
              utf8.encode('rzp_live_KxQfs7AIuG7S7k:3TH4qGEFM02Fu2bcAABS8z7R')),
      'Content-Type': 'application/json'
    };

    var response = await http.post(
      Uri.parse('https://api.razorpay.com/v1/orders'),
      headers: headers,
      body: jsonEncode({
        'amount': amount * 100, // in paise = ₹500.00
        'currency': 'INR',
        'receipt': 'receipt${name}',
        'payment_capture': 1
      }),
    );

    var data = jsonDecode(response.body);
    return data['id']; // This is the order_id
  }
  bool _isConfirming = false;
  String selectedPaymentMethod = "";
  String pickAddress= "Pick up Location";
  String deliveryAddress= "Delivery Location";
  String? pickAddressError;
  String? deliveryAddressError;
  String? serviceTypeError;
  String? storeSelectionError;
  Map? pickDetailsFull;
  Map? deliveryDetailsFull;

  // Pickup Date & Time State
  int selectedPickupDateIndex = -1; // -1: None, 0: Today, 1: Tomorrow, 2: Select Date
  DateTime? customPickupDate;
  String selectedPickupTimeSlot = "";
  String? pickupDateTimeError;

  final CartController cartController = Get.put(CartController());

  getCart(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final successResult = await ApiService.getData(
        uri: "/customer/cart",
        isAuthorized: true,
        context: context,
      );
      if (successResult != null) {
        setState(() {
          print("successResult$successResult");
          getHomeListModel = GetCartListResponseModel.fromJson(successResult);

          if (getHomeListModel!.data!.isNotEmpty) {
            setState(() {
              var items = successResult['data'] as List;
              var newestItem = items.reduce((curr, next) {
                num currId = curr['id'] ?? 0;
                num nextId = next['id'] ?? 0;
                return currId > nextId ? curr : next;
              });
              parentName = newestItem['parentname'] ?? '';
              subName = newestItem['name'] ?? '';
              image = newestItem['image'] ?? '';

              if (parentName.isEmpty) {
                SharedPreferences.getInstance().then((prefs) {
                  setState(() {
                    parentName = prefs.getString('last_added_parentname') ?? '';
                    subName = prefs.getString('last_added_subname') ?? '';
                    image = prefs.getString('last_added_image') ?? image;
                  });
                });
              }
            });
          } else{
            parentName = "";
          }

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserLocation() async {

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled!) {
      await Geolocator.openLocationSettings();
      return;
    }

  }

  Future<bool> deleteCart(BuildContext context, String id) async {
    try {
      final response = await ApiService.getData(
        uri: "/customer/cart/delete/$id",
        isAuthorized: true,
        context: context,
      );
      print("response$response");

      // API failed or null
      if (response != null || response != "failed") {
        Get.snackbar("Success", "Product Delete Successfully");
        return true;
      } else{
        Get.snackbar("Failed", "Order confirmation failed");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
      return false;
    }
  }

  getNearStore  (BuildContext context) async {
    try {
      final successResult = await ApiService.getData(
        uri: "/store",
        isAuthorized: true,
        context: context,
      );
      if (successResult != null) {
        setState(() {
          getNearByStoreResponseModel = GetNearByStoreResponseModel.fromJson(successResult);

        });
      }
    } catch (_) {

    }
  }

  Future<void> confirmBookingApi(CartController ctrl) async {
    setState(() {
      _isConfirming = true;
      serviceTypeError = null;
      storeSelectionError = null;
      pickAddressError = null;
      deliveryAddressError = null;
      pickupDateTimeError = null;
    });
    
    try {
      // 1. Validate Service Mode Selection
      if (ctrl.selectedType == -1) {
        setState(() {
          serviceTypeError = "Please select a Service Mode";
          _isConfirming = false;
        });
        Get.snackbar("Validation Error", "Please select a Service Mode",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900);
        return;
      }

      // 2. Validate Visit Store Selection
      if (ctrl.selectedType == 1) {
        if (ctrl.selectedStoreIndex == 0) {
          setState(() {
            storeSelectionError = "Please select a branch for store visit";
            _isConfirming = false;
          });
          Get.snackbar("Validation Error", "Please select a branch for store visit",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900);
          return;
        }
      }

      // 3. Validate Pickup & Delivery
      if (ctrl.selectedType == 0) {
        if (pickAddress == "Pick up Location" || pickAddress.trim().isEmpty) {
          setState(() {
            pickAddressError = "Please select a pickup location";
            _isConfirming = false;
          });
          Get.snackbar("Validation Error", "Please select a pickup location",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900);
          return;
        }

        if (deliveryAddress == "Delivery Location" || deliveryAddress.trim().isEmpty) {
          setState(() {
            deliveryAddressError = "Please select a delivery location";
            _isConfirming = false;
          });
          Get.snackbar("Validation Error", "Please select a delivery location",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900);
          return;
        }

        if (selectedPickupDateIndex == -1 || (selectedPickupDateIndex == 2 && customPickupDate == null)) {
          setState(() {
            pickupDateTimeError = "Please select a preferred pickup date";
            _isConfirming = false;
          });
          Get.snackbar("Validation Error", "Please select a preferred pickup date",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900);
          return;
        }

        if (selectedPickupTimeSlot.trim().isEmpty) {
          setState(() {
            pickupDateTimeError = "Please select a preferred time slot";
            _isConfirming = false;
          });
          Get.snackbar("Validation Error", "Please select a preferred time slot",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900);
          return;
        }
      }

      // 4. Validate Onsite Service
      if (ctrl.selectedType == 2) {
        if (deliveryAddress == "Delivery Location" || deliveryAddress == "Customer Service Location" || deliveryAddress.trim().isEmpty) {
          setState(() {
            deliveryAddressError = "Please select a service location";
            _isConfirming = false;
          });
          Get.snackbar("Validation Error", "Please select a service location",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900);
          return;
        }

        if (selectedPickupDateIndex == -1 || (selectedPickupDateIndex == 2 && customPickupDate == null)) {
          setState(() {
            pickupDateTimeError = "Please select a preferred service date";
            _isConfirming = false;
          });
          Get.snackbar("Validation Error", "Please select a preferred service date",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900);
          return;
        }

        if (selectedPickupTimeSlot.trim().isEmpty) {
          setState(() {
            pickupDateTimeError = "Please select a preferred time slot";
            _isConfirming = false;
          });
          Get.snackbar("Validation Error", "Please select a preferred time slot",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900);
          return;
        }
      }

      if (selectedPaymentMethod.isEmpty) {
        setState(() {
          _isConfirming = false;
        });
        Get.snackbar("Validation Error", "Please select a payment method",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900);
        return;
      }

      if(profileDetails == null){
         await getProfile();
      }
      
      if(profileDetails == null){
          setState(() {
             _isConfirming = false;
          });
          Get.snackbar("Error", "Could not fetch user profile details");
          return;
      }

      double currentAmount = 0;
      for (var product in getHomeListModel!.data!) {
        if (product.spare != null) {
          currentAmount += double.tryParse(product.spare!.convertedPrice.toString()) ?? 0;
        }
      }
      if (selectedPaymentMethod == "UPI / Online Payment" || selectedPaymentMethod == "Net Banking / Card") {
        await successApi();
        // String orderId = await createOrder(currentAmount, "${profileDetails!.name}");
        // var options = {
        //   'key': 'rzp_live_KxQfs7AIuG7S7k',
        //   'amount': currentAmount * 100,
        //   'name': "${profileDetails!.name}",
        //   'order_id': orderId,
        //   'description': "Payment for order",
        //   'retry': {'enabled': true, 'max_count': 1},
        //   'send_sms_hash': true,
        //   'notes': {
        //     'type': "BUY",
        //     'number': profileDetails!.phone.toString(),
        //   },
        //   'prefill': {'contact': profileDetails!.phone.toString(), 'email': profileDetails!.email.toString()},
        //   'external': {
        //     'wallets': ['paytm']
        //   },
        //   'method': {
        //     'card': true,
        //     'upi': true,
        //     'netbanking': true
        //   }
        // };
        // razorpay.open(options);
      } else {
        await successApi();
      }


    } catch (e) {
      setState(() {
        _isConfirming = false;
      });

      Get.snackbar("Failed", "Error: ${e.toString()}");
    }
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response){
    setState(() {
      _isConfirming = false;
    });
    showAlertDialog1(context, "Payment Failed", "Cancel Payment");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response){
    successApi();
  }

  void handleExternalWalletSelected(ExternalWalletResponse response){
    showAlertDialog1(context, "External Wallet Selected", "${response.walletName}");
  }
  void showAlertDialog1(BuildContext context, String title, String message){
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Close"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> successApi() async {
    setState(() {
      _isConfirming = true;
    });
    _isConfirming = false;
    List<int> variantIds = [];
    double totalAmount = 0;

    for (var product in getHomeListModel!.data!) {
      if(product.spare != null){
        variantIds.add(product.spare!.id!.toInt());
        totalAmount += double.tryParse(product.spare!.convertedPrice.toString()) ?? 0;
      }
    }
    // ✅ 2. Service Type
    String serviceType = cartController.selectedType == 0 
        ? "Pick up" 
        : (cartController.selectedType == 2 ? "Door Step" : "Visit Store");

    // ✅ 4. Images (Multipart)
    List<String> imagePaths =
    cartController.uploadedImages.map((e) => e.path).toList();

    // ✅ 5. Prepare multipart request fields
    List<MultipartRequestService> multipartFields = [];

    // Add variant_id as comma-separated string
    String variantIdString = variantIds.join(',');
    multipartFields.add(MultipartRequestService(
      fieldName: "variant_id",
      fieldValue: variantIdString,
      isField: true,
      isFile: false,
    ));

    List<int> spareIds = [];
    List<int> categoryIds = [];
    List<int> brandIds = [];
    List<int> modelIds = [];
    for (var product in getHomeListModel!.data!) {
      if(product.spareId != null){
        spareIds.add(product.spareId!.toInt());
      }
      if(product.categoryId != null){
        categoryIds.add(product.categoryId!.toInt());
      }
      if(product.brandId != null){
        brandIds.add(product.brandId!.toInt());
      }
      if(product.modelId != null){
        modelIds.add(product.modelId!.toInt());
      }
    }
    String spareIdString = spareIds.join(',');
    multipartFields.add(MultipartRequestService(
      fieldName: "spare_id",
      fieldValue: spareIdString,
      isField: true,
      isFile: false,
    ));

    multipartFields.add(MultipartRequestService(
      fieldName: "category_id",
      fieldValue: categoryIds.join(','),
      isField: true,
      isFile: false,
    ));

    multipartFields.add(MultipartRequestService(
      fieldName: "brand_id",
      fieldValue: brandIds.join(','),
      isField: true,
      isFile: false,
    ));

    multipartFields.add(MultipartRequestService(
      fieldName: "model_id",
      fieldValue: modelIds.join(','),
      isField: true,
      isFile: false,
    ));

    // Add service_type
    multipartFields.add(MultipartRequestService(
      fieldName: "service_type",
      fieldValue: serviceType,
      isField: true,
      isFile: false,
    ));

    // Calculate Final Pickup Date
    String finalDate = "";
    if (selectedPickupDateIndex == 0) {
      finalDate = DateTime.now().toIso8601String().split('T')[0];
    } else if (selectedPickupDateIndex == 1) {
      finalDate = DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0];
    } else if (selectedPickupDateIndex == 2 && customPickupDate != null) {
      finalDate = customPickupDate!.toIso8601String().split('T')[0];
    }

    if (serviceType == "Pick up" || serviceType == "Door Step") {
      multipartFields.add(MultipartRequestService(
        fieldName: "pickup_date",
        fieldValue: finalDate,
        isField: true,
        isFile: false,
      ));
      multipartFields.add(MultipartRequestService(
        fieldName: "pickup_time",
        fieldValue: selectedPickupTimeSlot,
        isField: true,
        isFile: false,
      ));
    }

    // Add totalAmount
    multipartFields.add(MultipartRequestService(
      fieldName: "totalAmount",
      fieldValue: totalAmount.toString(),
      isField: true,
      isFile: false,
    ));

    // Add payment_method
    multipartFields.add(MultipartRequestService(
      fieldName: "payment_method",
      fieldValue: (selectedPaymentMethod == "UPI / Online Payment" || selectedPaymentMethod == "Net Banking / Card") ? "ONLINE" : "COD",
      isField: true,
      isFile: false,
    ));

    // Add payment_method
    // multipartFields.add(MultipartRequestService(
    //   fieldName: "payment_status",
    //   fieldValue: (selectedPaymentMethod == "UPI / Online Payment" || selectedPaymentMethod == "Net Banking / Card") ? "Paid" : "Not Paid",
    //   isField: true,
    //   isFile: false,
    // ));
    multipartFields.add(MultipartRequestService(
      fieldName: "payment_status",
      fieldValue: "Not Paid",
      isField: true,
      isFile: false,
    ));

    if (serviceType == "Pick up") {
      String pAdd = (pickDetailsFull != null && pickDetailsFull!['phone'] != null && pickDetailsFull!['phone'].toString().isNotEmpty) 
          ? "$pickAddress,${pickDetailsFull!['phone']}" 
          : pickAddress;
      String dAdd = (deliveryDetailsFull != null && deliveryDetailsFull!['phone'] != null && deliveryDetailsFull!['phone'].toString().isNotEmpty) 
          ? "$deliveryAddress,${deliveryDetailsFull!['phone']}" 
          : deliveryAddress;

      multipartFields.add(MultipartRequestService(
        fieldName: "pickup_address",
        fieldValue: pAdd,
        isField: true,
        isFile: false,
      ));
      multipartFields.add(MultipartRequestService(
        fieldName: "delivery_address",
        fieldValue: dAdd,
        isField: true,
        isFile: false,
      ));
      multipartFields.add(MultipartRequestService(
        fieldName: "pickup_type",
        fieldValue: pickDetailsFull != null ? (pickDetailsFull!['tag'] ?? "Home") : "Home",
        isField: true,
        isFile: false,
      ));
      multipartFields.add(MultipartRequestService(
        fieldName: "delivery_type",
        fieldValue: deliveryDetailsFull != null ? (deliveryDetailsFull!['tag'] ?? "Home") : "Home",
        isField: true,
        isFile: false,
      ));
      multipartFields.add(MultipartRequestService(
        fieldName: "pickup_map",
        fieldValue: pAdd,
        isField: true,
        isFile: false,
      ));
      multipartFields.add(MultipartRequestService(
        fieldName: "delivery_map",
        fieldValue: dAdd,
        isField: true,
        isFile: false,
      ));
      
      // Door data empty
      multipartFields.add(MultipartRequestService(fieldName: "door_location_address", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "door_type", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "door_location_map", fieldValue: "", isField: true, isFile: false));

    } else if (serviceType == "Door Step") {
      String dAdd = (deliveryDetailsFull != null && deliveryDetailsFull!['phone'] != null && deliveryDetailsFull!['phone'].toString().isNotEmpty) 
          ? "$deliveryAddress,${deliveryDetailsFull!['phone']}" 
          : deliveryAddress;

      multipartFields.add(MultipartRequestService(
        fieldName: "door_location_address",
        fieldValue: deliveryAddress,
        isField: true,
        isFile: false,
      ));
      multipartFields.add(MultipartRequestService(
        fieldName: "door_type",
        fieldValue: deliveryDetailsFull != null ? (deliveryDetailsFull!['tag'] ?? "Home") : "Home",
        isField: true,
        isFile: false,
      ));
      multipartFields.add(MultipartRequestService(
        fieldName: "door_location_map",
        fieldValue: dAdd,
        isField: true,
        isFile: false,
      ));

      // Pickup data empty
      multipartFields.add(MultipartRequestService(fieldName: "pickup_address", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "delivery_address", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "pickup_type", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "delivery_type", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "pickup_map", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "delivery_map", fieldValue: "", isField: true, isFile: false));
      
    } else {
      multipartFields.add(MultipartRequestService(
        fieldName: "store_id",
        fieldValue: cartController.selectedStoreIndex.toString(),
        isField: true,
        isFile: false,
      ));
      // Address fields empty for Store Visit
      multipartFields.add(MultipartRequestService(fieldName: "pickup_address", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "delivery_address", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "pickup_type", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "delivery_type", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "pickup_map", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "delivery_map", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "door_location_address", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "door_type", fieldValue: "", isField: true, isFile: false));
      multipartFields.add(MultipartRequestService(fieldName: "door_location_map", fieldValue: "", isField: true, isFile: false));
    }

    // Add image files
    for (String imagePath in imagePaths) {
      multipartFields.add(MultipartRequestService(
        fieldName: "image",
        fieldValue: imagePath,
        isField: false,
        isFile: true,
      ));
    }

    // ✅ 6. API CALL (WITH MULTIPART FORM DATA)
    final response = await ApiService.multipartRequest(
      uri: "/customer/order",
      method: "POST",
      multipartRequestFields: multipartFields,
      context: context,
      isAuthorized: true,
    );

    if (response != null && response != "failed") {
      if (response["message"] == "success") {
        setState(() {
          _isConfirming = false;
        });
        if(cartController.selectedType == 0){
          showBookingConfirmedDialog("1");
        } else{
          showBookingConfirmedDialog("2");
        }
        // Handle success - maybe navigate or refresh
      } else {
        setState(() {
          _isConfirming = false;
        });
        Get.snackbar("Failed", response["message"] ?? "Order confirmation failed");
      }
    } else {
      setState(() {
        _isConfirming = false;
      });
      Get.snackbar("Failed", "Order confirmation failed");
    }
  }

  Future<void> address() async {
    String deliveryAdd = await AuthHelper.getString("deliver_address") ?? "";
    String pickupAddress = await AuthHelper.getString("pickup_address") ?? "";

    if(deliveryAdd.isNotEmpty){
      setState(() {
        deliveryAddress = deliveryAdd;
      });
    }
    if(pickupAddress.isNotEmpty){
      setState(() {
        pickAddress = pickupAddress;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartController.clearImages();
    });
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    
    randomHeaderIndex = Random().nextInt(4) + 1;

    cartController.selectedType = -1;
    getCart(context);
    getNearStore(context);
    address();
    getProfile();
    _getUserLocation();
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(icon, color: Colors.green.shade600, size: 14.sp),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w800, color: Colors.black),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 7.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);  // triggers refresh in parent
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FAFF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.blue),
            onPressed: () => Navigator.pop(context, true),
          ),
          title: Text(
            "Service Summary",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body:  GetBuilder<CartController>(
          builder: (ctrl) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ✅ Top phone info banner (Redesigned)
                  if (parentName.isNotEmpty)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Stack(
                          children: [
                            // Background blue blob
                            Positioned(
                              right: -30.w,
                              bottom: 0,
                              top: 0,
                              child: Container(
                                width: 135.w,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.08),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(200.r),
                                    bottomLeft: Radius.circular(200.r),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Left side: Product Image
                                  Container(
                                    height: 155.h,
                                    width: 115.w,
                                    child: buildAppNetworkImage(
                                      imageUrl: image,
                                      fit: BoxFit.contain,
                                      errorWidget: (_, __, ___) => Image.asset(
                                        "assets/images/selectService/display option.png",
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  // Center side: Details
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 90.w), // Give space for the person
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            parentName,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            subName,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.blue.shade600,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(6.r),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.verified, color: Colors.blue.shade600, size: 12.sp),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  "Trusted by 50k+ Users",
                                                  style: TextStyle(
                                                    fontSize: 7.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          _buildInfoRow(Icons.verified_user_outlined, "Genuine Parts", "100% Genuine Parts"),
                                          SizedBox(height: 4.h),
                                          _buildInfoRow(Icons.manage_accounts_outlined, "Expert Techs", "Skilled & Verified"),
                                          SizedBox(height: 4.h),
                                          _buildInfoRow(Icons.thumb_up_alt_outlined, "Quality Assured", "Best Service."),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Right side: Person Image and Badge
                            Positioned(
                              right: 0,
                              bottom: 0,
                              top: 10.h,
                              child: Container(
                                width: 110.w,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Positioned(
                                      bottom: 35.h,
                                      right: -35.w,
                                      child: Image.asset(
                                        "assets/cart_header/00$randomHeaderIndex.png",
                                        height: 140.h,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 12.h,
                                      child: Container(
                                        width: 105.w,
                                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.verified, color: Colors.blue.shade600, size: 16.sp),
                                            SizedBox(width: 4.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Assigned Expert",
                                                    style: TextStyle(fontSize: 7.sp, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                                                  ),
                                                  Text(
                                                    "12+ Yrs Exp.",
                                                    style: TextStyle(fontSize: 7.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 16.h),
      
                  /// ✅ Selected Service
                  Row(
                    children: [
                      Container(
                        height: 16.h,
                        width: 4.w,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Selected Service",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
      
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (getHomeListModel == null || getHomeListModel!.data!.isEmpty)
                    const Center(child: Text("Cart is Empty"))
                  else
                    ...?getHomeListModel!.data?.map((product) {
                      return product.spare != null?Container(
                        height: 100,
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade100, width: 1),
                        ),
                        child: Row(
                          children: [
                            /// ✅ Dynamic Image
                            Container(
                              height: 65.h,
                              width: 65.w,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: buildAppNetworkImage(
                                  imageUrl: product.spare?.image ?? '',
                                  fit: BoxFit.contain,
                                  errorWidget: (_, __, ___) => Image.asset(
                                    "assets/images/selectService/display.png",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
      
                            SizedBox(width: 12.w),
      
                            /// ✅ Dynamic Title & Badge
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    product.spare!.variantSlug ?? "No Name",
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified, color: Colors.green, size: 10.sp),
                                        SizedBox(width: 4.w),
                                        Text(
                                          "Original Quality",
                                          style: TextStyle(
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(width: 8.w),
                            
                            /// Vertical Divider
                            Container(
                              height: 40.h,
                              width: 1,
                              color: Colors.grey.shade200,
                            ),
                            
                            SizedBox(width: 12.w),
                            
                            /// Price
                            if (product.spare!.price != null && product.spare!.price != "0" && product.spare!.price != "0.00")
                              Text(
                                "₹ ${product.spare!.price}",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              
                            SizedBox(width: 12.w),
      
                            GestureDetector(
                              onTap: () async {
                                bool result = await deleteCart(context, product.spare!.id.toString());
                                if (result) {
                                  getHomeListModel!.data!.remove(product);
                                  cartController.clearImages();
                                  setState(() {});
                                } else {
                                  print("Delete failed");
                                }
                              },
                              child: Container(
                                height: 28.h,
                                width: 28.w,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.red.shade400,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ):SizedBox();
                    }).toList(),
      
                  //in this place add image option
      
                  SizedBox(height: 12.h),
                  Text(
                    "Add Image of the Mobile",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
      
                  GestureDetector(
                    onTap: () async {
                      Get.bottomSheet(
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.r),
                              topRight: Radius.circular(20.r),
                            ),
                          ),
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 40.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                "Select Option",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              InkWell(
                                onTap: () {
                                  controller.pickImages(multiple: true);
                                  Get.back();
                                },
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.w),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        child: Icon(
                                          Icons.image_outlined,
                                          color: Colors.white,
                                          size: 22.sp,
                                        ),
                                      ),
                                      SizedBox(width: 14.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Pick Multiple Images",
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              "Select multiple photos at once",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16.sp,
                                        color: Colors.grey.shade400,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              InkWell(
                                onTap: () {
                                  controller.pickImages(multiple: false);
                                  Get.back();
                                },
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.w),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        child: Icon(
                                          Icons.photo_library_outlined,
                                          color: Colors.white,
                                          size: 22.sp,
                                        ),
                                      ),
                                      SizedBox(width: 14.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Pick Single Image",
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              "Select one photo only",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16.sp,
                                        color: Colors.grey.shade400,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                            ],
                          ),
                        ),
                        isScrollControlled: true,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: controller.uploadedImages.isNotEmpty
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: controller.uploadedImages.isNotEmpty
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  color: Colors.blue,
                                  size: 18.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  "Mobile Images",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  "${controller.uploadedImages.length} added",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            height: 70.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.uploadedImages.length + 1,
                              separatorBuilder: (_, __) => SizedBox(width: 8.w),
                              itemBuilder: (context, index) {
                                if (index == controller.uploadedImages.length) {
                                  return GestureDetector(
                                    onTap: () async {
                                      Get.bottomSheet(
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20.r),
                                              topRight: Radius.circular(20.r),
                                            ),
                                          ),
                                          padding: EdgeInsets.all(20.w),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Container(
                                                  width: 40.w,
                                                  height: 4.h,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius: BorderRadius.circular(2.r),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 16.h),
                                              Text("Select Option", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
                                              SizedBox(height: 16.h),
                                              InkWell(
                                                onTap: () {
                                                  controller.pickImages(multiple: true);
                                                  Get.back();
                                                },
                                                borderRadius: BorderRadius.circular(12.r),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.withOpacity(0.08),
                                                    borderRadius: BorderRadius.circular(12.r),
                                                    border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.all(10.w),
                                                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10.r)),
                                                        child: Icon(Icons.image_outlined, color: Colors.white, size: 22.sp),
                                                      ),
                                                      SizedBox(width: 14.w),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("Pick Multiple Images", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                                                            SizedBox(height: 2.h),
                                                            Text("Select multiple photos at once", style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                                                          ],
                                                        ),
                                                      ),
                                                      Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey.shade400),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 12.h),
                                              InkWell(
                                                onTap: () {
                                                  controller.pickImages(multiple: false);
                                                  Get.back();
                                                },
                                                borderRadius: BorderRadius.circular(12.r),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.withOpacity(0.08),
                                                    borderRadius: BorderRadius.circular(12.r),
                                                    border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.all(10.w),
                                                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10.r)),
                                                        child: Icon(Icons.photo_library_outlined, color: Colors.white, size: 22.sp),
                                                      ),
                                                      SizedBox(width: 14.w),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("Pick Single Image", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                                                            SizedBox(height: 2.h),
                                                            Text("Select one photo only", style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                                                          ],
                                                        ),
                                                      ),
                                                      Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey.shade400),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8.h),
                                            ],
                                          ),
                                        ),
                                        isScrollControlled: true,
                                      );
                                    },
                                    child: Container(
                                      width: 70.h,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.3),
                                          width: 1.5,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add, color: Colors.blue, size: 24.sp),
                                          SizedBox(height: 2.h),
                                          Text(
                                            "Add More",
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10.r),
                                        child: Image.file(
                                          controller.uploadedImages[index],
                                          height: 70.h,
                                          width: 70.h,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => controller.removeImage(index),
                                        child: Container(
                                          height: 22.h,
                                          width: 22.h,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(Icons.close, color: Colors.white, size: 14.sp),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      )
                          : Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.add_a_photo_outlined,
                              color: Colors.blue,
                              size: 22.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Add Image of the mobile",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  "Tap to upload photos",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
      
      
                  SizedBox(height: 12.h),
                  Text(
                    "Choose Service Mode",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (serviceTypeError != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      serviceTypeError!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  SizedBox(height: 10.h),
      
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      serviceTypeButton(
                        ctrl,
                        icon: Icons.storefront,
                        label: "Visit Store",
                        badgeText: "Most Popular",
                        subtitle: "Bring your device to\nour service center",
                        baseColor: Colors.blue,
                        isSelected: ctrl.selectedType == 1,
                        onTap: () {
                          ctrl.selectServiceType(1);
                          ctrl.selectStore(0);
                          setState(() {
                            serviceTypeError = null;
                            storeSelectionError = null;
                          });
                        },
                      ),
                      SizedBox(width: 8.w),
                      serviceTypeButton(
                        ctrl,
                        icon: Icons.local_shipping,
                        label: "Pickup & Delivery",
                        badgeText: "Convenient",
                        subtitle: "We collect and return\nyour device",
                        baseColor: Colors.green,
                        isSelected: ctrl.selectedType == 0,
                        onTap: () {
                          ctrl.selectServiceType(0);
                          setState(() {
                            serviceTypeError = null;
                            pickAddressError = null;
                            deliveryAddressError = null;
                            pickupDateTimeError = null;
                          });
                        },
                      ),
                      SizedBox(width: 8.w),
                      serviceTypeButton(
                        ctrl,
                        icon: Icons.engineering,
                        label: "Onsite Service",
                        badgeText: "Premium",
                        subtitle: "Technician visits\nyour location",
                        baseColor: Colors.orange.shade700,
                        isSelected: ctrl.selectedType == 2,
                        onTap: () {
                          ctrl.selectServiceType(2);
                          setState(() {
                            serviceTypeError = null;
                            deliveryAddressError = null;
                            pickupDateTimeError = null;
                            isDeliverySameAsPickup = false;
                            deliveryAddress = "";
                            deliveryDetailsFull = null;
                            AuthHelper.setString("deliver_address", "");
                          });
                        },
                      ),
                    ],
                  ),
      
                  SizedBox(height: 16.h),
      
                  if (ctrl.selectedType == 0 || ctrl.selectedType == 2)
                    buildPickupDeliverySection(ctrl)
                  else if (ctrl.selectedType == 1)
                    buildStoreSelection(ctrl),
                  SizedBox(height: 10.h),
                  buildPaymentSection(),
                  SizedBox(height: 20.h),
                  GetBuilder<CartController>(
                    builder: (ctrl) {
                      return SafeArea(
                        top: false,
                        child: Material(
                          color: _isConfirming
                              ? AppColors.primary.withOpacity(0.6)
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(12.r),
                          elevation: _isConfirming ? 0 : 4,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                          child: InkWell(
                            onTap: _isConfirming ? null : () {
                              confirmBookingApi(ctrl);
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              height: 58.h,
                              alignment: Alignment.center,
                              child: _isConfirming
                                  ? SizedBox(
                                      height: 24.h,
                                      width: 24.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.lock, color: Colors.white, size: 16.sp),
                                            SizedBox(width: 6.w),
                                            Text(
                                              "Confirm & Book Service",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          "Review and confirm your service details",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            );
          },
        ),

      ),
    );
  }

  Widget serviceTypeButton(
      CartController ctrl, {
        required IconData icon,
        required String label,
        required String badgeText,
        required String subtitle,
        required Color baseColor,
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 2.w),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    Icon(icon, color: baseColor, size: 28.sp),
                    SizedBox(height: 8.h),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                          color: baseColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
               ),
              ),
              if (isSelected)
                Positioned(
                  right: 6.w,
                  top: 6.h,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 16.sp,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPickupDeliverySection(CartController ctrl) {
    bool isDoorStep = ctrl.selectedType == 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDoorStep) ...[
          Text(
            "Pick up Location",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          locationTile(
            pickAddress, 
            "Select on map",
            onTap: (){openPickAddressScreen();},
            hasError: pickAddressError != null,
          ),
          if (pickAddressError != null) ...[
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: Text(
                pickAddressError!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Row(
            children: [
              Checkbox(
                value: isDeliverySameAsPickup,
                activeColor: Colors.blue,
                onChanged: (bool? value) {
                  setState(() {
                    isDeliverySameAsPickup = value ?? false;
                    if (isDeliverySameAsPickup && pickAddress.isNotEmpty) {
                      deliveryAddress = pickAddress;
                      deliveryDetailsFull = pickDetailsFull;
                      deliveryAddressError = null;
                      AuthHelper.setString("deliver_address", deliveryAddress);
                    } else if (!isDeliverySameAsPickup) {
                      deliveryAddress = "";
                      deliveryDetailsFull = null;
                      AuthHelper.setString("deliver_address", "");
                    }
                  });
                },
              ),
              Text(
                "If delivery Location also same",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],
        Text(
          isDoorStep ? "Customer Service Location" : "Delivery Location",
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        locationTile(
          deliveryAddress, 
          "Select on map",
          onTap: (){openDeliveryAddressScreen();},
          hasError: deliveryAddressError != null,
        ),
        if (deliveryAddressError != null) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Text(
              deliveryAddressError!,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        SizedBox(height: 20.h),
        buildPickupDeliveryDetailsSection(ctrl),
      ],
    );
  }

  Widget buildPickupDeliveryDetailsSection(CartController ctrl) {
    bool isDoorStep = ctrl.selectedType == 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isDoorStep ? "Onsite Service Details" : "Pickup & Delivery Details",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          isDoorStep ? "Preferred Service Date" : "Preferred Pickup Date",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            _buildDateChip("Today", 0),
            SizedBox(width: 8.w),
            _buildDateChip("Tomorrow", 1),
            SizedBox(width: 8.w),
            _buildDateChip(
              customPickupDate != null 
                ? "${customPickupDate!.day}/${customPickupDate!.month}/${customPickupDate!.year} 📅" 
                : "Select Date 📅", 
              2
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Text(
          "Preferred Time Slot",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(child: _buildTimeSlotChip("9 AM - 12 PM")),
            SizedBox(width: 6.w),
            Expanded(child: _buildTimeSlotChip("12 PM - 3 PM")),
            SizedBox(width: 6.w),
            Expanded(child: _buildTimeSlotChip("3 PM - 6 PM")),
            SizedBox(width: 6.w),
            Expanded(child: _buildTimeSlotChip("6 PM - 9 PM")),
          ],
        ),
        if (pickupDateTimeError != null) ...[
          SizedBox(height: 8.h),
          Text(
            pickupDateTimeError!,
            style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.w500),
          ),
        ],
        SizedBox(height: 20.h),
        Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.show_chart, color: Colors.green, size: 20.sp),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isDoorStep ? "Onsite Service Charges" : "Pickup & Delivery Charges", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                        SizedBox(height: 2.h),
                        Text("Applicable for this service", style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Text("₹ ${getHomeListModel?.deliveryCharge?.toInt() ?? 99}", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_outline, color: Colors.blue, size: 20.sp),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isDoorStep ? "Service Technician" : "Pickup Executive", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                        SizedBox(height: 2.h),
                        Text("Will be assigned after booking confirmation", style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.blue.shade100)
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.blue, size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  isDoorStep
                      ? "Our expert technician will visit your service location at the scheduled date and time."
                      : "We will collect your device from the above address and return after service completion.",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateChip(String label, int index) {
    bool isSelected = selectedPickupDateIndex == index;
    return GestureDetector(
      onTap: () async {
        if (index == 2) {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: customPickupDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.blue, // header background color
                    onPrimary: Colors.white, // header text color
                    onSurface: Colors.black87, // body text color
                  ),
                  datePickerTheme: DatePickerThemeData(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() {
              selectedPickupDateIndex = index;
              customPickupDate = picked;
              pickupDateTimeError = null;
            });
          }
        } else {
          setState(() {
            selectedPickupDateIndex = index;
            pickupDateTimeError = null;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotChip(String label) {
    bool isSelected = selectedPickupTimeSlot == label;
    // For smaller screens, split "9 AM - 12 PM" to "9 AM\n12 PM" if needed
    String shortLabel = label.replaceFirst(' - ', '\n');
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPickupTimeSlot = label;
          pickupDateTimeError = null; // Clear error
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          shortLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  void openPickAddressScreen() async {
    final result = await Get.to(() => SelectAddressScreen(type: "pick",));

    if (result != null) {
      double lat = result['lat'];
      double lng = result['lng'];
      String address = result['address'];
      String tag = result['tag'];

      setState(() {
        pickAddress = address;
        pickDetailsFull = result;
        pickAddressError = null; // Clear error when address is selected
        if (isDeliverySameAsPickup) {
          deliveryAddress = address;
          deliveryDetailsFull = result;
          deliveryAddressError = null;
        }
      });
      await AuthHelper.setString("pickup_address",pickAddress);
      if (isDeliverySameAsPickup) {
        await AuthHelper.setString("deliver_address",deliveryAddress);
      }
      // You can now use these values, e.g., set state, update text fields, or save to API
    }
  }

  void openDeliveryAddressScreen() async {
    final result = await Get.to(() => SelectAddressScreen(type: "delivery",));

    if (result != null) {
      double lat = result['lat'];
      double lng = result['lng'];
      String address = result['address'];
      String tag = result['tag'];
      setState(() {
         deliveryAddress = address;
         deliveryDetailsFull = result;
         deliveryAddressError = null; // Clear error when address is selected
      });
      await AuthHelper.setString("deliver_address",deliveryAddress);

      // You can now use these values, e.g., set state, update text fields, or save to API
    }
  }

  String _extractCity(dynamic loc) {
    if (loc.city != null && loc.city.toString().isNotEmpty) return loc.city.toString().trim();
    String addr = loc.address?.toString().toLowerCase() ?? "";
    if (addr.contains("chennai")) return "Chennai";
    if (addr.contains("coimbatore")) return "Coimbatore";
    if (addr.contains("madurai")) return "Madurai";
    if (addr.contains("trichy") || addr.contains("tiruchirappalli")) return "Trichy";
    if (addr.contains("salem")) return "Salem";
    if (addr.contains("erode")) return "Erode";
    if (addr.contains("tirunelveli")) return "Tirunelveli";
    if (addr.contains("vellore")) return "Vellore";
    return "Other";
  }

  Widget buildStoreSelection(CartController ctrl) {
    bool showStores = ctrl.selectedType == 1 && 
        getNearByStoreResponseModel != null && 
        getNearByStoreResponseModel!.data != null && 
        getNearByStoreResponseModel!.data!.isNotEmpty;

    if (!showStores) return const SizedBox();

    List<String> cities = [];
    Map<String, List<dynamic>> cityStores = {};

    for (var loc in getNearByStoreResponseModel!.data!) {
      String c = _extractCity(loc);
      if (!cityStores.containsKey(c)) {
        cityStores[c] = [];
        cities.add(c);
      }
      cityStores[c]!.add(loc);
    }

    String currentFilter = selectedCityFilter ?? (cities.isNotEmpty ? cities.first : "");
    List<dynamic> filteredStores = cityStores[currentFilter] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select City",
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        // City Filter Row
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cities.length,
            itemBuilder: (context, index) {
              String city = cities[index];
              bool isSelected = city == currentFilter;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCityFilter = city;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white,
                    border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    city,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          "Select Branch in $currentFilter (${filteredStores.length} Branches)",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (storeSelectionError != null) ...[
          SizedBox(height: 4.h),
          Text(
            storeSelectionError!,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        SizedBox(height: 12.h),
        SizedBox(
          height: 230.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredStores.length,
            itemBuilder: (context, index) {
              var location = filteredStores[index];
              int locId = int.parse(location.id.toString());
              bool isSelected = ctrl.selectedStoreIndex == locId;

              return Stack(
                children: [
                  InkWell(
                    onTap: () {
                      ctrl.selectStore(isSelected ? 0 : locId);
                      setState(() {
                        storeSelectionError = null;
                      });
                    },
                    child: StoreCard(
                      title: location.title ?? "",
                      city: null, 
                      address: location.address ?? "",
                      timing: location.timing ?? "",
                      phone: location.phone,
                      mapUrl: location.map,
                      isSelected: isSelected,
                    ),
                  ),
                  Positioned(
                    top: 12.h,
                    right: 24.w, 
                    child: InkWell(
                      onTap: () {
                        ctrl.selectStore(isSelected ? 0 : locId);
                        setState(() {
                          storeSelectionError = null;
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildPaymentSection() {
    List<Map<String, dynamic>> paymentOptions = [
      {
        "title": "Cash on Delivery",
        "subtitle": "Pay after service\ncompletion",
        "icon": Icons.money,
        "color": Colors.green,
      },
      {
        "title": "UPI / Online Payment",
        "subtitle": "GPay, PhonePe,\nPaytm & more",
        "icon": Icons.play_arrow_rounded,
        "color": Colors.purple,
      },
      {
        "title": "Net Banking / Card",
        "subtitle": "All major banks\nsupported",
        "icon": Icons.account_balance,
        "color": Colors.grey.shade600,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Payment Method",
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 76.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: paymentOptions.length,
            itemBuilder: (context, index) {
              var option = paymentOptions[index];
              bool isSelected = selectedPaymentMethod == option["title"];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedPaymentMethod == option["title"]) {
                      selectedPaymentMethod = ""; // Unselect if already selected
                    } else {
                      selectedPaymentMethod = option["title"];
                    }
                  });
                },
                child: Container(
                  width: 225.w,
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade200,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: option["color"].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              option["icon"],
                              color: option["color"],
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option["title"],
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  option["subtitle"],
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, color: Colors.green, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              "100% Secure Payments. Your data is safe with us.",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 🔹 Reusable Static Point Widget
  Widget _staticPoint(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14.sp, color: Colors.blue),
          SizedBox(height: 2.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// 🔹 Reusable Location Tile
  Widget locationTile(String title, String subtitle, {VoidCallback ?onTap, bool hasError = false}) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: hasError ? Colors.red : Colors.transparent,
          width: hasError ? 1.5 : 0,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined, 
            color: hasError ? Colors.red : Colors.blue, 
            size: 20.sp
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp, 
                    fontWeight: FontWeight.w600,
                    color: hasError ? Colors.red : Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: hasError ? Colors.red.shade700 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit, 
              color: hasError ? Colors.red : Colors.blue, 
              size: 18.sp,
            ),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class PaymentDropdown extends StatefulWidget {
  final String selectedMethod;
  final ValueChanged<String> onSelected;
  const PaymentDropdown({Key? key, required this.selectedMethod, required this.onSelected}) : super(key: key);

  @override
  State<PaymentDropdown> createState() => _PaymentDropdownState();
}

class _PaymentDropdownState extends State<PaymentDropdown> {
  bool isExpanded = false;
  
  final List<String> paymentMethods = [
    "Cash On Delivery",
    "Online Payment",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main container (clickable)
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Color(0x1A000000),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Payment Method",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      widget.selectedMethod,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Dropdown list (expand when tapped)
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: isExpanded ? paymentMethods.length * 45.0 : 0,
          curve: Curves.easeInOut,
          child: Container(
            margin: EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Color(0x1A000000),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                return InkWell(
                  onTap: () {
                    widget.onSelected(method);
                    setState(() {
                      isExpanded = false;
                    });
                  },
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(method,
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black)),
                        if (method == widget.selectedMethod)
                          Icon(Icons.check, color: Colors.green, size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
