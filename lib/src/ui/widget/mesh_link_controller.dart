import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesh_sdk_flutter/src/mesh_sdk_version.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_error_type.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_event.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_internal_event.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_result.dart';
import 'package:mesh_sdk_flutter/src/model/success/success.dart';
import 'package:mesh_sdk_flutter/src/ui/theme.dart';
import 'package:mesh_sdk_flutter/src/util/app_url.dart';
import 'package:mesh_sdk_flutter/src/util/constants.dart';
import 'package:mesh_sdk_flutter/src/util/link_uri.dart';
import 'package:mesh_sdk_flutter/src/util/logger.dart';
import 'package:mesh_sdk_flutter/src/util/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

const _activityNotFoundCode = 'ACTIVITY_NOT_FOUND';

/// A controller for managing the Mesh Link web view.
/// This uses [WebViewController] and adds our own logic on top.
class MeshLinkController {
  MeshLinkController({
    required this.configuration,
    required this.onInternalEvent,
    required this.onEvent,
    required this.onError,
    required this.onSuccess,
  });

  final MeshConfiguration configuration;
  final ValueChanged<MeshInternalEvent> onInternalEvent;
  final ValueChanged<MeshEvent> onEvent;
  final ValueChanged<MeshErrorType> onError;
  final ValueChanged<SuccessPayload> onSuccess;

  WebViewController? _webViewController;
  late Brightness _brightness;
  bool _isExternalAppOpened = false;

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

  /// Initialize the controller using [configuration].
  Future<void> init(BuildContext context) async {
    try {
      final uri = buildLinkUri(configuration);

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
            if (isAppUrlChange(newUrl)) {
              logger.info('app redirect: $newUri');
              unawaited(_launchExternalUri(newUri, isApp: true));
              return;
            }

            final isLinkHost = newUri.host == linkHost;
            if (_isExternalAppOpened && isLinkHost) {
              _isExternalAppOpened = false;
            }

            onInternalEvent(ShowNativeNavBar(show: !isLinkHost));
          },
          onNavigationRequest: (navigation) {
            logger.info('Navigation request: ${navigation.url}');
            final uri = Uri.parse(navigation.url);

            if (isExternallyOpenedOrigin(navigation.url)) {
              logger.info(
                'Externally opened origin, opening in external browser: '
                '${navigation.url}',
              );
              unawaited(_launchExternalUri(uri, isApp: false));
              return NavigationDecision.prevent;
            }

            if (isAppUrlChange(navigation.url)) {
              logger.info('Opening app link: $uri');
              unawaited(_launchExternalUri(uri, isApp: true));
              return NavigationDecision.prevent;
            }

            if (configuration.isDomainWhitelistEnabled &&
                !isWhitelistedOrigin(navigation.url)) {
              logger.severe('Blocked navigation to: ${navigation.url}');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
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

    _webViewController = controller;
  }

  void _initStyle(BuildContext context, Uri uri) {
    final theme = resolveTheme(uri, configuration.theme);

    final brightness = switch (theme) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };

    onBrightnessChanged(brightness);
    _brightness = brightness;
  }

  /// Callback when a JavaScript console message is received.
  /// We use this to log messages from the JS side, based on level.
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

  /// Callback when a custom message is received from the JS side.
  /// This is used to parse events (internal and external),
  /// and results (success and error).
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
      if (event is LoadedEvent) {
        unawaited(_onLoaded());
      }

      onEvent(event);
      return;
    }

    final result = MeshResult.fromJson(json);
    if (result != null) {
      logger.info('Result received: ${result.runtimeType}');
      result.when(
        success: (result) => onSuccess(result.payload),
        error: (error) => onError(error.type),
      );
      return;
    }

    logger.warning('Unexpected JS message: $json');
  }

  Future<void> _launchExternalUri(Uri uri, {required bool isApp}) async {
    if (_isExternalAppOpened) {
      logger.warning('External app already opened, ignoring: $uri');
      unawaited(goBack());
      return;
    }

    _isExternalAppOpened = true;
    if (!isApp) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    try {
      // Try launching in external non-browser app
      await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    } on PlatformException catch (e) {
      if (e.code == _activityNotFoundCode) {
        // If it fails, try browser app
        try {
          logger.info('Activity not found. Trying external app...');
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        } on PlatformException catch (e) {
          // If it fails, try store link
          if (e.code == _activityNotFoundCode) {
            logger.info('External app not found. Trying store link...');
            final storeUrl = getStoreUriFromAppUri(uri);
            if (storeUrl != null) {
              logger.info('Store link found. Opening...');
              _isExternalAppOpened = false;
              unawaited(_launchExternalUri(storeUrl, isApp: true));
              return;
            }
          }
        }
      }

      _isExternalAppOpened = false;
      rethrow;
    }
  }

  Future<void> _onLoaded() async {
    final stringBuffer = StringBuffer(
      "window.meshSdkPlatform='flutter';"
      "window.meshSdkVersion='$packageVersion';",
    );

    final integrationAccessTokens = configuration.integrationAccessTokens;
    if (integrationAccessTokens.isNotEmpty) {
      final tokensJson = integrationAccessTokens
          .map((e) => e.toJson())
          .toList();

      stringBuffer.write('window.accessTokens=${json.encode(tokensJson)};');
    }

    await _webViewController!.runJavaScript(stringBuffer.toString());
  }
}
