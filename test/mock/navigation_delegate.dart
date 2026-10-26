import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class MockNavigationDelegate extends PlatformNavigationDelegate {
  MockNavigationDelegate()
    : super.implementation(const PlatformNavigationDelegateCreationParams());

  NavigationRequestCallback? _onNavigationRequest;

  /// Simulates the WebView asking whether it may navigate to [url].
  Future<NavigationDecision?> simulateNavigationRequest(String url) async =>
      _onNavigationRequest?.call(
        NavigationRequest(url: url, isMainFrame: true),
      );

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {
    _onNavigationRequest = onNavigationRequest;
  }

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {
    // Do nothing
  }

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {
    // Do nothing
  }

  @override
  Future<void> setOnHttpAuthRequest(
    HttpAuthRequestCallback onHttpAuthRequest,
  ) async {
    // Do nothing
  }

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback onHttpError) async {
    // Do nothing
  }
}
