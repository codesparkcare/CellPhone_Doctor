import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Webscreen extends StatefulWidget {
  String url = "";
  String title = "";
  Webscreen({super.key, required this.url,required this.title});

  @override
  State<Webscreen> createState() => _WebscreenState();
}

class _WebscreenState extends State<Webscreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: WebViewWidget(controller: controller),
    );
  }
}
