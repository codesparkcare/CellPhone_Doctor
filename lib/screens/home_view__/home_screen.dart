// $file
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:cellphone_doctor/ApiService/ApiService.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

import 'package:cellphone_doctor/models/app/getHomeListModel.dart';
import 'package:cellphone_doctor/models/app/getSelectModelResponse.dart';
import 'package:cellphone_doctor/screens/home_view__/home_widgets/Strore_section.dart';
import 'package:cellphone_doctor/screens/home_view__/home_widgets/faq.dart';
import 'package:cellphone_doctor/screens/home_view__/home_widgets/ourProcessSection.dart';
import 'package:cellphone_doctor/screens/service__/service_view.dart';
import 'package:cellphone_doctor/utils/app-sizes.dart';
import 'package:cellphone_doctor/utils/app_colors.dart';
import 'package:cellphone_doctor/utils/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controller/navBar_controller.dart';
import '../service_detail/service_detail_view.dart';
import 'home_widgets/StorySection/story_section.dart';
import 'home_widgets/carousel_area.dart';
import 'home_widgets/did_u_know.dart';
import 'home_widgets/service_section.dart';
import 'home_widgets/topBrand_section.dart';
import 'home_widgets/trusted_section.dart';
import 'home_widgets/whyUs_section.dart';

GetHomeListModel parseHomeModel(Map<String, dynamic> json) {
  return GetHomeListModel.fromJson(json);
}

