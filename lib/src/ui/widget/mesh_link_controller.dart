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
      controller.setOnConsoleMessage((consoleMessage) {
        // TODO: move event parsing to onMessageReceived
        final message = consoleMessage.message;
        logger.info('Console message (${consoleMessage.level}): $message');
        if (message.startsWith('Failed to send a message with webkit')) {
          return;
        }

        final match = RegExp(r'\(type:(.*?)\)').firstMatch(message);
        final eventString = match?.group(1);

        final internalEvent = MeshInternalEvent.fromString({
          'type': eventString,
        });
        if (internalEvent != null) {
          logger.info('Internal event received: $internalEvent');
          onInternalEvent(internalEvent);
          return;
        }

        final event = MeshEvent.fromJson({'type': eventString});
        if (event != null) {
          logger.info('Event received: $event');
          onEvent(event);
        }
      }),
      controller.addJavaScriptChannel(
        'JSBridge',
        onMessageReceived: (json) {
          logger.info('JS message received: ${json.message}');
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

            // TODO: use showNativeNavbar(true/false) event to show/hide
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
                unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
                return NavigationDecision.prevent;

              default:
                return NavigationDecision.navigate;
            }
          },
          onHttpError: (error) {
            logger.warning('HTTP error: ${error.response}');
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
}
