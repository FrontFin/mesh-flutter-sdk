import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class MockWebViewPlatform extends WebViewPlatform {
  MockWebViewPlatform({
    required this.webViewController,
    required this.navigationDelegate,
    required this.mockWebViewWidget,
  });

  final PlatformWebViewController webViewController;
  final PlatformNavigationDelegate navigationDelegate;
  final PlatformWebViewWidget mockWebViewWidget;

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return webViewController;
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return navigationDelegate;
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return mockWebViewWidget;
  }
}