class HomeScreen extends StatefulWidget {
  final bool showBackButton;
  const HomeScreen({super.key, this.showBackButton = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  bool showStickyHeaders = false;
  bool showAppBar = false;
  bool showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _sharedSearchController = TextEditingController();
  final FocusNode _sharedSearchFocus = FocusNode();
  bool showScrollToTop = false;
  StateSetter? _activePopupSetState;

  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  double _level = 0.0;

  GetHomeListModel? getHomeListModel;
  bool _isLoading = true;
  bool _isSearching = false;
  List<Data> _searchResults = [];
  bool _expandCategories = false;

  final ScrollController _scrollController1 = ScrollController();
  Timer? _timer;

  getActiveJobs(BuildContext context) async {
    if (getHomeListModel == null) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Try to load from cache immediately so UI feels instant
      try {
        final cachedData = prefs.getString('home_api_cache_v1');
        if (cachedData != null && cachedData != "failed" && getHomeListModel == null) {
          final decoded = jsonDecode(cachedData);
          if (decoded is Map<String, dynamic>) {
            final cachedModel = parseHomeModel(decoded);
            if (mounted) {
              setState(() {
                getHomeListModel = cachedModel;
                if (getHomeListModel?.review != null && getHomeListModel!.review!.isNotEmpty) {
                  getHomeListModel!.review!.shuffle();
                }
                _isLoading = false;
              });
              // Start warming image cache immediately from cached data
              _precacheHomeImages(cachedModel);
            }
          } else {
            // Remove corrupted/invalid cache data
            await prefs.remove('home_api_cache_v1');
          }
        }
      } catch (cacheError) {
        debugPrint("Error loading from cache: $cacheError");
        // Clear corrupted cache to avoid repeated failures
        try {
          await prefs.remove('home_api_cache_v1');
        } catch (_) {}
      }

      // 2. Fetch fresh data in the background
      final successResult = await ApiService.getData(
        uri: "/home",
        isAuthorized: true,
        context: context,
      );
      
      if (successResult != null && successResult != "failed" && successResult is Map<String, dynamic>) {
        await prefs.setString('home_api_cache_v1', jsonEncode(successResult));
        final freshModel = parseHomeModel(successResult);
        
        if (mounted) {
          setState(() {
            getHomeListModel = freshModel;
            if (getHomeListModel?.review != null && getHomeListModel!.review!.isNotEmpty) {
              getHomeListModel!.review!.shuffle();
            }
            _isLoading = false;
          });
          // Warm image cache with fresh data (covers first install — no cache yet)
          _precacheHomeImages(freshModel);
          _autoScrollCategories();
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Home Load Error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Pre-warm image cache for only above-the-fold content.
  /// Prevents Dart thread choking on 50 parallel image decodes on first install.
  void _precacheHomeImages(GetHomeListModel model) {
    if (!mounted) return;
    final ctx = context;

    // 1. First 2 banners (above the fold)
    final bannerUrls = (model.banner ?? [])
        .map((b) => b.image ?? '')
        .where((u) => u.startsWith('http'))
        .take(2)
        .toList();

    // 2. First 4 category icons (above the fold)
    final categoryUrls = (model.categories ?? [])
        .map((c) => c.imageUrl ?? '')
        .where((u) => u.startsWith('http'))
        .take(4)
        .toList();

    // 3. Featured spares (above the fold)
    final mobileSpares = (model.spare ?? [])
        .where((s) => s.isFeatured == true && s.type == "1")
        .toList()
      ..sort((a, b) => (a.sequence ?? 0).compareTo(b.sequence ?? 0));
        
    final spareUrls = mobileSpares
        .map((s) => s.logoUrl ?? s.imageUrl ?? '')
        .where((u) => u.startsWith('http'))
        .take(9)
        .toList();

    // Schedule after 300ms delay to let the page mount and transition smoothly
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      for (final url in bannerUrls) {
        precacheImage(CachedNetworkImageProvider(url), ctx);
      }
      for (final url in categoryUrls) {
        precacheImage(
          CachedNetworkImageProvider(url),
          ctx,
        );
      }
      for (final url in spareUrls) {
        precacheImage(
          CachedNetworkImageProvider(url),
          ctx,
        );
      }
    });
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initSpeech();
    getActiveJobs(context);

    Get.find<NavController>().addListener(() {
      if (mounted && Get.find<NavController>().currentIndex == 0) {
        setState(() {
          if (getHomeListModel?.review != null && getHomeListModel!.review!.isNotEmpty) {
            getHomeListModel!.review!.shuffle();
          }
        });
      }
    });

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final double offset = _scrollController.offset;
      final bool newScrollToTop = offset > 300;
      final bool newStickyHeaders = offset > 150;

      if (newScrollToTop != showScrollToTop || newStickyHeaders != showStickyHeaders) {
        setState(() {
          showScrollToTop = newScrollToTop;
          showStickyHeaders = newStickyHeaders;
        });
      }
    });
  }

  void _autoScrollCategories() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_scrollController1.hasClients) {
        _scrollController1.animateTo(
          _scrollController1.position.maxScrollExtent,
          duration: const Duration(milliseconds: 2000),
          curve: Curves.easeInOut,
        ).then((_) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_scrollController1.hasClients) {
              _scrollController1.animateTo(
                0,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
              );
            }
          });
        });
      }
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  bool _speechEnabled = false;

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            if (mounted) {
              setState(() => _isListening = false);
              if (_activePopupSetState != null) {
                _activePopupSetState!(() {});
              }
            }
          }
        },
        onError: (error) {
          debugPrint('Speech error: $error');
          _speechEnabled = false; // Reset on error so it can try re-initializing
          if (mounted) {
            setState(() => _isListening = false);
            if (_activePopupSetState != null) {
              _activePopupSetState!(() {});
            }
          }
        },
      );
      debugPrint('Speech initialized: $_speechEnabled');
    } catch (e) {
      debugPrint('Speech init error: $e');
      _speechEnabled = false;
    }
  }

  void _listen(StateSetter setStatePopup) async {
    try {
      if (_isListening) {
        _speechToText.stop();
        setState(() => _isListening = false);
        setStatePopup(() {});
        return;
      }

      // 1. Check Permissions explicitly
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
        if (!status.isGranted) {
          debugPrint("Microphone permission denied");
          return;
        }
      }

      // 2. Ensure initialized
      if (!_speechEnabled) {
        _speechEnabled = await _speechToText.initialize();
        if (!_speechEnabled) {
          debugPrint("Speech recognition failed to initialize");
          return;
        }
      }

      // 3. Start Listening
      setState(() {
        _isListening = true;
        _level = 0.0;
        _lastWords = ''; // Reset words when starting new listen
      });
      setStatePopup(() {});

      // Pulse timer for UI
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!_isListening || _activePopupSetState == null) {
          timer.cancel();
          return;
        }
        _activePopupSetState!(() {});
      });

      // Small delay to ensure audio hardware is ready after initialization/permission
      await Future.delayed(const Duration(milliseconds: 300));

      if (!_speechToText.isAvailable) {
        debugPrint("Speech recognition is not available on this device");
        setState(() => _isListening = false);
        setStatePopup(() {});
        return;
      }

      await _speechToText.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _lastWords = result.recognizedWords;
            });
            if (_activePopupSetState != null) {
              _activePopupSetState!(() {});
            }

            if (result.finalResult) {
              setState(() => _isListening = false);
              if (_activePopupSetState != null) {
                _activePopupSetState!(() {});
              }
              
              // Close popup and pass result to the home screen handler
              Future.delayed(const Duration(milliseconds: 800), () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                  _onSpeechResult(_lastWords);
                }
              });
            }
          }
        },
        onSoundLevelChange: (level) {
          if (mounted) {
            setState(() => _level = level);
            if (_activePopupSetState != null) {
              _activePopupSetState!(() {});
            }
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint("Speech listen error: $e");
      if (mounted) {
        setState(() => _isListening = false);
        setStatePopup(() {});
      }
    }
  }

  void _onSpeechResult(String text) {
    if (text.isNotEmpty) {
      // Set text and move cursor to end
      _sharedSearchController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );

      // Scroll to search area so user can see it
      _scrollController.animateTo(
        220,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      
      // Focus the field to trigger the Autocomplete dropdown
      _sharedSearchFocus.requestFocus();
    }
  }

  Future<void> _fetchSearchResults(String query, {StateSetter? setStatePopup}) async {
    String cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      if (setStatePopup != null) setStatePopup(() {});
      return;
    }

    setState(() => _isSearching = true);
    if (setStatePopup != null) setStatePopup(() {});
    
    try {
      // Helper function to perform the actual API call
      Future<List<Data>> performSearch(String q) async {
        final result = await ApiService.getData(
          uri: "/models?category=&brand=&search=true&param=$q",
          isAuthorized: true,
          context: context,
        );
        if (result != null && result != "failed") {
          final response = GetSelectModelResponse.fromJson(result);
          return response.data ?? [];
        }
        return [];
      }

      // 1. Try with original trimmed query
      List<Data> results = await performSearch(cleanQuery);

      // 2. Fallback: replace spaces with dashes (e.g. "Samsung S23" -> "Samsung-S23")
      if (results.isEmpty && cleanQuery.contains(' ')) {
        results = await performSearch(cleanQuery.replaceAll(' ', '-'));
      }

      // 3. Fallback: remove spaces (e.g. "S 23" -> "S23")
      if (results.isEmpty && cleanQuery.contains(' ')) {
        results = await performSearch(cleanQuery.replaceAll(' ', ''));
      }

      // 4. Fallback: if multiple words, try the last word (usually the model number like "S23")
      if (results.isEmpty && cleanQuery.contains(' ')) {
        List<String> words = cleanQuery.split(' ');
        if (words.isNotEmpty && words.last.length > 1) {
          results = await performSearch(words.last);
        }
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
      if (setStatePopup != null) setStatePopup(() {});

      // SMART NAVIGATION: If exactly one match, jump straight to it
      if (results.length == 1) {
        final selection = results.first;
        Get.to(() => ServiceDetailScreen(
              brandId: selection.brand,
              catergoryId: selection.category,
              modelId: selection.id,
            ));
      }
    } catch (e) {
      debugPrint("Search Error: $e");
      setState(() => _isSearching = false);
      if (setStatePopup != null) setStatePopup(() {});
    }
  }

  void showMicPopup(BuildContext context) {
    _lastWords = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            _activePopupSetState = setStatePopup;
            
            // Start listening automatically when opened if not already
            if (!_isListening && _lastWords.isEmpty) {
              Future.microtask(() => _listen(setStatePopup));
            }

            return Container(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 12.h,
                bottom: MediaQuery.of(context).padding.bottom + 30.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.r),
                  topRight: Radius.circular(32.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      Text(
                        _isListening ? "Listening..." : "I Heard...",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _speechToText.stop();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 20.sp, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 10.w),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      _lastWords.isEmpty
                          ? "Tell us your mobile or laptop model"
                          : _lastWords,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.sp,
                        color: _lastWords.isEmpty ? Colors.grey.shade600 : AppColors.primary,
                        fontWeight: _lastWords.isEmpty ? FontWeight.w400 : FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 180.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Builder(
                          builder: (context) {
                            // Create a pulse effect based on time if sound level is low
                            double pulse = _isListening ? (sin(DateTime.now().millisecondsSinceEpoch / 150).abs() * 3) : 0;
                            double effectiveLevel = _level > 1 ? _level : pulse;
                            
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: (110 + (effectiveLevel * 2.5)).w,
                                  height: (110 + (effectiveLevel * 2.5)).w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withOpacity(0.1),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: (140 + (effectiveLevel * 4.5)).w,
                                  height: (140 + (effectiveLevel * 4.5)).w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withOpacity(0.05),
                                  ),
                                ),
                              ],
                            );
                          }
                        ),
                        GestureDetector(
                          onTap: () => _listen(setStatePopup),
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: Colors.white,
                              size: 36.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(5, (idx) {
                        double waveHeight = _isListening ? (15 + (idx % 2 == 0 ? _level * 3 : _level * 2)) : 5;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.symmetric(horizontal: 3.w),
                          width: 3.w,
                          height: waveHeight.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.3 + (idx * 0.1)),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ADD SEARCH RESULTS LIST HERE
                  if (_searchResults.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Results Found (${_searchResults.length})",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _searchResults = []);
                            setStatePopup(() {});
                          },
                          child: Text(
                            "Clear",
                            style: TextStyle(fontSize: 12.sp, color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      constraints: BoxConstraints(maxHeight: 250.h),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _searchResults.length,
                        separatorBuilder: (c, i) => Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          final name = (item.slug ?? '').replaceAll('-', ' ');
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 40.w,
                              height: 40.w,
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: item.logoUrl ?? '',
                                fit: BoxFit.contain,
                                errorWidget: (c, u, e) => const Icon(Icons.phone_android),
                              ),
                            ),
                            title: Text(
                              name,
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                            ),
                            trailing: Icon(Icons.chevron_right, size: 18.sp, color: Colors.grey.shade400),
                            onTap: () {
                              Navigator.pop(context);
                              Get.to(() => ServiceDetailScreen(
                                    brandId: item.brand,
                                    catergoryId: item.category,
                                    modelId: item.id,
                                  ));
                            },
                          );
                        },
                      ),
                    ),
                  ],
                  
                  if (_isSearching) ...[
                    SizedBox(height: 20.h),
                    const CircularProgressIndicator(),
                    SizedBox(height: 10.h),
                    const Text("Searching models..."),
                  ],
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      _speechToText.stop();
      _activePopupSetState = null;
      setState(() => _isListening = false);
    });
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _scrollController1.dispose();
    _sharedSearchController.dispose();
    _sharedSearchFocus.dispose();
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload fresh data when app comes back to foreground
      getActiveJobs(context);
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    // Reload fresh data when hot reloading
    getActiveJobs(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      extendBodyBehindAppBar: false,
      floatingActionButton: showScrollToTop
          ? FloatingActionButton(
              heroTag: null,
              onPressed: _scrollToTop,
              backgroundColor: AppColors.primary,
              mini: true,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await getActiveJobs(context);
            },
            child: Skeletonizer(
              enabled: _isLoading,
              ignoreContainers: true,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              centerTitle: false,
              pinned: false,
              floating: false,
              snap: false,
              elevation: 0,
              expandedHeight: 70.h,
// adjust for header height
              backgroundColor: Colors.transparent,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final percent =
                  ((constraints.maxHeight - kToolbarHeight) /
                      (90.h - kToolbarHeight))
                      .clamp(0.0, 1.0);

                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary, AppColors.pureWhite],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Opacity(
                          opacity: percent,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 8.h,
                                left: 5.w,
                                right: 5.w,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          "assets/Icon/Icon.png",
                                          height: 55.h,
                                        ),
                                        SizedBox(width: 8.w),
                                        Flexible(
                                          child: Text(
                                            "THE CELLPHONE DOCTOR",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.sp,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _scrollController.animateTo(
                                              220,
                                              duration: const Duration(milliseconds: 500),
                                              curve: Curves.easeInOut,
                                            );
                                          });
                                        },
                                        child: Icon(
                                          Icons.search,
                                          color: Colors.black,
                                          size: 26.sp,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      GestureDetector(
                                        onTap: () => showMicPopup(context),
                                        child: Icon(
                                          Icons.mic_none,
                                          color: Colors.black,
                                          size: 26.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 2.h)),

            SliverToBoxAdapter(
              child: SizedBox(
                height: size.height * 0.08,
                  child: Builder(
                    builder: (context) {
                      final hasCategories = getHomeListModel?.categories != null &&
                          getHomeListModel!.categories!.isNotEmpty;

                      if (_isLoading || !hasCategories) {
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          itemCount: 6,
                          separatorBuilder: (_, __) => SizedBox(width: 18 .w),
                          itemBuilder: (context, index) {
                            return _CategorySkeletonItem(
                                width: size.width * 0.20);
                          },
                        );
                      }

                      final categories = getHomeListModel!.categories!;

                      return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController1,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => SizedBox(width: 18.w),
                          itemBuilder: (context, index) {
                            final item = categories[index];
                            return GestureDetector(
                              onTap: () {
                                Get.to(() => ServiceView(
                                      categoryList:
                                          getHomeListModel!.categories!,
                                      initialIndex: index,
                                    ));
                              },
                              child: Container(
                                width: size.width * 0.20,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: buildAppNetworkImage(
                                        imageUrl: item.imageUrl ?? '',
                                        fit: BoxFit.contain,
                                        memCacheHeight: 200,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        item.name!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10.5.sp,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                  ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 2.h)),

            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: CarouselHome(
                  autoscroll: true,
                  showIndicator: true,
                  isLoading: _isLoading,
                  imageUrls: (getHomeListModel?.banner ?? [])
                      .map((b) => (b.image ?? ''))
                      .where((url) => url.isNotEmpty)
                      .toList(),
                ),
              ),
            ),

            SliverToBoxAdapter(child: kHeight5),

            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: ServiceSection(
                  spares: getHomeListModel?.spare ?? [],
                  categoryList: getHomeListModel?.categories ?? [],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: TopBrandSection(
                  brands: getHomeListModel?.brands,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: const OurProcessSection(),
              ),
            ),

            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: StoriesSection(),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 12.h)),

            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: Image.asset("assets/images/Chat Bot.png"),
              ),
            ),

            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: DidUKnow(blogs: getHomeListModel?.blog),
              ),
            ),

            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: StoreSection(stores: getHomeListModel?.store),
              ),
            ),

