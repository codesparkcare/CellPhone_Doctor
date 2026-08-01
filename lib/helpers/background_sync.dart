import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../ApiService/ApiService.dart';
import '../models/app/getSelectModelResponse.dart';
import '../models/app/GetSparePartsResponseModelNew.dart' hide Data;
import '../models/app/getSpareResponseModel.dart';
import '../helpers/auth_helper.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      debugPrint("Native called background task: $task");

      final prefs = await SharedPreferences.getInstance();
      
      // Get recently viewed category/brand pairs
      List<String> recentPairs = prefs.getStringList("recent_category_brand_pairs") ?? [];
      
      if (recentPairs.isEmpty) {
        return Future.value(true);
      }

      String userid = await AuthHelper.getString("userid") ?? "";

      // Limit to 3 most recent combinations to avoid 429
      final pairsToProcess = recentPairs.take(3).toList();

      for (String pairStr in pairsToProcess) {
        final parts = pairStr.split('_');
        if (parts.length != 2) continue;
        
        final categoryId = parts[0];
        final brandId = parts[1];

        // 1. Fetch models
        final cacheKey = "${categoryId}_${brandId}";
        var result = await ApiService.getData(
          uri: "/models?category=$categoryId&brand=$brandId",
          isAuthorized: true,
          context: null,
        );

        if (result != null && result is Map) {
          final response = GetSelectModelResponse.fromJson(result);
          final fetchedModels = response.data ?? [];
          
          fetchedModels.sort((a, b) {
            final seqA = a.sequence ?? double.infinity;
            final seqB = b.sequence ?? double.infinity;
            if (seqA != seqB) return seqA.compareTo(seqB);
            final idA = a.id ?? 0;
            final idB = b.id ?? 0;
            return idA.compareTo(idB);
          });

          // Save to SharedPreferences for SelectModelScreen to use instantly
          final jsonStr = jsonEncode(fetchedModels.map((m) => m.toJson()).toList());
          prefs.setString("models_cache_$cacheKey", jsonStr);
          
          // 2. Fetch categories for the top 5 models of this brand to avoid 429
          int maxModels = fetchedModels.length > 5 ? 5 : fetchedModels.length;
          
          for (int i = 0; i < maxModels; i++) {
            await Future.delayed(const Duration(milliseconds: 1500));
            
            final modelId = fetchedModels[i].id;
            final catCacheKey = "${categoryId}_${brandId}_${modelId}";
            
            var catResult = await ApiService.getData(
              uri: "/spare/$categoryId",
              isAuthorized: true,
              context: null,
            );
            
            if (catResult != null && catResult is Map) {
              GetSpareResponseModel getHomeListModel = GetSpareResponseModel.fromJson(catResult);
              List<dynamic> rawCategories = getHomeListModel.data ?? [];
              
              List<dynamic> validCategories = [];
              
              for (var cat in rawCategories) {
                String spareId = cat.id.toString();
                
                // Fetch products to verify if category has spares
                var prodResult;
                if (userid.isNotEmpty) {
                  prodResult = await ApiService.getData(
                    uri: "/products?category=$categoryId&brand=$brandId&model=$modelId&spare=$spareId&user=$userid",
                    isAuthorized: true,
                    context: null,
                  );
                } else {
                  prodResult = await ApiService.getData(
                    uri: "/products?category=$categoryId&brand=$brandId&model=$modelId&spare=$spareId",
                    isAuthorized: true,
                    context: null,
                  );
                }

                bool hasProducts = false;
                if (prodResult != null && prodResult is Map && prodResult['status'] == true) {
                  var data = prodResult['data'] as List;
                  for (var product in data) {
                    var spares = product['spare'] as List?;
                    if (spares != null && spares.isNotEmpty) {
                      hasProducts = true;
                      break;
                    }
                  }
                }

                if (hasProducts) {
                  validCategories.add(cat);
                }
                
                // Slight delay to avoid hitting rate limit
                await Future.delayed(const Duration(milliseconds: 1000));
              }
              
              // Save filtered categories to SharedPreferences
              final catJsonStr = jsonEncode(validCategories.map((c) => c.toJson()).toList());
              prefs.setString("filtered_categories_v2_$catCacheKey", catJsonStr);
            }
          }
        }
      }

      return Future.value(true);
    } catch (err) {
      debugPrint("Background task error: $err");
      return Future.value(false); // return false to signal failure
    }
  });
}
