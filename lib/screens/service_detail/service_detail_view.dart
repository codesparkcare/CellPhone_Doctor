import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cellphone_doctor/screens/Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../ApiService/ApiService.dart';
import '../../helpers/auth_helper.dart';
import '../../models/app/GetCartListResponseModel.dart' show GetCartListResponseModel;
import '../../models/app/GetSparePartsResponseModelNew.dart'hide Data;
import '../../models/app/getSpareResponseModel.dart' ;
import '../cart/cartView.dart';


class CategoryCache {
  final List<Spare> products;
  final String currentproductId;
  final String parentName;
  final String subName;
  final String image;

  CategoryCache({
    required this.products,
    required this.currentproductId,
    required this.parentName,
    required this.subName,
    required this.image,
  });
}

class ServiceDetailScreen extends StatefulWidget {
  final catergoryId;
  final brandId;
  final modelId;
  final int? spareID;
  const ServiceDetailScreen({super.key, this.catergoryId, this.brandId, this.modelId,this.spareID});

  // Global static caches
  static final Map<String, CategoryCache> globalCategoryCaches = {};
  static final Map<dynamic, List<Data>> globalCategoriesCache = {};
  static final Set<dynamic> globalFilteredCategoriesKeys = {};
  static final Map<dynamic, List<Data>> globalRawCategoriesCache = {};

  static final Set<String> fullyPrefetchedModels = {};
  static final Map<String, Future<void>> _activeFetches = {};

  static Future<void> prefetchServiceDetailData({
    required BuildContext context,
    required dynamic categoryId,
    required dynamic brandId,
    required dynamic modelId,
    int? spareID,
    String userid = "",
    bool forceRefresh = false,
  }) async {
    final cacheKey = "${categoryId}_${brandId}_${modelId}";

    if (!forceRefresh && fullyPrefetchedModels.contains(cacheKey)) return;

    if (!forceRefresh && _activeFetches.containsKey(cacheKey)) {
      await _activeFetches[cacheKey];
      return;
    }

    final fetchFuture = _doPrefetch(
      context: context,
      categoryId: categoryId,
      brandId: brandId,
      modelId: modelId,
      spareID: spareID,
      userid: userid,
      forceRefresh: forceRefresh,
      cacheKey: cacheKey,
    );

    _activeFetches[cacheKey] = fetchFuture;
    try {
      await fetchFuture;
    } finally {
      if (_activeFetches[cacheKey] == fetchFuture) {
        _activeFetches.remove(cacheKey);
      }
    }
  }

