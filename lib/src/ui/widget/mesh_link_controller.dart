import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mesh_sdk/mesh_sdk.dart';
import 'package:mesh_sdk/src/model/link_style.dart';
import 'package:mesh_sdk/src/model/mesh_error_type.dart';
import 'package:mesh_sdk/src/model/mesh_event.dart';
import 'package:mesh_sdk/src/model/mesh_internal_event.dart';
import 'package:mesh_sdk/src/ui/theme.dart';
import 'package:mesh_sdk/src/util/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MeshLinkController {
  MeshLinkController({
    required this.configuration,
    required this.onInternalEvent,
    required this.onEvent,
    required this.onError,
  });

  final MeshConfiguration configuration;
  final ValueChanged<MeshInternalEvent> onInternalEvent;
  final ValueChanged<MeshEvent> onEvent;
  final ValueChanged<MeshErrorType> onError;

  WebViewController? _webViewController;
  late Brightness _brightness;

  Brightness get brightness => _brightness;

  bool get isInitialized => _webViewController != null;

  WebViewController get webViewController {
    if (_webViewController == null) {
      throw StateError('WebViewController is not initialized');
    }

    return _webViewController!;
  }

  Future<bool> canGoBack() async => _webViewController?.canGoBack() ?? false;

  Future<void> goBack() async {
    await _webViewController?.runJavaScript('window.history.go(-1)');
  }

  Future<void> init(BuildContext context) async {
    try {
      final url = String.fromCharCodes(base64Decode(configuration.linkToken));
      final parsedUri = Uri.parse(url);
      final uri = parsedUri.replace(
        queryParameters: {
          ...parsedUri.queryParameters,
          'lng': configuration.language,
        },
      );

      await _initWebViewController(uri);
      if (!context.mounted) {
        return;
      }

      _initStyle(context, uri);
    } catch (e, s) {
      logger.severe('Error initializing MeshLinkPage: $e', e, s);
      onError(MeshErrorType.connectionError);
    }
  }

  Future<void> _initWebViewController(Uri uri) async {
    final linkHost = uri.host;

    final controller = WebViewController();
    await Future.wait([
      controller.setBackgroundColor(Colors.transparent),
      controller.setJavaScriptMode(JavaScriptMode.unrestricted),
      controller.setOnConsoleMessage(_onJsConsoleMessage),
      controller.addJavaScriptChannel(
        'JSBridge',
        onMessageReceived: (jsMessage) {
          _onJsMessageReceived(jsMessage.message);
        },
      ),
      controller.setNavigationDelegate(
        NavigationDelegate(
          onHttpAuthRequest: (navigation) {
            logger.info('HTTP auth request: ${navigation.host}');
          },
          onUrlChange: (navigation) {
            logger.info('URL changed: ${navigation.url}');
            final newUrl = navigation.url;
            if (newUrl == null) {
              return;
            }

            final newUri = Uri.parse(newUrl);
            if (newUri.host.endsWith('.app.link') ||
                newUri.host == 'apps.apple.com') {
              // App redirect - ignore.
              return;
            }

            onInternalEvent(ShowNativeNavBar(show: newUri.host != linkHost));
          },
          onNavigationRequest: (navigation) {
            logger.info('Navigation request: ${navigation.url}');
            final uri = Uri.parse(navigation.url);

            switch (uri.scheme) {
              case 'itms-appss':
                logger.info('Opening App Store link: $uri');
                _launchExternalUri(uri, isApp: true);
                return NavigationDecision.prevent;

              case 'market':
                logger.info('Opening Play Store link: $uri');
                _launchExternalUri(uri, isApp: true);
                return NavigationDecision.prevent;

              case 'intent':
                logger.info('Opening Android intent link: $uri');
                _launchExternalUri(uri, isApp: true);
                return NavigationDecision.prevent;

              default:
                return NavigationDecision.navigate;
            }
          },
          onHttpError: (error) {
            logger.warning(
              'HTTP error ${error.response?.statusCode}. '
              'Request (${error.request?.uri}). '
              'Response ${error.response?.uri}',
            );
          },
          onWebResourceError: (error) {
            logger.warning(
              'Web resource error: ${error.errorCode} - ${error.description}',
            );
          },
        ),
      ),
    ]);

    await controller.loadRequest(uri);

    final packageInfo = await PackageInfo.fromPlatform();
    final sdkVersion = packageInfo.version;

    final stringBuffer = StringBuffer(
      "window.meshSdkPlatform='flutter';"
      "window.meshSdkVersion='$sdkVersion';",
    );

    final integrationAccessTokens = configuration.integrationAccessTokens;
    if (integrationAccessTokens.isNotEmpty) {
      final tokensJson = integrationAccessTokens
          .map((e) => e.toJson())
          .toList();

      stringBuffer.write(
        'window.integrationAccessTokens=${json.encode(tokensJson)};',
      );
    }

    await controller.runJavaScript(stringBuffer.toString());
    _webViewController = controller;
  }

  void _initStyle(BuildContext context, Uri uri) {
    final linkStyleParam = uri.queryParameters['link_style'];
    final linkStyleString = linkStyleParam == null
        ? null
        : base64Decode(linkStyleParam);
    final linkStyleJson = linkStyleString == null
        ? null
        : json.decode(utf8.decode(linkStyleString));
    final linkStyle = linkStyleJson is Map<String, dynamic>
        ? LinkStyle.fromJson(linkStyleJson)
        : LinkStyle.fromJson(const {});

    final brightness = switch (linkStyle.theme) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };

    onBrightnessChanged(brightness);
    _brightness = brightness;
  }

  void _onJsConsoleMessage(JavaScriptConsoleMessage consoleMessage) {
    final log = switch (consoleMessage.level) {
      JavaScriptLogLevel.error => logger.severe,
      JavaScriptLogLevel.warning => logger.warning,
      JavaScriptLogLevel.debug => logger.fine,
      JavaScriptLogLevel.info => logger.info,
      JavaScriptLogLevel.log => logger.info,
    };

    log('(JS) ${consoleMessage.message}');
  }

  void _onJsMessageReceived(String message) {
    logger.fine('JS message received: $message');
    final json = jsonDecode(message);
    if (json is! Map<String, dynamic>) {
      logger.warning('Invalid JS message format: $message');
      return;
    }

    final internalEvent = MeshInternalEvent.fromJson(json);
    if (internalEvent != null) {
      logger.info('Internal event received: ${internalEvent.runtimeType}');
      onInternalEvent(internalEvent);
      return;
    }

    final event = MeshEvent.fromJson(json);
    if (event != null) {
      logger.info('Event received: ${event.runtimeType}');
      onEvent(event);
      return;
    }

    logger.warning('Unexpected JS message: $json');
  }

  void _launchExternalUri(Uri uri, {required bool isApp}) {
    unawaited(
      launchUrl(
        uri,
        mode: isApp
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      ),
    );
  }
}
