import 'dart:ui';

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class MockWebViewController extends PlatformWebViewController {
  MockWebViewController()
    : super.implementation(const PlatformWebViewControllerCreationParams());

  Color? _backgroundColor;

  Color? get backgroundColor => _backgroundColor;

  @override
  Future<void> setBackgroundColor(Color color) async {
    _backgroundColor = color;
  }

  JavaScriptMode? _javaScriptMode;

  JavaScriptMode? get javaScriptMode => _javaScriptMode;

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {
    _javaScriptMode = javaScriptMode;
  }

  @override
  Future<void> setOnConsoleMessage(
    void Function(JavaScriptConsoleMessage consoleMessage) onConsoleMessage,
  ) async {
    // Do nothing
  }

  String? _javaScriptChannel;

  String? get javaScriptChannel => _javaScriptChannel;

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {
    if (_javaScriptChannel != null) {
      throw StateError('JavaScript channel already exists');
    }

    _javaScriptChannel = javaScriptChannelParams.name;
  }

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {
    // Do nothing
  }

  Uri? _requestUri;

  Uri? get requestUri => _requestUri;

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    _requestUri = params.uri;
  }

  String? _lastJavaScript;

  String? get lastJavaScript => _lastJavaScript;

  @override
  Future<void> runJavaScript(String javaScript) async {
    _lastJavaScript = javaScript;
  }
}
