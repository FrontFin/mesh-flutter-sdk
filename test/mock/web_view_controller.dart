import 'dart:ui';

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class MockWebViewController extends PlatformWebViewController {
  MockWebViewController()
    : super.implementation(const PlatformWebViewControllerCreationParams());

  final _jsChannels = <String, void Function(JavaScriptMessage)>{};

  /// Simulates receiving a JavaScript message through the JSBridge channel.
  void simulateJsMessage(String message) {
    _jsChannels['JSBridge']?.call(JavaScriptMessage(message: message));
  }

  /// Simulates a target="_blank" navigation via the MeshNavigator channel.
  void simulateBlankTargetNavigation(String url) {
    _jsChannels['MeshNavigator']?.call(JavaScriptMessage(message: url));
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

  Set<String> get javaScriptChannels => _jsChannels.keys.toSet();

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {
    _jsChannels[javaScriptChannelParams.name] =
        javaScriptChannelParams.onMessageReceived;
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
