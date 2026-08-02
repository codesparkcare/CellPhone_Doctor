import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget buildAppNetworkImage({
  required String imageUrl,
  BoxFit fit = BoxFit.contain,
  double? width,
  double? height,
  int? memCacheHeight,
  int? memCacheWidth,
  Widget Function(BuildContext, String)? placeholder,
  Widget Function(BuildContext, String, dynamic)? errorWidget,
}) {
  final String trimmed = imageUrl.trim();
  if (trimmed.isEmpty) {
    if (errorWidget != null) {
      return Builder(builder: (ctx) => errorWidget(ctx, '', 'empty'));
    }
    return _defaultFallback();
  }

  final String cleanUrl = Uri.encodeFull(trimmed);

  if (kIsWeb) {
    return Image.network(
      cleanUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        final String stripped = cleanUrl.replaceFirst(RegExp(r'^https?://'), '');
        final String webProxyUrl = 'https://wsrv.nl/?url=$stripped&output=webp';
        return Image.network(
          webProxyUrl,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (ctx, err, st) {
            if (errorWidget != null) {
              return errorWidget(ctx, cleanUrl, err);
            }
            return _defaultFallback();
          },
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        if (placeholder != null) {
          return placeholder(context, cleanUrl);
        }
        return Skeletonizer(
          enabled: true,
          child: Container(color: Colors.grey.shade100),
        );
      },
    );
  }

  return CachedNetworkImage(
    imageUrl: cleanUrl,
    fit: fit,
    width: width,
    height: height,
    memCacheHeight: memCacheHeight,
    memCacheWidth: memCacheWidth,
    placeholder: placeholder != null
        ? (context, url) => placeholder(context, url)
        : (context, url) => Skeletonizer(
              enabled: true,
              child: Container(color: Colors.grey.shade100),
            ),
    errorWidget: errorWidget != null
        ? (context, url, error) => errorWidget(context, url, error)
        : (context, url, error) => _defaultFallback(),
  );
}

Widget _defaultFallback() {
  return Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(
      Icons.build_circle_rounded,
      color: Color(0xFF2563EB),
      size: 24,
    ),
  );
}
