import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../ApiService/ApiService.dart';
import '../../models/app/getHistoryResponseModel.dart';
import '../../models/app/getProfileResponseModel.dart';
import 'History_Controller/service_history_controller.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {

  bool _isLoading = true;
  GetHistoryResponseModel? getHistoryResponseModel;
  GetProfileResponseModel? profileDetails;
  late Razorpay razorpay;
  bool _isPaying = false;
  Data? currentPayingOrder; // To keep track of the order being paid

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
        'amount': (amount * 100).toInt(), // in paise
        'currency': 'INR',
        'receipt': 'receipt_${name}_${DateTime.now().millisecondsSinceEpoch}',
        'payment_capture': 1
      }),
    );

    var data = jsonDecode(response.body);
    return data['id']; // This is the order_id
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response){
    setState(() {
      _isPaying = false;
      currentPayingOrder = null;
    });
    
    String errorMessage = response.message ?? "Transaction Cancelled . Try to Pay Again ! ";
    if (errorMessage.toLowerCase() == "undefined") {
      errorMessage = "Transaction Cancelled . Try to Pay Again ! ";
    }
    
    showAlertDialog1(context, "Payment Failed", errorMessage);
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response){
    // Here we should call the update API
    updatePaymentStatus(
      response.paymentId ?? "",
      response.orderId ?? "",
      response.signature ?? "",
    );
  }

  void handleExternalWalletSelected(ExternalWalletResponse response){
    showAlertDialog1(context, "External Wallet Selected", "${response.walletName}");
  }

  void showAlertDialog1(BuildContext context, String title, String message){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isError = title.toLowerCase().contains("failed") || title.toLowerCase().contains("error");
        
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isError ? Colors.red.shade50 : Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isError ? Icons.cancel_outlined : Icons.info_outline,
                    color: isError ? Colors.red : Colors.blue,
                    size: 40.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isError ? Colors.red : const Color(0xFF1E88E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Close",
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
        );
      },
    );
  }

  Future<void> payNow(Data order) async {
    if (_isPaying) return;

    setState(() {
      _isPaying = true;
      currentPayingOrder = order;
    });

    try {
      if (profileDetails == null) {
        await getProfile();
      }

      if (profileDetails == null) {
        setState(() => _isPaying = false);
        Get.snackbar("Error", "Could not fetch user profile details");
        return;
      }

      double amount = double.tryParse(order.totalAmount ?? "0") ?? 0;
      
      if (amount <= 0) {
        setState(() => _isPaying = false);
        Get.snackbar("Error", "Invalid order amount");
        return;
      }

      String rzpOrderId = await createOrder(amount, profileDetails!.name ?? "Customer");
      // updatePaymentStatus(
      //   "awlkwod" ?? "",
      //   rzpOrderId ?? "",
      //   "skjoswd" ?? "",
      // );
      var options = {
        'key': 'rzp_live_KxQfs7AIuG7S7k',
        'amount': (amount * 100).toInt(),
        'name': "The Cellphone Doctor",
        'order_id': rzpOrderId,
        'description': "Payment for order #${order.id}",
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
        'prefill': {
          'contact': profileDetails!.phone.toString(),
          'email': profileDetails!.email.toString()
        },
        'external': {
          'wallets': ['paytm']
        }
      };
      razorpay.open(options);
    } catch (e) {
      setState(() => _isPaying = false);
      Get.snackbar("Error", "Payment initialization failed: ${e.toString()}");
    }
  }

  Future<void> updatePaymentStatus(String paymentId, String rzpOrderId, String signature) async {
    if (currentPayingOrder == null) return;

    try {
      Map<String, dynamic> body = {
        "orderId": currentPayingOrder!.id.toString(),
        "razorpay_payment_id": paymentId,
        "razorpay_order_id": rzpOrderId,
        "razorpay_signature": signature,
      };
      print("body${body}");
      final response = await ApiService.postData(
        uri: "/customer/paymentStatus",
        requestData: jsonEncode(body),
        isAuthorized: true,
        context: context,
      );

      // {ordeId: 5, razorpay_payment_id: pay_SbsZINjk8EiVTR, razorpay_order_id: order_SbsYWp4ULbjzLn, razorpay_signature: 8384e145dca71243fc5ba77e9dc4a3f2964075f73755f842dce8519b1564ad85}
      print("response${response}");

      if (response != null && response != "failed") {
        Get.snackbar("Success", "Payment successful and updated");
        getHistory(context); // Refresh list
      } else {
        Get.snackbar("Attention", "Payment was successful but we couldn't update the status. Please contact support.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update payment status");
    } finally {
      setState(() {
        _isPaying = false;
        currentPayingOrder = null;
      });
    }
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 2));
    getHistory(context);
    print("Page refreshed");
  }

  getHistory(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Fetching order history...');
      final successResult = await ApiService.getData(
        uri: "/customer/order",
        isAuthorized: true,
        context: context,
      );
      
      print('API Response Type: ${successResult.runtimeType}');
      print('API Response: $successResult');
      
      if (successResult != null) {
        try {
          // Check if successResult is already a Map or needs to be decoded
          final responseData = successResult is Map ? successResult : null;

          if (responseData == null) {
            print('Error: Unexpected response format. Expected Map but got ${successResult.runtimeType}');
            setState(() => _isLoading = false);
            return;
          }
          
          print('Response data type: ${responseData.runtimeType}');
          print('Response keys: ${responseData.keys}');
          
          // Create the model from the response
          final historyModel = GetHistoryResponseModel.fromJson(responseData);
          
          setState(() {
            getHistoryResponseModel = historyModel;
            print('Successfully parsed history data. Has data: ${historyModel.data?.isNotEmpty ?? false}');
            print('GLOBAL DELIVERY CHARGE: ${historyModel.deliveryCharge}');
            if (historyModel.data != null && historyModel.data!.isNotEmpty) {
               print('FIRST ORDER DELIVERY CHARGE: ${historyModel.data!.first.deliveryCharge}');
            }
            _isLoading = false;
          });
        } catch (e) {
          print('Error parsing response: $e');
          print('Stack trace: ${e.toString()}');
          setState(() => _isLoading = false);
          // Show error to user if needed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading order history: ${e.toString()}')),
          );
        }
      } else {
        print('API returned null response');
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data received from server')),
        );
      }
    } catch (e) {
      print('Error in getHistory: $e');
      print('Stack trace: ${e.toString()}');
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load order history: ${e.toString()}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getHistory(context);
      getProfile();
    });
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceHistoryController>(
      init: ServiceHistoryController(),
      builder: (controller) {
        return Scaffold(
          // bottomNavigationBar: Padding(
          //   padding:  EdgeInsets.all(18.r),
          //   child: Container(
          //     padding: EdgeInsets.all(16.w),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(10.r),
          //       boxShadow: [
          //         BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
          //       ],
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(
          //           "Payment Method",
          //           style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
          //         ),
          //         Text(
          //           "Cash On Delivery",
          //           style: TextStyle(
          //             fontWeight: FontWeight.w700,
          //             fontSize: 14.sp,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          backgroundColor: const Color(0xFFF8FBFF),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Service History",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _refresh,
                child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FC),
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        child: Builder(
                          builder: (context) {
                            final data = getHistoryResponseModel?.data ?? [];
                            
                            final orderCount = data.where((o) => o.status?.toLowerCase() == "new order" || o.status?.toLowerCase() == "accept" || o.status?.toLowerCase() == "pick up").length;
                            final inProgressCount = data.where((o) => o.status?.toLowerCase() == "in processing" || o.status?.toLowerCase() == "dispatch").length;
                            final completedCount = data.where((o) => o.status?.toLowerCase() == "completed").length;
                            final cancelledCount = data.where((o) => o.status?.toLowerCase() == "cancel" || o.status?.toLowerCase() == "cancelled").length;

                            String formatCount(int count) => count.toString().padLeft(2, '0');

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                tabButton("Orders\n(${formatCount(orderCount)})", 0, controller),
                                tabButton("InProgress\n(${formatCount(inProgressCount)})",  1, controller),
                                tabButton("Completed\n(${formatCount(completedCount)})", 2, controller),
                                tabButton("Cancelled\n(${formatCount(cancelledCount)})", 3, controller),
                              ],
                            );
                          }
                        ),
                      ),
                
                      Expanded(child: buildTabView(controller.selectedTab)),
                    ],
                  ),
              ),
        );
      },
    );
  }

  Widget tabButton(
    String text,
    int index,
    ServiceHistoryController controller,
  ) {
    bool active = controller.selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.switchTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 40.h,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1E88E5) : Colors.transparent,
            borderRadius: BorderRadius.circular(40.r),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : Colors.black,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTabView(int tabIndex) {
    print("getHistoryResponseModel$getHistoryResponseModel");
    int? currentId = currentPayingOrder?.id?.toInt();
    if (tabIndex == 0) return PickUpTab(historyData: getHistoryResponseModel, onPayNow: payNow, isPaying: _isPaying, currentPayingOrderId: currentId);
    if (tabIndex == 1) return InProgressTab(historyData: getHistoryResponseModel, onPayNow: payNow, isPaying: _isPaying, currentPayingOrderId: currentId);
    if (tabIndex == 2) return CompletedTab(historyData: getHistoryResponseModel, onPayNow: payNow, isPaying: _isPaying, currentPayingOrderId: currentId);
    return CancelledTab(historyData: getHistoryResponseModel, onPayNow: payNow, isPaying: _isPaying, currentPayingOrderId: currentId);
  }
}

