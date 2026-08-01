import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiService/ApiService.dart';
import '../../models/app/getSelectModelResponse.dart';
import '../Auth/login_screen.dart';
import '../service_detail/service_detail_view.dart';
import '../../helpers/auth_helper.dart';

class SelectModelScreen extends StatefulWidget {
  final categoryid;
  final brandId;
  final int? spareID;
  const SelectModelScreen({super.key, this.categoryid, this.brandId,this.spareID});

  // Public static cache for models, keyed by "categoryId_brandId"
  static final Map<String, List<Data>> modelsCache = {};

  static Future<void> prefetchModelsData({
    required BuildContext context,
    required dynamic categoryId,
    required dynamic brandId,
  }) async {
    final cacheKey = "${categoryId}_${brandId}";

    // Always fetch silently in the background to revalidate cache in case of admin updates
    try {
      var successResult = await ApiService.getData(
        uri: "/models?category=$categoryId&brand=$brandId",
        isAuthorized: true,
        context: context,
      );

      if (successResult != null) {
        final response = GetSelectModelResponse.fromJson(successResult);
        final fetchedModels = response.data ?? [];
        
        // Sort models: sequence ascending (nulls last), then ID ascending
        fetchedModels.sort((a, b) {
          final seqA = a.sequence ?? double.infinity;
          final seqB = b.sequence ?? double.infinity;
          
          if (seqA != seqB) {
            return seqA.compareTo(seqB);
          }
          
          final idA = a.id ?? 0;
          final idB = b.id ?? 0;
          return idA.compareTo(idB);
        });
        
        // Compare with current cache to see if there are changes
        bool hasChanges = true;
        final cachedList = modelsCache[cacheKey];
        if (cachedList != null) {
          if (cachedList.length == fetchedModels.length) {
            hasChanges = false;
            for (int i = 0; i < fetchedModels.length; i++) {
              if (cachedList[i].id != fetchedModels[i].id ||
                  cachedList[i].slug != fetchedModels[i].slug ||
                  cachedList[i].logoUrl != fetchedModels[i].logoUrl ||
                  cachedList[i].sequence != fetchedModels[i].sequence) {
                hasChanges = true;
                break;
              }
            }
          }
        }

        if (hasChanges) {
          modelsCache[cacheKey] = fetchedModels;
        }
      }
    } catch (e) {
      debugPrint("Error prefetching models for brand $brandId: $e");
    }
  }

  @override
  State<SelectModelScreen> createState() => _SelectModelScreenState();
}

class _SelectModelScreenState extends State<SelectModelScreen> {
  GetSelectModelResponse? getHomeListModel;
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();
  List<Data> _allModels = [];
  List<Data> _filteredModels = [];
  String _searchQuery = "";
  bool _showSearchBar = false;
  bool isGridView = true;
  
  // Pagination variables
  int _currentMax = 15;
  final ScrollController _scrollController = ScrollController();
  
  void _getMoreData() {
    if (_currentMax < _filteredModels.length) {
      setState(() {
        _currentMax += 6;
      });
    }
  }
  void _startBackgroundPrefetching(List<Data> models) async {
    // Intentionally disabled to completely prevent background API calls from queueing up 
    // and slowing down user-initiated actions, like clicking on "Samsung".
    return;
  }