//why us section
            SliverToBoxAdapter(child: kHeight10),

            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: WhyUsSection(),
              ),
            ),

            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: TrustedSection(reviews: getHomeListModel?.review),
              ),
            ),

            SliverToBoxAdapter(child: kHeight10),

            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: FaqSection(faqs: getHomeListModel?.faq),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          ],
        ),
      ),
      ),
          // Floaty Sticky Header overlay
          if (showStickyHeaders)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: RepaintBoundary(
                child: Material(
                  elevation: 3,
                  color: Colors.transparent,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary, AppColors.pureWhite],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: _SearchHeader(
                              controller: _sharedSearchController,
                              focusNode: _sharedSearchFocus,
                              onMicTap: () => showMicPopup(context),
                              onSearch: _fetchSearchResults,
                            ),
                          ),
                          _CategoryHeader(context, getHomeListModel),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8.r),
      child: Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
      ),
    );
  }
}

class _CategorySkeletonItem extends StatelessWidget {
  final double width;

  const _CategorySkeletonItem({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 10.h,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: _SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.topCenter,
              child: _SkeletonBox(
                width: width * 0.8,
                height: 10.h,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Category Bar for AppBar (top)
Widget _buildCategoryBar() {
  final List<Map<String, String>> categories = [
    {
      "title": "Mobile Repair",
      "image": "assets/images/category/mobile_repair.png",
    },
    {
      "title": "Laptop Repair",
      "image": "assets/images/category/laptop_repair.png",
    },
    {
      "title": "Tablet Repair",
      "image": "assets/images/category/tablet_repair.png",
    },
    {"title": "Smart Watch", "image": "assets/images/category/smart_watch.png"},
    {"title": "Ear Buds", "image": "assets/images/category/earbuds.png"},
  ];

  return SizedBox(
    height: 70.h,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      itemCount: categories.length,
      separatorBuilder: (_, __) => SizedBox(width: 18.w),
      itemBuilder: (context, index) {
        final item = categories[index];
        return GestureDetector(
          onTap: () => Get.to(() => const ServiceView()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(item["image"]!, height: 35.h),
              SizedBox(height: 5.h),
              Text(
                item["title"]!,
                style: TextStyle(fontSize: 11.sp, color: Colors.white),
              ),
            ],
          ),
        );
      },
    ),
  );
}

// -----------------------------------------------------------------------------
// 🔹 Sticky Header Delegates
// -----------------------------------------------------------------------------

class _SafeAreaHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SafeAreaHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.pureWhite],
        ),
      ),
      child: SafeArea(top: true, bottom: false, child: child),
    );
  }

  @override
  double get maxExtent => 140.h;

  @override
  double get minExtent => 140.h;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onMicTap;
  final Function(String)? onSearch;

  const _SearchHeader({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onMicTap,
    this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.001),
            AppColors.pureWhite.withOpacity(0.001),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Autocomplete<Data>(
        textEditingController: controller,
        focusNode: focusNode,
        optionsBuilder: (TextEditingValue textEditingValue) async {
          String query = textEditingValue.text.trim();
          if (query.isEmpty) {
            return const Iterable<Data>.empty();
          }
          try {
            // Helper to fetch data
            Future<List<Data>> fetch(String q) async {
              final result = await ApiService.getData(
                uri: "/models?category=&brand=&search=true&param=$q",
                isAuthorized: true,
                context: context,
              );
              if (result != null && result != "failed") {
                final response = GetSelectModelResponse.fromJson(result);
                return response.data ?? [];
              }
              return [];
            }

            // 1. Try original query
            List<Data> options = await fetch(query);

            // 2. Fallback: dashes (Samsung S23 -> Samsung-S23)
            if (options.isEmpty && query.contains(' ')) {
              options = await fetch(query.replaceAll(' ', '-'));
            }

            // 3. Fallback: no spaces (S 23 -> S23)
            if (options.isEmpty && query.contains(' ')) {
              options = await fetch(query.replaceAll(' ', ''));
            }

            // 4. Fallback: last word (Samsung S23 -> S23)
            if (options.isEmpty && query.contains(' ')) {
              List<String> words = query.split(' ');
              if (words.isNotEmpty && words.last.length > 1) {
                options = await fetch(words.last);
              }
            }
            
            return options;
          } catch (e) {
            debugPrint("Search error: $e");
          }
          return const Iterable<Data>.empty();
        },
        displayStringForOption: (Data option) => (option.slug ?? '').replaceAll('-', ' '),
        onSelected: (Data selection) {
          Get.to(() => ServiceDetailScreen(
                brandId: selection.brand,
                catergoryId: selection.category,
                modelId: selection.id,
              ));
        },
        fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
            FocusNode focusNodeInternal, VoidCallback onFieldSubmitted) {
          // Sync external controller text with internal if needed, 
          // but better to just use the shared one.
          
          return Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: textEditingController, // USE THE PROVIDED CONTROLLER
                    focusNode: focusNodeInternal,      // USE THE PROVIDED FOCUS NODE
                    textInputAction: TextInputAction.search,
                    onSubmitted: (String value) {
                      if (onSearch != null) {
                        onSearch!(value);
                      }
                      onFieldSubmitted();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for mobile, laptop...',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: textEditingController,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () {
                        textEditingController.clear();
                        if (onSearch != null) onSearch!('');
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Icon(Icons.close, color: Colors.grey, size: 18.sp),
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTap: onMicTap,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.w, right: 4.w),
                    child: Icon(Icons.mic, color: AppColors.primary, size: 22.sp),
                  ),
                ),
              ],
            ),
          );
        },
        optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Data> onSelected,
            Iterable<Data> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: EdgeInsets.only(top: 4.h),
              width: MediaQuery.of(context).size.width - 28.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 320.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 12.w, top: 12.h, bottom: 6.h),
                        child: Text(
                          "Suggested",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Flexible(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                            indent: 64.w,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final Data option = options.elementAt(index);
                            final String displayName = (option.slug ?? '').replaceAll('-', ' ');

                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44.w,
                                      height: 44.h,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8.r),
                                        border: Border.all(color: Colors.grey.shade100),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6.r),
                                        child: CachedNetworkImage(
                                          imageUrl: option.logoUrl ?? '',
                                          fit: BoxFit.contain,
                                          errorWidget: (c, u, e) => Icon(
                                            Icons.phone_android,
                                            color: Colors.grey.shade300,
                                            size: 22.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            "Tap to select device",
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey.shade300,
                                      size: 18.sp,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _CategoryHeader(BuildContext context, GetHomeListModel? homeListModel) {
  // Show skeleton loader if data is loading or null
  if (homeListModel == null || homeListModel.categories == null) {
    return Container(
      height: 20.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Show 5 skeleton items
        separatorBuilder: (_, __) => SizedBox(width: 18.w),
        itemBuilder: (context, index) {
          return Container(
            width: 80.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
            ),
          );
        },
      ),
    );
  }

  return Container(
    width: double.infinity,
    decoration: const BoxDecoration(),
    child: SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: SizedBox(
          height: 20.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: homeListModel.categories!.length,
            separatorBuilder: (_, __) => SizedBox(width: 18.w),
            itemBuilder: (context, index) {
              final category = homeListModel.categories![index];
              return GestureDetector(
                onTap: () {
                  Get.to(() => ServiceView(
                    categoryList: homeListModel.categories!,
                    initialIndex: index,
                  ));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    category.name ?? 'Category',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}