class PickUpTab extends StatefulWidget {
  final GetHistoryResponseModel? historyData;
  final Function(Data) onPayNow;
  final bool isPaying;
  final int? currentPayingOrderId;
  const PickUpTab({super.key, this.historyData, required this.onPayNow, required this.isPaying, this.currentPayingOrderId});

  @override
  State<PickUpTab> createState() => _PickUpTabState();
}

class _PickUpTabState extends State<PickUpTab> {
  List<Data> get filteredOrders {
    print("filteredOrders${widget.historyData?.data}");
    if (widget.historyData?.data == null) return [];
    return widget.historyData!.data!
        .where((order) => order.status?.toLowerCase() == "new order" || order.status?.toLowerCase() == "accept" || order.status?.toLowerCase() == "pick up")
        .toList();

  }


  @override
  Widget build(BuildContext context) {
    print("filteredOrders$filteredOrders");
    if (filteredOrders.isEmpty) {
      return Center(
        child: Text(
          "No New orders found",
          style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      children: filteredOrders.map((order) {
        return Padding(
          padding: EdgeInsets.only(bottom: 5.h),
          child: PickUpServiceCard(
            orderId: order.id?.toString() ?? "",
            order: order,
            onPayNow: widget.onPayNow,
            isPaying: widget.isPaying,
            isCurrentPaying: widget.currentPayingOrderId == order.id,
          ),
        );
      }).toList(),
    );
  }
}

class InProgressTab extends StatelessWidget {
  final GetHistoryResponseModel? historyData;
  final Function(Data) onPayNow;
  final bool isPaying;
  final int? currentPayingOrderId;
  const InProgressTab({super.key, this.historyData, required this.onPayNow, required this.isPaying, this.currentPayingOrderId});

  List<Data> get filteredOrders {
    if (historyData?.data == null) return [];
    return historyData!.data!
        .where((order) => order.status?.toLowerCase() == "in processing" || order.status?.toLowerCase() == "dispatch")
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (filteredOrders.isEmpty) {
      return Center(
        child: Text(
          "No New orders found",
          style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      children: filteredOrders.map((order) {
        return Padding(
          padding: EdgeInsets.only(bottom: 5.h),
          child: PickUpServiceCard(
            orderId: order.id?.toString() ?? "",
            order: order,
            onPayNow: onPayNow,
            isPaying: isPaying,
            isCurrentPaying: currentPayingOrderId == order.id,
          ),
        );
      }).toList(),
    );
  }
}

class CompletedTab extends StatelessWidget {
  final GetHistoryResponseModel? historyData;
  final Function(Data) onPayNow;
  final bool isPaying;
  final int? currentPayingOrderId;
  const CompletedTab({super.key, this.historyData, required this.onPayNow, required this.isPaying, this.currentPayingOrderId});

  List<Data> get filteredOrders {
    if (historyData?.data == null) return [];
    return historyData!.data!
        .where((order) => order.status?.toLowerCase() == "completed")
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (filteredOrders.isEmpty) {
      return Center(
        child: Text(
          "No New orders found",
          style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      children: filteredOrders.map((order) {
        return CompactServiceCard(
          orderId: order.id?.toString() ?? "",
          order: order,
          onPayNow: onPayNow,
          isPaying: isPaying,
          isCurrentPaying: currentPayingOrderId == order.id,
        );
      }).toList(),
    );
  }
}

class CancelledTab extends StatelessWidget {
  final GetHistoryResponseModel? historyData;
  final Function(Data) onPayNow;
  final bool isPaying;
  final int? currentPayingOrderId;
  const CancelledTab({super.key, this.historyData, required this.onPayNow, required this.isPaying, this.currentPayingOrderId});

  List<Data> get filteredOrders {
    if (historyData?.data == null) return [];
    return historyData!.data!
        .where((order) => 
            order.status?.toLowerCase() == "cancel" ||
            order.status?.toLowerCase() == "cancelled")
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (filteredOrders.isEmpty) {
      return Center(
        child: Text(
          "No New orders found",
          style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      children: filteredOrders.map((order) {
        return CompactServiceCard(
          orderId: order.id?.toString() ?? "",
          order: order,
          onPayNow: onPayNow,
          isPaying: isPaying,
          isCurrentPaying: currentPayingOrderId == order.id,
        );
      }).toList(),
    );
  }
}

class CompactServiceCard extends StatelessWidget {
  final String? orderId;
  final Data? order;
  final Function(Data) onPayNow;
  final bool isPaying;
  final bool isCurrentPaying;

  const CompactServiceCard({
    super.key,required this.orderId,this.order, required this.onPayNow, required this.isPaying, this.isCurrentPaying = false
  });

  String get productName {
    if (order?.productName == null) return "Service";
    return order?.productName ?? "Service";
  }

  String get brandName {
    if (order?.serviceType == null) return "";
    // Extract brand from variant slug or use service type
    return order?.serviceType ?? "";
  }

  String get formattedPrice {
    if (order?.totalAmount == null) return "₹0";
    double? amount = double.tryParse(order?.totalAmount ?? "0");
    if (amount == null) return "₹0";
    return "₹${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}";
  }

  String formatItemPrice(String? price) {
    if (price == null) return "₹0";
    double? amount = double.tryParse(price);
    if (amount == null) return "₹0";
    return "₹${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for Image and Order info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 60.h,
                width: 60.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: const Color(0xFFF1F8FE),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: order?.productImage != null &&
                         order?.productImage != "0" &&
                         order!.productImage!.isNotEmpty
                      ? Image.network(
                          order!.productImage!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/images/modal/modal16.png",
                              fit: BoxFit.contain,
                            );
                          },
                        )
                      : Image.asset(
                          "assets/images/modal/modal16.png",
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ORDER ID: #${orderId}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      productName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.store_outlined, size: 14.sp, color: Colors.grey[600]),
                        SizedBox(width: 4.w),
                        Text(
                          brandName,
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (order?.items != null && order!.items!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              "Selected Spares",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            ...order!.items!.map((item) => Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x0A000000),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 55.h,
                      width: 55.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: Colors.white,
                      ),
                      child: item.image != null && item.image!.isNotEmpty
                          ? Image.network(
                              item.image!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/category/mobile_repair.png",
                                  fit: BoxFit.contain,
                                );
                              },
                            )
                          : Image.asset(
                              "assets/images/category/mobile_repair.png",
                              fit: BoxFit.contain,
                            ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        item.variantSlug ?? "Part",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (item.discountPrice != null && double.tryParse(item.discountPrice.toString()) != null && double.parse(item.discountPrice.toString()) > 0) ...[
                          Text(
                            "Discount ${item.discountPrice}%",
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                        Text(
                          formatItemPrice(item.price),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )).toList(),
          ],

          SizedBox(height: 16.h),
          
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Payment Details",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                
                // Payment Method Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Payment Method",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      order?.paymentMethod?.toString() ?? "COD",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                
                // Delivery Charges
                    if (order?.applyDelivery?.toString() == "1" && order?.deliveryCharge != null && order!.deliveryCharge.toString() != "0" && order!.deliveryCharge.toString() != "0.00") ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Pickup & Delivery Charges",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "₹${double.tryParse(order!.deliveryCharge.toString())?.toStringAsFixed(2) ?? '0.00'}",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                    ],
                
                // Additional Charges
                if (order?.additionalCharge != null && order!.additionalCharge.toString() != "0" && order!.additionalCharge.toString() != "0.00") ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Additional Charge",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "₹${double.tryParse(order!.additionalCharge.toString())?.toStringAsFixed(2) ?? '0.00'}",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],

                Divider(color: Colors.grey.shade300, height: 16.h),
                
                // Total Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      formattedPrice,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
                
                // Buttons Row
                Row(
                  children: [
                    if (order?.paymentStatus == "Not Paid")
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5), // Blue
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isPaying ? null : () {
                            if (order != null) {
                              onPayNow(order!);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isCurrentPaying ? "Processing..." : "Pay Now",
                                style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                              ),
                              if (!isCurrentPaying) ...[
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PickUpServiceCard extends StatelessWidget {
  final String orderId;
  final Data order;
  final Function(Data) onPayNow;
  final bool isPaying;
  final bool isCurrentPaying;

  const PickUpServiceCard({
    required this.orderId,
    required this.order,
    required this.onPayNow,
    required this.isPaying,
    this.isCurrentPaying = false,
    super.key,
  });

  String get productName {
    if (order.productName == null || order.productName!.isEmpty) return "Service";
    return order.productName ?? "Service";
  }

  String get brandName {
    return order.serviceType ?? "";
  }

  String get formattedPrice {
    if (order.totalAmount == null) return "₹0";
    double? amount = double.tryParse(order.totalAmount ?? "0");
    if (amount == null) return "₹0";
    return "₹${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}";
  }

  String formatItemPrice(String? price) {
    if (price == null) return "₹0";
    double? amount = double.tryParse(price);
    if (amount == null) return "₹0";
    return "₹${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}";
  }

  String get paymentStatus {
    if (order.paymentStatus == "Paid") return "Paid";
    return "Not Paid";
  }

  Color get paymentStatusColor {
    if (order.paymentStatus == "Not Paid") return const Color(0xFFEB180B);
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for Image and Order info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 60.h,
                width: 60.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: const Color(0xFFF1F8FE),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: order.productImage != null &&
                         order.productImage != "0" &&
                         order.productImage!.isNotEmpty
                      ? Image.network(
                          order.productImage!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/images/modal/modal16.png",
                              fit: BoxFit.contain,
                            );
                          },
                        )
                      : Image.asset(
                          "assets/images/modal/modal16.png",
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ORDER ID: #${orderId}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      productName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.store_outlined, size: 14.sp, color: Colors.grey[600]),
                        SizedBox(width: 4.w),
                        Text(
                          brandName,
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (order.items != null && order.items!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              "Selected Spares",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            ...order.items!.map((item) => Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x0A000000),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 55.h,
                      width: 55.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: Colors.white,
                      ),
                      child: item.image != null && item.image!.isNotEmpty
                          ? Image.network(
                              item.image!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/category/mobile_repair.png",
                                  fit: BoxFit.contain,
                                );
                              },
                            )
                          : Image.asset(
                              "assets/images/category/mobile_repair.png",
                              fit: BoxFit.contain,
                            ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        item.variantSlug ?? "Part",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (item.discountPrice != null && double.tryParse(item.discountPrice.toString()) != null && double.parse(item.discountPrice.toString()) > 0) ...[
                          Text(
                            "Discount ${item.discountPrice}%",
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                        Text(
                          formatItemPrice(item.price),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )).toList(),
          ],

          SizedBox(height: 16.h),
          
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Payment Details",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                
                // Payment Method Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Payment Method",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      order.paymentMethod?.toString() ?? "COD",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                
                // Delivery Charges
                if (order.applyDelivery?.toString() == "1" && order.deliveryCharge != null && order.deliveryCharge.toString() != "0" && order.deliveryCharge.toString() != "0.00") ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pickup & Delivery Charges",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "₹${double.tryParse(order.deliveryCharge.toString())?.toStringAsFixed(2) ?? '0.00'}",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],
                
                // Additional Charges
                if (order.additionalCharge != null && order.additionalCharge.toString() != "0" && order.additionalCharge.toString() != "0.00") ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Additional Charge",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "₹${double.tryParse(order.additionalCharge.toString())?.toStringAsFixed(2) ?? '0.00'}",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],

                Divider(color: Colors.grey.shade300, height: 16.h),
                
                // Total Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      formattedPrice,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
                
                // Buttons Row
                Row(
                  children: [
                    if(order.status!.toLowerCase() == "accept" || order.status!.toLowerCase() == "pick up" || order.status!.toLowerCase() == "dispatch") ...[
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF388E3C), // Green
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            // Status action logic
                          },
                          child: Text(
                            order.status!.toLowerCase() == "pick up" ? "Pick Up" :
                            order.status!.toLowerCase() == "dispatch" ? "Dispatch" : "Accept",
                            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                    ],
                    if (order.paymentStatus == "Not Paid")
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5), // Blue
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isPaying ? null : () => onPayNow(order),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isCurrentPaying ? "Processing..." : "Pay Now",
                                style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                              ),
                              if (!isCurrentPaying) ...[
                              ],
                            ],
                          ),
                        ),
                      ),
                    if (order.paymentStatus != "Not Paid")
                      Expanded(
                        child: Center(
                          child: Text(
                            paymentStatus,
                            style: TextStyle(
                              color: paymentStatusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
