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
  const rawUrl = 'https://test_linktoken';
  late String validLinkToken;

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
    validLinkToken = base64Encode(utf8.encode(rawUrl));
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
      final configuration = MeshConfiguration(linkToken: validLinkToken);

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(webViewController.requestUri, Uri.parse('$rawUrl?lng=en'));
    });

    testWidgets('Language param is used', (tester) async {
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        language: 'de',
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(webViewController.requestUri, Uri.parse('$rawUrl?lng=de'));
    });

    testWidgets('language: "system" resolves to platform locale', (
      tester,
    ) async {
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        language: 'system',
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      final expectedLng =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      expect(webViewController.requestUri?.queryParameters['lng'], expectedLng);
      expect(webViewController.requestUri?.path, Uri.parse(rawUrl).path);
    });
  });

  group('URL query parameters', () {
    testWidgets('displayFiatCurrency adds fiatCur to request URI', (
      tester,
    ) async {
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        displayFiatCurrency: 'EUR',
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(webViewController.requestUri?.queryParameters['lng'], 'en');
      expect(webViewController.requestUri?.queryParameters['fiatCur'], 'EUR');
    });

    testWidgets('theme adds th=light to request URI', (tester) async {
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        theme: ThemeMode.light,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(webViewController.requestUri?.queryParameters['th'], 'light');
    });

    testWidgets('theme adds th=dark to request URI', (tester) async {
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        theme: ThemeMode.dark,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(webViewController.requestUri?.queryParameters['th'], 'dark');
    });

    testWidgets('theme adds th=system to request URI', (tester) async {
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        theme: ThemeMode.system,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(webViewController.requestUri?.queryParameters['th'], 'system');
    });

    testWidgets('configuration theme (th) takes precedence over link_style', (
      tester,
    ) async {
      final linkStyleJson = '{"th":"dark"}';
      final linkStyleEncoded = base64Encode(utf8.encode(linkStyleJson));
      final urlWithLinkStyle =
          'https://test_linktoken?link_style=$linkStyleEncoded';
      final tokenWithLinkStyle = base64Encode(utf8.encode(urlWithLinkStyle));

      final configuration = MeshConfiguration(
        linkToken: tokenWithLinkStyle,
        theme: ThemeMode.light,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(webViewController.requestUri?.queryParameters['th'], 'light');
    });
  });

  group('Domain Whitelist', () {
    testWidgets('Domain whitelist is enabled by default', (tester) async {
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        onError: (error) => errorType = error,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(configuration.isDomainWhitelistEnabled, true);
      expect(errorType, null);
    });
  });

  group('WebView', () {
    testWidgets('WebViewController is initialized', (tester) async {
      final configuration = MeshConfiguration(linkToken: validLinkToken);

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(webViewController.backgroundColor, Colors.transparent);
      expect(webViewController.javaScriptMode, JavaScriptMode.unrestricted);
      expect(webViewController.javaScriptChannel, 'JSBridge');
      expect(webViewController.requestUri, Uri.parse('$rawUrl?lng=en'));

      // Simulate the "loaded" event from JS to trigger _onLoaded()
      webViewController.simulateJsMessage('{"type":"loaded","payload":{}}');
      await tester.pumpAndSettle();

      expect(
        webViewController.lastJavaScript,
        "window.meshSdkPlatform='flutter';"
        "window.meshSdkVersion='0.0.1';",
      );
      expect(find.text('Mock WebView Widget'), findsOneWidget);
    });

    testWidgets('Integration access tokens are passed to JS', (tester) async {
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
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

      // Simulate the "loaded" event from JS to trigger _onLoaded()
      webViewController.simulateJsMessage('{"type":"loaded","payload":{}}');
      await tester.pumpAndSettle();

      expect(
        webViewController.lastJavaScript,
        "window.meshSdkPlatform='flutter';"
        "window.meshSdkVersion='0.0.1';"
        'window.accessTokens=[{'
        '"accountId":"id",'
        '"accountName":"name",'
        '"accessToken":"token",'
        '"brokerType":"brokerType",'
        '"brokerName":"brokerName"'
        '}];',
      );
    });
  });

  group('Callbacks', () {
    testWidgets('onEvent is called for events', (tester) async {
      MeshEvent? receivedEvent;
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        onEvent: (event) => receivedEvent = event,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Simulate an integrationSelected event from JS
      webViewController.simulateJsMessage('''
          {
            "type": "integrationSelected",
            "payload": {
              "integrationType": "robinhood",
              "integrationName":"Robinhood"
              }
            }
        ''');
      await tester.pumpAndSettle();

      expect(receivedEvent, isA<IntegrationSelectedEvent>());
      final event = receivedEvent! as IntegrationSelectedEvent;
      expect(event.type, 'robinhood');
      expect(event.name, 'Robinhood');
    });

    testWidgets('onEvent is called for LoadedEvent', (tester) async {
      MeshEvent? receivedEvent;
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        onEvent: (event) => receivedEvent = event,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      webViewController.simulateJsMessage('{"type":"loaded","payload":{}}');
      await tester.pumpAndSettle();

      expect(receivedEvent, isA<LoadedEvent>());
    });

    testWidgets('onSuccess is called on done event', (tester) async {
      SuccessPayload? payload;
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        onSuccess: (p) => payload = p,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      webViewController.simulateJsMessage('''
        {
          "type": "done",
          "payload": {
            "page": "done",
            "selectedIntegration": {
              "id": "123",
              "name": "Test Integration"
              }
            }
          }''');
      await tester.pumpAndSettle();

      expect(payload, isA<IntegrationSuccessPayload>());
      final success = payload! as IntegrationSuccessPayload;
      expect(success.page, 'done');
      expect(success.integration.id, '123');
      expect(success.integration.name, 'Test Integration');
    });

    testWidgets('onSuccess is called with TransferSuccessPayload', (
      tester,
    ) async {
      SuccessPayload? payload;
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        onSuccess: (p) => payload = p,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      webViewController.simulateJsMessage('''
        {
          "type": "done",
          "payload": {
            "page": "transferComplete",
            "selectedIntegration": {
              "id":"456",
              "name":"Coinbase"
            },
            "transfer": {
              "amount": 100.5,
              "symbol":"ETH",
              "transactionId":
              "tx-abc"
            }
          }
        }''');
      await tester.pumpAndSettle();

      expect(payload, isA<TransferSuccessPayload>());
      final success = payload! as TransferSuccessPayload;
      expect(success.page, 'transferComplete');
      expect(success.integration.name, 'Coinbase');
      expect(success.transfer.amount, 100.5);
      expect(success.transfer.symbol, 'ETH');
      expect(success.transfer.transactionId, 'tx-abc');
    });

    testWidgets('onError is called with userCancelled on close', (
      tester,
    ) async {
      MeshErrorType? error;
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        onError: (e) => error = e,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      webViewController.simulateJsMessage(
        '{"type":"close","payload":{"page":"closed"}}',
      );
      await tester.pumpAndSettle();

      // Close triggers onSuccess, not onError
      expect(error, isNull);
    });

    testWidgets('multiple events trigger onEvent multiple times', (
      tester,
    ) async {
      final events = <MeshEvent>[];
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        onEvent: events.add,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      webViewController.simulateJsMessage('{"type":"loaded","payload":{}}');
      await tester.pumpAndSettle();

      webViewController.simulateJsMessage(
        '{"type":"credentialsEntered","payload":{}}',
      );
      await tester.pumpAndSettle();

      webViewController.simulateJsMessage(
        '{"type":"transferStarted","payload":{}}',
      );
      await tester.pumpAndSettle();

      expect(events, hasLength(3));
      expect(events[0], isA<LoadedEvent>());
      expect(events[1], isA<CredentialsEnteredEvent>());
      expect(events[2], isA<TransferStartedEvent>());
    });

    testWidgets('onEvent receives TransferPreviewedEvent with full payload', (
      tester,
    ) async {
      MeshEvent? receivedEvent;
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        onEvent: (event) => receivedEvent = event,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      webViewController.simulateJsMessage('''
        {
          "type": "transferPreviewed",
          "payload": {
            "amount": 50.5,
            "symbol": "USDC",
            "toAddress": "0xabc",
            "networkId": "polygon",
            "previewId": "preview-123",
            "networkName": "Polygon",
            "amountInFiat": 50.5
          }
        }''');
      await tester.pumpAndSettle();

      expect(receivedEvent, isA<TransferPreviewedEvent>());
      final event = receivedEvent! as TransferPreviewedEvent;
      expect(event.amount, 50.5);
      expect(event.symbol, 'USDC');
      expect(event.toAddress, '0xabc');
      expect(event.networkId, 'polygon');
      expect(event.previewId, 'preview-123');
      expect(event.networkName, 'Polygon');
      expect(event.amountInFiat, 50.5);
    });
  });

  group('onIntegrationConnected Callback', () {
    testWidgets('is called with DelayedAuthPayload', (tester) async {
      IntegrationConnectedEvent? event;
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        onIntegrationConnected: (e) => event = e,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      webViewController.simulateJsMessage('''
        {
          "type": "delayedAuthentication",
          "payload": {
            "brokerType": "robinhood",
            "refreshToken": "token-123",
            "brokerName": "Robinhood",
            "brokerBrandInfo": {"brokerLogo": "https://logo.url"}
          }
        }''');
      await tester.pumpAndSettle();

      expect(event, isNotNull);
      expect(event!.payload, isA<DelayedAuthPayload>());
      final payload = event!.payload as DelayedAuthPayload;
      expect(payload.brokerType, 'robinhood');
      expect(payload.refreshToken, 'token-123');
      expect(payload.brokerName, 'Robinhood');
    });

    testWidgets('is called with AccessTokenPayload', (tester) async {
      IntegrationConnectedEvent? event;
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        onIntegrationConnected: (e) => event = e,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      webViewController.simulateJsMessage('''
        {
          "type": "brokerageAccountAccessToken",
          "payload": {
            "accountTokens": [
              {
                "account": {
                  "accountId": "acc-123",
                  "accountName": "Main Account"
                },
                "accessToken": "access-token-xyz"
              }
            ],
            "brokerBrandInfo": {"brokerLogo": null},
            "brokerType": "coinbase",
            "brokerName": "Coinbase"
          }
        }''');
      await tester.pumpAndSettle();

      expect(event, isNotNull);
      expect(event!.payload, isA<AccessTokenPayload>());
      final payload = event!.payload as AccessTokenPayload;
      expect(payload.brokerType, 'coinbase');
      expect(payload.brokerName, 'Coinbase');
      expect(payload.accountTokens, hasLength(1));
      expect(payload.accountTokens.first.accessToken, 'access-token-xyz');
    });
  });

  group('onTransferFinished Callback', () {
    testWidgets('is called with success payload', (tester) async {
      TransferFinishedEvent? event;
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        onTransferFinished: (e) => event = e,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      webViewController.simulateJsMessage('''
        {
          "type": "transferFinished",
          "payload": {
            "status": "success",
            "txId": "tx-123",
            "fromAddress": "0xfrom",
            "toAddress": "0xto",
            "symbol": "ETH",
            "amount": 1.5,
            "networkId": "ethereum"
          }
        }''');
      await tester.pumpAndSettle();

      expect(event, isNotNull);
      expect(event!.payload, isA<TransferFinishedSuccessPayload>());
      final payload = event!.payload as TransferFinishedSuccessPayload;
      expect(payload.txId, 'tx-123');
      expect(payload.symbol, 'ETH');
      expect(payload.amount, 1.5);
    });

    testWidgets('is called with error payload', (tester) async {
      TransferFinishedEvent? event;
      final configuration = MeshConfiguration(
        linkToken: validLinkToken,
        onTransferFinished: (e) => event = e,
      );

      await tester.pumpWidget(TestApp(configuration: configuration));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      webViewController.simulateJsMessage('''
        {
          "type": "transferFinished",
          "payload": {
            "status": "error",
            "errorMessage": "Transfer failed: insufficient funds"
          }
        }''');
      await tester.pumpAndSettle();

      expect(event, isNotNull);
      expect(event!.payload, isA<TransferFinishedErrorPayload>());
      final payload = event!.payload as TransferFinishedErrorPayload;
      expect(payload.errorMessage, 'Transfer failed: insufficient funds');
    });
  });
}
