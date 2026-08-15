import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class Webscreen extends StatefulWidget {
  final String url;
  final String title;
  const Webscreen({super.key, required this.url, required this.title});

  @override
  State<Webscreen> createState() => _WebscreenState();
}

class _WebscreenState extends State<Webscreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controllerInstance =
        WebViewController.fromPlatformCreationParams(params);

    controllerInstance
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));

    if (controllerInstance.platform is AndroidWebViewController) {
      (controllerInstance.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    controller = controllerInstance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: WebViewWidget(controller: controller),
    );
  }
}