  static Future<void> _doPrefetch({
    required BuildContext context,
    required dynamic categoryId,
    required dynamic brandId,
    required dynamic modelId,
    int? spareID,
    String userid = "",
    bool forceRefresh = false,
    required String cacheKey,
  }) async {

    // Helper to parse and cache JSON data
    void processAndCacheData(Map data) {
      // 1. Process Spares (Categories)
      List<Data> rawCategories = [];
      if (data['spares'] != null) {
        rawCategories = (data['spares'] as List).map((e) => Data.fromJson(e)).toList();
      }

      Map<String, dynamic> productsBySpare = data['products_by_spare'] ?? {};
      
      // 2. Filter categories (only those that have products)
      List<Data> validCategories = [];
      for (var cat in rawCategories) {
        String catIdStr = cat.id.toString();
        var prodList = productsBySpare[catIdStr];
        
        bool hasProducts = false;
        if (prodList != null && prodList is List) {
          for (var product in prodList) {
             var spares = product['spare'] as List?;
             if (spares != null && spares.isNotEmpty) {
                hasProducts = true;
                break;
             }
          }
        }
        if (hasProducts) validCategories.add(cat);
      }

      globalRawCategoriesCache[cacheKey] = rawCategories;
      globalCategoriesCache[cacheKey] = validCategories;
      globalFilteredCategoriesKeys.add(cacheKey);

      // 3. Process and Cache Products for all spares
      productsBySpare.forEach((spareIdStr, prodList) {
         if (prodList is List) {
            List<Spare> fetchedProducts = [];
            String pId = '';
            String pName = '';
            String sName = '';
            String img = '';

            if (prodList.isNotEmpty) {
              pId = prodList[0]['id']?.toString() ?? '';
              pName = prodList[0]['parentname'] ?? '';
              sName = prodList[0]['name'] ?? '';
              img = prodList[0]['image'] ?? '';
            }

            for (var product in prodList) {
              var spares = product['spare'] as List?;
              if (spares != null) {
                for (var spare in spares) {
                  fetchedProducts.add(Spare.fromJson(spare));
                }
              }
            }

            final productCacheKey = "${categoryId}_${brandId}_${modelId}_${spareIdStr}_$userid";
            globalCategoryCaches[productCacheKey] = CategoryCache(
              products: fetchedProducts,
              currentproductId: pId,
              parentName: pName,
              subName: sName,
              image: img,
            );
         }
      });

      fullyPrefetchedModels.add(cacheKey);
    }

    // 1. Try loading from SharedPreferences instantly
    if (!forceRefresh) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedJson = prefs.getString("model_details_json_${cacheKey}_$userid");
        if (cachedJson != null) {
          
          final decoded = jsonDecode(cachedJson);
          if (decoded != null && decoded is Map && decoded['status'] == true) {
             processAndCacheData(decoded['data']);
             return; // Return early if we have cache, the UI will load instantly.
          }
        }
      } catch (e) {
        debugPrint("Error reading SharedPreferences for model-details: $e");
      }
    }

    // 2. Fetch from API if no cache
    try {
      var uri = "/model-details?category=$categoryId&brand=$brandId&model=$modelId";
      if (userid.isNotEmpty) {
        uri += "&user=$userid";
      }

      var result = await ApiService.getData(
        uri: uri,
        isAuthorized: true,
        context: context,
      );

      if (result != null && result is Map && result['status'] == true) {
        // Save to SharedPreferences for next cold start
        try {
           
           final prefs = await SharedPreferences.getInstance();
           prefs.setString("model_details_json_${cacheKey}_$userid", jsonEncode(result));
        } catch (_) {}

        processAndCacheData(result['data']);
      }
    } catch (e) {
      debugPrint("Error prefetching model-details: $e");
    }
  }

  @override
  State<ServiceDetailScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<ServiceDetailScreen> {
  bool _isDisposed = false;
  bool isLoadingCategories = true;
  bool isLoadingProducts = false;
  String spareId= "";
  Map<String, bool> _isAddingToCart = {};
  Map<String, bool> _isRemovingFromCart = {};

  List<Data> categories = [];
  List<Spare> products = [];
  String parentName = '';
  String subName = '';
  String image = '';
  String currentproductId = '';

  int selectedIndex = 0;
  bool isLogin = false;
  String userid = "";

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _initializeData();
  }

  Future<void> _initializeData() async {
    await loginCheck();
    fetchCategories();
  }

  Future<void> loginCheck() async {

    isLogin = await AuthHelper.getBool("isShowOnBoard")??false;
    if(isLogin){
      userid = await AuthHelper.getString("userid")??"";
    }
  }

  void showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Please Login"),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: Colors.grey),
              )
            ],
          ),
          content: const Text(
            "You need to login first to continue.",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to Login Screen
                Get.to(() => LoginScreen());
              },
              child: const Text("Login"),
            )
          ],
        );
      },
    );
  }

  Future<void> isLoginFun() async {
    if (isLogin) {
      // Check if cart has items before navigating
      try {
        final result = await ApiService.getData(
          uri: "/customer/cart",
          isAuthorized: true,
          context: context,
        );

        if (result != null) {
          var cartModel = GetCartListResponseModel.fromJson(result);
          if (cartModel.data != null && cartModel.data!.isNotEmpty) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CartScreen()),
            );
            
            final cacheKey = "${widget.catergoryId}_${widget.brandId}_${widget.modelId}";
            ServiceDetailScreen.fullyPrefetchedModels.remove(cacheKey);
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove("model_details_json_$cacheKey");
            fetchCategories();
          } else {
            Get.snackbar("Alert", "No product available in cart");
          }
        } else {
          Get.snackbar("Error", "Failed to fetch cart details");
        }
      } catch (e) {
        debugPrint("Error checking cart: $e");
        Get.snackbar("Error", "Something went wrong. Please try again.");
      }
    } else {
      showLoginDialog(context);
    }
  }

  void showCustomPopup(BuildContext context, String disc) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.all(20.w),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 24.sp,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "Info",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Divider(height: 30.h, color: Colors.grey.shade300),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      disc.isNotEmpty
                          ? disc
                          : "No information available.",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: disc.isNotEmpty
                            ? Colors.black87
                            : Colors.grey.shade600,
                        fontStyle: disc.isNotEmpty
                            ? FontStyle.normal
                            : FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                      backgroundColor: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
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



  Future<void> _silentRevalidateModelDetails() async {
    final cacheKey = "${widget.catergoryId}_${widget.brandId}_${widget.modelId}";
    ServiceDetailScreen.fullyPrefetchedModels.remove(cacheKey); // force re-fetch
    await ServiceDetailScreen.prefetchServiceDetailData(
      context: context,
      categoryId: widget.catergoryId,
      brandId: widget.brandId,
      modelId: widget.modelId,
      spareID: widget.spareID,
      userid: userid,
      forceRefresh: true,
    );
    if (mounted && spareId.isNotEmpty) {
      fetchProducts(spareId);
    }
  }

  /// Fetch categories (and all products via model-details endpoint)
  Future<void> fetchCategories() async {
    final cacheKey = "${widget.catergoryId}_${widget.brandId}_${widget.modelId}";
    
    setState(() => isLoadingCategories = true);

    if (!ServiceDetailScreen.fullyPrefetchedModels.contains(cacheKey)) {
        await ServiceDetailScreen.prefetchServiceDetailData(
          context: context,
          categoryId: widget.catergoryId,
          brandId: widget.brandId,
          modelId: widget.modelId,
          spareID: widget.spareID,
          userid: userid,
        );
    }

    if (ServiceDetailScreen.globalCategoriesCache.containsKey(cacheKey)) {
      categories = List<Data>.from(ServiceDetailScreen.globalCategoriesCache[cacheKey]!);

      if (categories.isNotEmpty) {
        if (widget.spareID != null) {
          int? foundIndex;
          for (int i = 0; i < categories.length; i++) {
            if (categories[i].id == widget.spareID) {
              foundIndex = i;
              break;
            }
          }

          if (foundIndex != null) {
            selectedIndex = foundIndex;
            spareId = categories[foundIndex].id.toString();
          } else {
            spareId = categories[0].id.toString();
          }
        } else {
          spareId = categories[0].id.toString();
        }
        
        fetchProducts(spareId);
      }

      setState(() {
        isLoadingCategories = false;
      });

      _silentRevalidateModelDetails();
      return;
    }

    setState(() => isLoadingCategories = false);
  }

  Future<void> fetchProducts(String spareId) async {
    final cacheKey = "${widget.catergoryId}_${widget.brandId}_${widget.modelId}_${spareId}_$userid";
    
    if (ServiceDetailScreen.globalCategoryCaches.containsKey(cacheKey)) {
      final cache = ServiceDetailScreen.globalCategoryCaches[cacheKey]!;
      setState(() {
        products = cache.products;
        currentproductId = cache.currentproductId;
        parentName = cache.parentName;
        subName = cache.subName;
        image = cache.image;
        isLoadingProducts = false;
      });
      return;
    }

    setState(() {
      products = [];
      isLoadingProducts = false;
    });
  }

  Future<void> clearCart() async {
    try {
      final result = await ApiService.getData(
        uri: "/customer/cart",
        isAuthorized: true,
        context: context,
      );
      if (result != null) {
        var cartModel = GetCartListResponseModel.fromJson(result);
        if (cartModel.data != null) {
          for (var item in cartModel.data!) {
            if (item.spareId != null) {
              await ApiService.getData(
                uri: "/customer/cart/delete/${item.spareId}",
                isAuthorized: true,
                context: context,
              );
            } else if (item.id != null) {
              await ApiService.getData(
                uri: "/customer/cart/delete/${item.id}",
                isAuthorized: true,
                context: context,
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error clearing cart: $e");
    }
  }

  Future<void> addCart(String productId, String variantId, int index) async {
    setState(() {
      _isAddingToCart[variantId] = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_added_parentname', parentName ?? '');
    await prefs.setString('last_added_subname', subName ?? '');
    await prefs.setString('last_added_image', image ?? '');

    String effectiveProductId = currentproductId;
    try {
      final cartResult = await ApiService.getData(
        uri: "/customer/cart",
        isAuthorized: true,
        context: context,
      );
      if (cartResult != null && cartResult is Map && cartResult['data'] != null) {
        var cartData = cartResult['data'] as List;
        if (cartData.isNotEmpty) {
           var firstItem = cartData.first;
           if (firstItem['model_id']?.toString() == widget.modelId?.toString()) {
               if (firstItem['spare'] != null && firstItem['spare']['product_id'] != null) {
                   effectiveProductId = firstItem['spare']['product_id'].toString();
               }
           }
        }
      }
    } catch(e) {}

    // Prepare multipart request fields
    List<MultipartRequestService> multipartFields = [];
    multipartFields.add(MultipartRequestService(
      fieldName: "product_id",
      fieldValue: effectiveProductId,
      isField: true,
      isFile: false,
    ));
    multipartFields.add(MultipartRequestService(
      fieldName: "variant_id",
      fieldValue: variantId,
      isField: true,
      isFile: false,
    ));
    try {
      var result = await ApiService.multipartRequest(
        uri: "/customer/cart",
        method: "POST",
        multipartRequestFields: multipartFields,
        context: context,
        isAuthorized: true,
      );

      if (result != null && result != "failed" && result is Map) {
        String message = result["message"] ?? "Unknown error";
        bool hasCart = result["has_cart"] ?? false;

        if (hasCart) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Replace Cart Item?"),
              content: const Text(
                  "Your cart already contains another product. Would you like to remove it and add this new product?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    
                    // Clear old cart and add the new product first
                    await clearCart();
                    await addCart(productId, variantId, index);

                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CartScreen()),
                    );
                    
                    final cacheKey = "${widget.catergoryId}_${widget.brandId}_${widget.modelId}";
                    ServiceDetailScreen.fullyPrefetchedModels.remove(cacheKey);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove("model_details_json_$cacheKey");
                    fetchCategories();
                  },
                  child: const Text("Replace",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
          return;
        }

        final bool isSuccess = (result is Map && result["status"] == true) ||
            message.toString().toLowerCase().contains("added");
        if (isSuccess) {
          setState(() {
            products[index] = products[index].copyWith(isCart: 1);
          });
          Get.snackbar("Success", "Product added to cart");
        } else {
          Get.snackbar("Failed", message);
        }
      } else {
        Get.snackbar("Failed", "Please try again later");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred. Please try again.");
    } finally {
      setState(() {
        _isAddingToCart.remove(variantId);
      });
    }
  }

  Future<void> removeCart(String variantId, int index) async {
    setState(() {
      _isRemovingFromCart[variantId] = true;
    });
    try {
      final response = await ApiService.getData(
        uri: "/customer/cart/delete/$variantId",
        isAuthorized: true,
        context: context,
      );
      final bool isSuccess = response != null && response != "failed";
      if (isSuccess) {
        setState(() {
          products[index] = products[index].copyWith(isCart: 0);
        });
        Get.snackbar("Success", "Product removed from cart");
      } else {
        Get.snackbar("Failed", "Please try again later");
      }
    } catch (_) {
      Get.snackbar("Error", "An error occurred. Please try again.");
    } finally {
      setState(() {
        _isRemovingFromCart.remove(variantId);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Select Spare",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Row(
        children: [
          /// 🔹 LEFT CATEGORY BAR
          Container(
            width: 90.w,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Colors.grey.shade200, width: 1.w),
              ),
            ),
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedIndex == index;
                var category = categories[index];
                String imagePath = category.imageUrl ??
                    "assets/images/selectService/display.png";

                return InkWell(
                  onTap: () {
                    setState(() => selectedIndex = index);
                    spareId = category.id.toString() ?? "";
                    fetchProducts(category.id.toString() ?? "");
                  },
                  child: Container(
                    height: 115.h,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: [
                        // Blue left indicator
                        if (isSelected)
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 3.w,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        // Category Content
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 6.w),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Transparent, fixed-size image box container
                                SizedBox(
                                  height: 60.h,
                                  width: 60.w,
                                  child: CachedNetworkImage(
                                    imageUrl: imagePath,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Center(
                                      child: SizedBox(
                                        width: 20.w,
                                        height: 20.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.w,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Image.asset(
                                      "assets/images/selectService/display.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  category.title ?? "",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Small divider line
                        if (index < categories.length - 1)
                          Positioned(
                            left: 10.w,
                            right: 10.w,
                            bottom: 0,
                            child: Container(
                              height: 0.8.h,
                              color: Colors.grey.shade200,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// 🔹 RIGHT CONTENT AREA
          Expanded(
            child: Column(
              children: [
                /// Top Banner
                if (parentName.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(minHeight: 120.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 95.h,
                            width: 95.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(2.w),
                              child: Image.network(
                                image,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  "assets/images/selectService/display option.png",
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  parentName.isNotEmpty
                                      ? '${parentName[0].toUpperCase()}${parentName.substring(1)}'
                                      : '',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  subName,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 15.h),

                /// Products List
                Expanded(
                  child: isLoadingProducts
                      ? const Center(child: CircularProgressIndicator())
                      : products.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48.sp, color: Colors.grey.shade300),
                        SizedBox(height: 10.h),
                        const Text("No services available for this category",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: products.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var product = products[index];
                      final bool isAdding = _isAddingToCart[product.id.toString()] == true;
                      final bool isRemoving = _isRemovingFromCart[product.id.toString()] == true;
                      final bool isLoading = isAdding || isRemoving;

                      return ServiceOptionCard(
                        imagePath: product.image ?? "assets/images/selectService/display option.png",
                        title: product.name ?? "",
                        originalPrice: product.regularPrice != null && product.regularPrice != "0" && product.regularPrice != "0.00"
                            ? "₹${product.regularPrice}"
                            : "",
                        discount: product.discountPrice != null && product.discountPrice.toString() != "0" && product.discountPrice.toString() != "0.00"
                            ? "${product.discountPrice}"
                            : "",
                        offerPrice: product.price != null && product.price != "0" && product.price != "0.00"
                            ? "₹${product.price}"
                            : "",
                        warranty: product.warranty ?? "",
                        warrantyDescription: product.warranty_discription ?? "",
                        isAdded: (product.isCart ?? 0) == 1,
                        isLoading: isLoading,
                        onTapAdd: isLoading ? null : () {
                          if (isLogin) {
                            if ((product.isCart ?? 0) != 1) {
                              addCart(product.productId.toString(), product.id.toString(), index);
                            }
                          } else {
                            showLoginDialog(context);
                          }
                        },
                        onTapCancel: isLoading ? null : () {
                          if (isLogin) {
                            if ((product.isCart ?? 0) == 1) {
                              removeCart(product.id.toString(), index);
                            }
                          } else {
                            showLoginDialog(context);
                          }
                        },
                        onTapInfo: () {
                          showCustomPopup(context, product.description ?? "");
                        },
                      );
                    },
                  ),
                ),
                if (parentName.isNotEmpty)
                  SafeArea(
                    top: false,
                    bottom: true,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 10.h),
                      child: GestureDetector(
                        onTap: () => isLoginFun(),
                        child: Container(
                          height: 44.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "BOOK NOW",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// --------------------- ServiceOptionCard ---------------------
class ServiceOptionCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String discount;
  final String originalPrice;
  final String offerPrice;
  final String warranty;
  final String warrantyDescription;
  final VoidCallback? onTapAdd;
  final VoidCallback? onTapCancel;
  final VoidCallback? onTapInfo;
  final bool isAdded;
  final bool isLoading;

  const ServiceOptionCard({
    super.key,
    required this.imagePath,
    required this.title,
    this.discount = "",
    this.originalPrice = "",
    this.offerPrice = "",
    this.warranty = "",
    this.warrantyDescription = "",
    this.onTapAdd,
    this.onTapCancel,
    this.onTapInfo,
    this.isAdded = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.only(left: 14.w, right: 14.w, top: 6.h, bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Product Name (Full Line at the top)
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          if (originalPrice.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              originalPrice,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
          SizedBox(height: 4.h),

          /// Row containing Left Info (Prices & Warranty) and Right Info (Image & ADD Button)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Left Column: Prices & Warranty Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Offer Price & Discount Badge Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (offerPrice.isNotEmpty)
                          Text(
                            offerPrice,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        if (discount.isNotEmpty && discount != "0" && discount != "0.00") ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              "${discount.endsWith('.00') ? discount.substring(0, discount.length - 3) : discount}% OFF",
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    /// Spacing to Warranty Badge
                    if (warranty.isNotEmpty) SizedBox(height: 6.h),

                    /// Warranty Badge
                    if (warranty.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              elevation: 5,
                              backgroundColor: Colors.white,
                              child: Container(
                                padding: EdgeInsets.all(20.w),
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.verified_user_outlined,
                                          color: Colors.blue.shade700,
                                          size: 24.sp,
                                        ),
                                        SizedBox(width: 10.w),
                                        Text(
                                          "Warranty Details",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(height: 30.h, color: Colors.grey.shade300),
                                    Flexible(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          warrantyDescription.isNotEmpty
                                              ? warrantyDescription
                                              : "Warranty Details Not Mentioned",
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: warrantyDescription.isNotEmpty
                                                ? Colors.black87
                                                : Colors.grey.shade600,
                                            fontStyle: warrantyDescription.isNotEmpty
                                                ? FontStyle.normal
                                                : FontStyle.italic,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                                          backgroundColor: Colors.blue.shade50,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                        ),
                                        child: Text(
                                          "Close",
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F7FF),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 13.sp,
                                color: Colors.blue.shade700,
                              ),
                              SizedBox(width: 6.w),
                              Flexible(
                                child: Text(
                                  warranty,
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.info_outline,
                                size: 12.sp,
                                color: Colors.blue.shade700,
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 6.h),

                    /// ADD / ADDED Action Button
                    if (isLoading)
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: isAdded ? onTapCancel : onTapAdd,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 150.w,
                          padding: EdgeInsets.symmetric(vertical: 3.h),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isAdded ? Colors.green.shade50 : Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: isAdded ? Colors.green : Colors.transparent,
                            ),
                            boxShadow: isAdded
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isAdded ? "ADDED" : "ADD",
                                style: TextStyle(
                                  color: isAdded ? Colors.green : Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isAdded) ...[
                                SizedBox(width: 2.w),
                                Icon(
                                  Icons.check_circle,
                                  size: 11.sp,
                                  color: Colors.green,
                                )
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),

              /// Right Column: Image stack & ADD Button underneath
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  /// Stack with Product image & Info button
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 85.h,
                        width: 85.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2.w),
                          child: CachedNetworkImage(
                            imageUrl: imagePath,
                            fit: BoxFit.contain,
                            memCacheWidth: 250,
                            memCacheHeight: 250,
                            maxWidthDiskCache: 250,
                            maxHeightDiskCache: 250,
                            filterQuality: FilterQuality.high,
                            fadeInDuration: const Duration(milliseconds: 100),
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade300),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.image_not_supported, size: 20.sp, color: Colors.grey),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -6.h,
                        right: -6.w,
                        child: GestureDetector(
                          onTap: onTapInfo,
                          child: Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.info_outline,
                              size: 18.sp,
                              color: Colors.blue.shade400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

