import 'dart:ui';

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class MockWebViewController extends PlatformWebViewController {
  MockWebViewController()
    : super.implementation(const PlatformWebViewControllerCreationParams());

  void Function(JavaScriptMessage)? _onMessageReceived;

  /// Simulates receiving a JavaScript message through the JSBridge channel.
  void simulateJsMessage(String message) {
    _onMessageReceived?.call(JavaScriptMessage(message: message));
  }

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
    _onMessageReceived = javaScriptChannelParams.onMessageReceived;
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

  bool _canGoBack = false;

  /// Controls what [canGoBack] returns in tests.
  // ignore: avoid_setters_without_getters
  set canGoBackResult(bool value) => _canGoBack = value;

  @override
  Future<bool> canGoBack() async => _canGoBack;

  String? _lastJavaScript;

  String? get lastJavaScript => _lastJavaScript;

  @override
  Future<void> runJavaScript(String javaScript) async {
    _lastJavaScript = javaScript;
  }
}