  getSelectModel(BuildContext context) async {
    final cacheKey = "${widget.categoryid}_${widget.brandId}";
    bool hasCache = SelectModelScreen.modelsCache.containsKey(cacheKey);
    
    // 1. Load from SharedPreferences if not in memory cache
    if (!hasCache) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedJson = prefs.getString("models_json_$cacheKey");
        if (cachedJson != null) {
          
          final decoded = jsonDecode(cachedJson);
          final response = GetSelectModelResponse.fromJson(decoded);
          if (response.data != null && response.data!.isNotEmpty) {
            SelectModelScreen.modelsCache[cacheKey] = response.data!;
            hasCache = true;
          }
        }
      } catch (e) {
        debugPrint("Error reading SharedPreferences for models: $e");
      }
    }

    // Show cached data immediately if available
    if (hasCache) {
      setState(() {
        _allModels = SelectModelScreen.modelsCache[cacheKey]!;
        if (_searchQuery.isEmpty) {
          _filteredModels = _allModels;
        } else {
          final queryForSearch = _searchQuery.replaceAll(' ', '').toLowerCase();
          _filteredModels = _allModels.where((model) {
            final modelName = (model.slug ?? "").replaceAll('-', '').replaceAll(' ', '').toLowerCase();
            return modelName.contains(queryForSearch);
          }).toList();
        }
        isLoading = false;
      });
      // Removed background prefetching
    } else {
      setState(() => isLoading = true);
    }

    // Save this combination to recent pairs for background syncing
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> recentPairs = prefs.getStringList("recent_category_brand_pairs") ?? [];
      // Remove it if it already exists to put it at the front (most recent)
      recentPairs.remove(cacheKey);
      recentPairs.insert(0, cacheKey);
      // Keep only the top 3
      if (recentPairs.length > 3) recentPairs = recentPairs.sublist(0, 3);
      prefs.setStringList("recent_category_brand_pairs", recentPairs);
    } catch (e) {
      debugPrint("Error saving recent category pair: $e");
    }

    // Always fetch in background to get newly added models
    var successResult = await ApiService.getData(
      uri: "/models?category=${widget.categoryid}&brand=${widget.brandId}",
      isAuthorized: true,
      context: context,
    );

    if (!mounted) return;

    if (successResult != null) {
      // Save raw JSON to SharedPreferences for next cold start
      try {
        
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("models_json_$cacheKey", jsonEncode(successResult));
      } catch (_) {}

      final response = GetSelectModelResponse.fromJson(successResult);
      final fetchedModels = response.data ?? [];
      
      // Sort models: sequence ascending (nulls last), then ID ascending
      fetchedModels.sort((a, b) {
        final seqA = a.sequence ?? double.infinity;
        final seqB = b.sequence ?? double.infinity;
        
        if (seqA != seqB) {
          return seqA.compareTo(seqB);
        }
        
        final idA = a.id ?? 0;
        final idB = b.id ?? 0;
        return idA.compareTo(idB);
      });
      
      // Check if there are changes between cached models and fetched ones
      bool hasChanges = true;
      final cachedList = SelectModelScreen.modelsCache[cacheKey];
      if (cachedList != null) {
        if (cachedList.length == fetchedModels.length) {
          hasChanges = false;
          for (int i = 0; i < fetchedModels.length; i++) {
            if (cachedList[i].id != fetchedModels[i].id ||
                cachedList[i].slug != fetchedModels[i].slug ||
                cachedList[i].logoUrl != fetchedModels[i].logoUrl ||
                cachedList[i].sequence != fetchedModels[i].sequence) {
              hasChanges = true;
              break;
            }
          }
        }
      }

      if (hasChanges) {
        SelectModelScreen.modelsCache[cacheKey] = fetchedModels;
        // Removed background prefetching
      }
      
      setState(() {
        getHomeListModel = response;
        _allModels = fetchedModels;
        if (_searchQuery.isEmpty) {
          _filteredModels = fetchedModels;
        } else {
          final queryForSearch = _searchQuery.replaceAll(' ', '').toLowerCase();
          _filteredModels = fetchedModels.where((model) {
            final modelName = (model.slug ?? "").replaceAll('-', '').replaceAll(' ', '').toLowerCase();
            return modelName.contains(queryForSearch);
          }).toList();
        }
        isLoading = false;
      });
    } else {
      if (!hasCache) {
        setState(() => isLoading = false);
      }
    }
  }

  void _filterModels(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _currentMax = 15; // Reset pagination on search
      if (_searchQuery.isEmpty) {
        _filteredModels = _allModels;
      } else {
        final queryForSearch = _searchQuery.replaceAll(' ', '').toLowerCase();
        _filteredModels = _allModels.where((model) {
          final modelName = (model.slug ?? "").replaceAll('-', '').replaceAll(' ', '').toLowerCase();
          return modelName.contains(queryForSearch);
        }).toList();
      }
    });
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
        _filterModels("");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getSelectModel(context);
    _searchController.addListener(() {
      _filterModels(_searchController.text);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _getMoreData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _showSearchBar ? "Search Models" : "Select Model",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(
          //     isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
          //     color: Colors.black54,
          //   ),
          //   tooltip: isGridView ? "Switch to List View" : "Switch to Grid View",
          //   onPressed: () {
          //     setState(() {
          //       isGridView = !isGridView;
          //     });
          //   },
          // ),
          IconButton(
            icon: Icon(
              _showSearchBar ? Icons.close : Icons.search,
              color: Colors.black,
            ),
            onPressed: _toggleSearchBar,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar (Animated)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showSearchBar ? 50 : 0,
            margin: EdgeInsets.only(
              left: 16,
              right: 16,
              top: _showSearchBar ? 10 : 0,
              bottom: _showSearchBar ? 20 : 0,
            ),
            curve: Curves.easeInOut,
            child: _showSearchBar
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Search models...",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  )
                : null,
          ),
          
          // Models Grid
          Expanded(
            child: isLoading
                ? Skeletonizer(
                    enabled: true,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) => Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                margin: const EdgeInsets.all(20),
                                color: Colors.grey[300],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : _filteredModels.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.inventory_2_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? "No models found for '$_searchQuery'"
                                  : "No Models Found",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                  child: const Text("Clear Search"),
                                ),
                              ),
                          ],
                        ),
                      )
                    : isGridView 
                      ? GridView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _filteredModels.length > _currentMax ? _currentMax : _filteredModels.length,
                          itemBuilder: (context, index) {
                            final model = _filteredModels[index];
                            final displayName = (model.slug ?? "").replaceAll('-', ' ');
                            return GestureDetector(
                              onTap: () => Get.to(() => ServiceDetailScreen(
                                brandId: model.brand,
                                catergoryId: model.category,
                                modelId: model.id,
                                spareID: widget.spareID,
                              )),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.2),
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.w),
                                        child: (model.logoUrl == null || model.logoUrl!.trim().isEmpty || model.logoUrl == "null")
                                            ? const Center(
                                                child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40),
                                              )
                                            : CachedNetworkImage(
                                                imageUrl: model.logoUrl!,
                                                fit: BoxFit.contain,
                                                memCacheWidth: 250,
                                                memCacheHeight: 250,
                                                maxWidthDiskCache: 250,
                                                maxHeightDiskCache: 250,
                                                filterQuality: FilterQuality.high,
                                                fadeInDuration: const Duration(milliseconds: 100),
                                                placeholder: (context, url) => Skeletonizer(
                                                  enabled: true,
                                                  child: Container(color: Colors.grey.shade100),
                                                ),
                                                errorWidget: (context, url, error) =>
                                                    const Center(
                                                      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40),
                                                    ),
                                              ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                                        child: Text(
                                          displayName,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          itemCount: _filteredModels.length > _currentMax ? _currentMax : _filteredModels.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                          itemBuilder: (context, index) {
                            final model = _filteredModels[index];
                            final displayName = (model.slug ?? "").replaceAll('-', ' ');
                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              leading: Container(
                                width: 50.w,
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: (model.logoUrl == null || model.logoUrl!.trim().isEmpty || model.logoUrl == "null")
                                    ? const Center(
                                        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 30),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: model.logoUrl!,
                                        fit: BoxFit.contain,
                                        memCacheWidth: 250,
                                        memCacheHeight: 250,
                                        maxWidthDiskCache: 250,
                                        maxHeightDiskCache: 250,
                                        filterQuality: FilterQuality.high,
                                        fadeInDuration: const Duration(milliseconds: 100),
                                        placeholder: (context, url) => Skeletonizer(
                                          enabled: true,
                                          child: Container(color: Colors.grey.shade100),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                              child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 30),
                                            ),
                                      ),
                              ),
                              title: Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16.sp,
                                color: Colors.grey,
                              ),
                              onTap: () => Get.to(() => ServiceDetailScreen(
                                brandId: model.brand,
                                catergoryId: model.category,
                                modelId: model.id,
                                spareID: widget.spareID,
                              )),
                            );
                          },
                        ),
          ),
        ],
      ),
    );
  }
}
