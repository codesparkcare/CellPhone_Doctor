import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cellphone_doctor/models/app/getHomeListModel.dart' as home;
import 'package:cellphone_doctor/models/app/getBrandListModel.dart' as brand;
import 'package:cellphone_doctor/ApiService/ApiService.dart';
import 'package:cellphone_doctor/screens/service__/select_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cellphone_doctor/utils/app_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceView extends StatefulWidget {
  final List<home.Categories>? categoryList;
  final int initialIndex;
  final int? spareID;
  const ServiceView({super.key, this.categoryList, this.initialIndex = 0,this.spareID});

  @override
  _ServiceViewState createState() => _ServiceViewState();
}

class _ServiceViewState extends State<ServiceView> {
  int selectedIndex = 0;
  bool isLoadingBrands = true;
  List<brand.Data> brands = [];
  final ScrollController _scrollController = ScrollController();
  
  // Cache to store brands by category ID
  static final Map<String, List<brand.Data>> _brandsCache = {};

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    _fetchBrandsForSelectedCategory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(selectedIndex);
    });
  }
  
  void _scrollToIndex(int index) {
    if (_scrollController.hasClients) {
      double itemWidth = 105.w;
      double screenWidth = MediaQuery.of(context).size.width;

      // Calculate the offset to center the tab
      double targetOffset = (index * itemWidth) + 16.w - (screenWidth / 2) + (itemWidth / 2);

      // Clamp the offset to avoid overscrolling
      double maxScroll = _scrollController.position.maxScrollExtent;
      double minScroll = _scrollController.position.minScrollExtent;
      targetOffset = targetOffset.clamp(minScroll, maxScroll);

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startBackgroundPrefetchingModels(List<brand.Data> brandsList) async {
    // Intentionally disabled. Firing background API requests clogs the HTTP connection pool 
    // and causes severe delays when the user actually clicks on a brand (like Samsung).
    return;
  }

  Future<void> _fetchBrandsForSelectedCategory() async {
    if (widget.categoryList == null || widget.categoryList!.isEmpty) {
      setState(() {
        isLoadingBrands = false;
        brands = [];
      });
      return;
    }

    final String categoryId =
        (widget.categoryList![selectedIndex].id ?? '').toString();

    bool hasCache = _brandsCache.containsKey(categoryId);

    // 1. Load from SharedPreferences if not in memory cache
    if (!hasCache) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedJson = prefs.getString("brands_json_$categoryId");
        if (cachedJson != null) {
          final decoded = jsonDecode(cachedJson);
          final parsed = brand.GetBrandListModel.fromJson(decoded);
          if (parsed.data != null && parsed.data!.isNotEmpty) {
            _brandsCache[categoryId] = parsed.data!;
            hasCache = true;
          }
        }
      } catch (e) {
        debugPrint("Error reading SharedPreferences for brands: $e");
      }
    }

    // Show cached data immediately if available
    if (hasCache) {
      setState(() {
        brands = _brandsCache[categoryId]!;
        isLoadingBrands = false;
      });
      // Removed background prefetching to prevent network contention
    } else {
      setState(() {
        isLoadingBrands = true;
      });
    }

    // Always fetch in background to get newly added brands
    final result = await ApiService.getData(
      uri: "/brands?category=$categoryId",
      isAuthorized: true,
      context: context,
    );

    if (!mounted) return;

    if (result != null) {
      try {
        // Save raw JSON to SharedPreferences for next cold start
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("brands_json_$categoryId", jsonEncode(result));

        final parsed = brand.GetBrandListModel.fromJson(result);
        final fetchedBrands = parsed.data ?? [];
        
        // Check for changes before triggering another prefetch
        bool hasChanges = true;
        final cachedList = _brandsCache[categoryId];
        if (cachedList != null) {
          if (cachedList.length == fetchedBrands.length) {
            hasChanges = false;
            for (int i = 0; i < fetchedBrands.length; i++) {
              if (cachedList[i].id != fetchedBrands[i].id) {
                hasChanges = true;
                break;
              }
            }
          }
        }
        
        if (hasChanges) {
          // Save to cache
          _brandsCache[categoryId] = fetchedBrands;
          
          setState(() {
            brands = fetchedBrands;
            isLoadingBrands = false;
          });
          // Removed background prefetching to prevent network contention
        }
      } catch (_) {
        setState(() {
          if (!hasCache) brands = [];
          isLoadingBrands = false;
        });
      }
    } else {
      if (!hasCache) {
        setState(() {
          isLoadingBrands = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Select Your Brand',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header section
          // 🔹 New Modern Header Slider
          Container(
            height: 60.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: widget.categoryList != null
                ? ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: widget.categoryList!.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                          _scrollToIndex(index);
                          _fetchBrandsForSelectedCategory();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 105.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected ? Colors.blue : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                          child: Text(
                            widget.categoryList![index].name ?? "",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              color: isSelected ? Colors.blue : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),

          // Brand grid with asset images
          Expanded(
            child: Container(
              color: Colors.white,
              child: (brands.isEmpty && !isLoadingBrands)
                  ? Center(
                      child: Text(
                        "No brands found",
                        style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                      ),
                    )
                  : Skeletonizer(
                      enabled: isLoadingBrands,
                      child: GridView.builder(
                        padding: EdgeInsets.all(16.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 1,
                        ),
                        itemCount: isLoadingBrands ? 12 : brands.length,
                        itemBuilder: (context, index) {
                          if (isLoadingBrands) {
                            return _buildBrandSkeleton();
                          }
                          final item = brands[index];
                          return InkWell(
                            onTap: () {
                              Get.to(
                                () => SelectModelScreen(
                                  categoryid: brands[index].category,
                                  brandId: brands[index].id,
                                  spareID: widget.spareID,
                                ),
                                routeName: '/select-model',
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                child: Center(
                                  child: buildAppNetworkImage(
                                    imageUrl: item.logoUrl ?? '',
                                    fit: BoxFit.contain,
                                    memCacheWidth: 250,
                                    placeholder: (context, url) => Skeletonizer(
                                      enabled: true,
                                      child: Container(color: Colors.grey.shade100),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Center(
        child: Container(
          width: 40.w,
          height: 40.w,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}
