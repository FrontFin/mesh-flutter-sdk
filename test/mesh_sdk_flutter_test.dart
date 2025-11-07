import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/mesh_sdk_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class TestApp extends StatelessWidget {
  const TestApp({required this.configuration, super.key});

  final MeshConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () =>
                MeshSdk.show(context, configuration: configuration),
            child: const Text('Start'),
          ),
        ),
      ),
    );
  }
}

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

class MockWebViewController extends PlatformWebViewController {
  MockWebViewController()
    : super.implementation(const PlatformWebViewControllerCreationParams());

  Color? _backgroundColor;

  @override
  Future<void> setBackgroundColor(Color color) async {
    _backgroundColor = color;
  }

  JavaScriptMode? _javaScriptMode;

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

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    _requestUri = params.uri;
  }

  String? _lastJavaScript;

  @override
  Future<void> runJavaScript(String javaScript) async {
    _lastJavaScript = javaScript;
  }
}

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

void main() {
  MeshErrorType? errorType;
  late MockWebViewController webViewController;
  late MockNavigationDelegate navigationDelegate;
  late MockWebViewWidget webViewWidget;

  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: '',
      packageName: '',
      version: '0.0.1',
      buildNumber: '',
      buildSignature: '',
    );
  });

  setUp(() {
    errorType = null;
    webViewController = MockWebViewController();
    navigationDelegate = MockNavigationDelegate();
    webViewWidget = MockWebViewWidget(controller: webViewController);
    WebViewPlatform.instance = MockWebViewPlatform(
      webViewController: webViewController,
      navigationDelegate: navigationDelegate,
      mockWebViewWidget: webViewWidget,
    );
  });

  group('Link Token', () {
    testWidgets('Wrong base64 should exit', (tester) async {
      const linkToken = 'not_base64_encoded';
      final configuration = MeshConfiguration(
        linkToken: linkToken,
        onExit: (error) => errorType = error,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(errorType, MeshErrorType.connectionError);
    });

    testWidgets('Missing scheme should exit', (tester) async {
      final linkToken = base64Encode(utf8.encode('test_linktoken'));
      final configuration = MeshConfiguration(
        linkToken: linkToken,
        onExit: (error) => errorType = error,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(errorType, MeshErrorType.connectionError);
    });
  });

  group('Language', () {
    testWidgets('Default language param is "en"', (tester) async {
      const rawUrl = 'https://test_linktoken';
      final linkToken = base64Encode(utf8.encode(rawUrl));
      final configuration = MeshConfiguration(linkToken: linkToken);

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(webViewController._requestUri, Uri.parse('$rawUrl?lng=en'));
    });

    testWidgets('Language param is used', (tester) async {
      const rawUrl = 'https://test_linktoken';
      final linkToken = base64Encode(utf8.encode(rawUrl));
      final configuration = MeshConfiguration(
        linkToken: linkToken,
        language: 'de',
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(webViewController._requestUri, Uri.parse('$rawUrl?lng=de'));
    });
  });

  group('WebView', () {
    testWidgets('WebViewController is initialized', (tester) async {
      const rawUrl = 'https://test_linktoken';
      final linkToken = base64Encode(utf8.encode(rawUrl));
      final configuration = MeshConfiguration(linkToken: linkToken);

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(webViewController._backgroundColor, Colors.transparent);
      expect(webViewController._javaScriptMode, JavaScriptMode.unrestricted);
      expect(webViewController._javaScriptChannel, 'JSBridge');
      expect(webViewController._requestUri, Uri.parse('$rawUrl?lng=en'));
      expect(
        webViewController._lastJavaScript,
        "window.meshSdkPlatform='flutter';"
        "window.meshSdkVersion='0.0.1';",
      );
      expect(find.text('Mock WebView Widget'), findsOneWidget);
    });

    testWidgets('Integration access tokens are passed to JS', (tester) async {
      const rawUrl = 'https://test_linktoken';
      final linkToken = base64Encode(utf8.encode(rawUrl));
      final configuration = MeshConfiguration(
        linkToken: linkToken,
        integrationAccessTokens: const [
          IntegrationAccessToken(
            accountId: 'id',
            accountName: 'name',
            accessToken: 'token',
            brokerType: 'brokerType',
            brokerName: 'brokerName',
          ),
        ],
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(
        webViewController._lastJavaScript,
        "window.meshSdkPlatform='flutter';"
        "window.meshSdkVersion='0.0.1';"
        'window.integrationAccessTokens=[{'
        '"accountId":"id",'
        '"accountName":"name",'
        '"accessToken":"token",'
        '"brokerType":"brokerType",'
        '"brokerName":"brokerName"'
        '}];',
      );
    });
  });
}
