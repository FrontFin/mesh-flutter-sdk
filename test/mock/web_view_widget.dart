import 'package:flutter/material.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class MockWebViewWidget extends PlatformWebViewWidget {
  MockWebViewWidget({required PlatformWebViewController controller})
    : super.implementation(
        PlatformWebViewWidgetCreationParams(controller: controller),
      );

  @override
  Widget build(BuildContext context) {
    return const Text('Mock WebView Widget');
  }
}
