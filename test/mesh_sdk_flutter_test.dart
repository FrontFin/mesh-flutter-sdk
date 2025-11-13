import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/mesh_sdk_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'mock/app.dart';
import 'mock/navigation_delegate.dart';
import 'mock/web_view.dart';
import 'mock/web_view_controller.dart';
import 'mock/web_view_widget.dart';

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
        onError: (error) => errorType = error,
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
        onError: (error) => errorType = error,
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

      expect(webViewController.requestUri, Uri.parse('$rawUrl?lng=en'));
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

      expect(webViewController.requestUri, Uri.parse('$rawUrl?lng=de'));
    });
  });

  group('Domain Whitelist', () {
    testWidgets('Domain whitelist is enabled by default', (tester) async {
      const rawUrl = 'https://test_linktoken';
      final linkToken = base64Encode(utf8.encode(rawUrl));
      final configuration = MeshConfiguration(
        linkToken: linkToken,
        onError: (error) => errorType = error,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'https://google.com');
      await tester.tap(find.byType(FilledButton));

      expect(configuration.isDomainWhitelistEnabled, true);
      expect(errorType, null);
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

      expect(webViewController.backgroundColor, Colors.transparent);
      expect(webViewController.javaScriptMode, JavaScriptMode.unrestricted);
      expect(webViewController.javaScriptChannel, 'JSBridge');
      expect(webViewController.requestUri, Uri.parse('$rawUrl?lng=en'));
      expect(
        webViewController.lastJavaScript,
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
        webViewController.lastJavaScript,
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
