import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class MockNavigationDelegate extends PlatformNavigationDelegate {
  MockNavigationDelegate()
    : super.implementation(const PlatformNavigationDelegateCreationParams());

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {
    // Do nothing
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
