import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesh_sdk_flutter/src/mesh_sdk_version.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_error_type.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_event.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_internal_event.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_result.dart';
import 'package:mesh_sdk_flutter/src/model/success/success.dart';
import 'package:mesh_sdk_flutter/src/util/app_url.dart';
import 'package:mesh_sdk_flutter/src/util/constants.dart';
import 'package:mesh_sdk_flutter/src/util/link_url.dart';
import 'package:mesh_sdk_flutter/src/util/logger.dart';
import 'package:mesh_sdk_flutter/src/util/new_task_launcher.dart';
import 'package:mesh_sdk_flutter/src/util/redact_uri.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late Color _backgroundColor;
  bool _isExternalAppOpened = false;

  /// The color around Link and of the native bars.
  Color get backgroundColor => _backgroundColor;

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

  /// Call when the host app returns to the foreground. The latest Link never
  /// changes its URL, so the URL-change reset alone would block every later
  /// launch.
  void onAppResumed() {
    _isExternalAppOpened = false;
  }

  /// Initialize the controller using [configuration].
  Future<void> init(BuildContext context) async {
    try {
      // Read once, like the page: Link doesn't follow a device switch.
      final (:url, :backgroundColor, isDarkTheme: _) = buildLinkUrl(
        configuration,
        platformBrightness: MediaQuery.platformBrightnessOf(context),
      );

      await _initWebViewController(url);
      if (!context.mounted) {
        return;
      }

      _backgroundColor = backgroundColor;
    } catch (e, s) {
      // The exception text can echo the raw link token, so log the type only.
      logger.severe(
        'Error initializing MeshLinkPage: ${e.runtimeType}',
        null,
        s,
      );
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
            logger.info('URL changed: ${redactUri(navigation.url)}');
            final newUrl = navigation.url;
            if (newUrl == null) {
              return;
            }

            // Uri.parse throws a FormatException that echoes the whole URL
            // into host crash reports, so parse safely.
            final newUri = Uri.tryParse(newUrl);
            if (newUri == null) {
              return;
            }

            if (isAppUrlChange(newUrl)) {
              logger.info('app redirect: ${redactUri(newUri)}');
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
            logger.info('Navigation request: ${redactUri(navigation.url)}');
            final uri = Uri.tryParse(navigation.url);
            if (uri == null) {
              logger.severe('Blocked unparsable navigation URL');
              return NavigationDecision.prevent;
            }

            if (isExternallyOpenedOrigin(navigation.url)) {
              logger.info(
                'Externally opened origin, opening in external browser: '
                '${redactUri(uri)}',
              );
              unawaited(_launchExternalUri(uri, isApp: false));
              return NavigationDecision.prevent;
            }

            if (isAppUrlChange(navigation.url)) {
              logger.info('Opening app link: ${redactUri(uri)}');
              unawaited(_launchExternalUri(uri, isApp: true));
              return NavigationDecision.prevent;
            }

            if (configuration.isDomainWhitelistEnabled &&
                !isWhitelistedOrigin(navigation.url)) {
              logger.severe('Blocked navigation to: ${redactUri(uri)}');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onHttpError: (error) {
            logger.warning(
              'HTTP error ${error.response?.statusCode}. '
              'Request (${redactUri(error.request?.uri)}). '
              'Response ${redactUri(error.response?.uri)}',
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

    logger
      ..warning('Unhandled JS message type: ${json['type']}')
      // Build the keys string lazily so nothing is allocated when FINE logging
      // is disabled (the logger defaults to INFO).
      ..fine(() => 'Unhandled JS message keys: ${json.keys.toList()}');
  }

  /// Returns true if a store URL launch was scheduled ([_isExternalAppOpened]
  /// is cleared first).
  bool _tryStoreFallbackFromAppUri(Uri uri) {
    final storeUrl = getStoreUriFromAppUri(uri);
    if (storeUrl == null) {
      return false;
    }
    logger.info('External app not found. Trying store link...');
    _isExternalAppOpened = false;
    unawaited(_launchExternalUri(storeUrl, isApp: false));
    return true;
  }

  Future<bool> _launchExternalApplication(
    Uri uri, {
    required bool isApp,
  }) async {
    if (isApp && defaultTargetPlatform == TargetPlatform.android) {
      await launchInNewTask(uri);
      return true;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      logger.info(
        'Launch of external application returned false for URI: '
        '${redactUri(uri)}',
      );
    }
    return launched;
  }

  Future<void> _launchExternalUri(Uri uri, {required bool isApp}) async {
    if (_isExternalAppOpened) {
      logger.warning(
        'External app already opened, ignoring: ${redactUri(uri)}',
      );
      unawaited(goBack());
      return;
    }

    _isExternalAppOpened = true;
    try {
      if (!await _launchExternalApplication(uri, isApp: isApp)) {
        if (isApp && _tryStoreFallbackFromAppUri(uri)) {
          return;
        }
        _isExternalAppOpened = false;
        return;
      }
    } on PlatformException catch (e, s) {
      if (isApp && e.code == activityNotFoundCode) {
        if (_tryStoreFallbackFromAppUri(uri)) {
          return;
        }
      } else {
        // The platform message can echo the launched URI, so log the code only.
        logger.severe(
          'Unexpected platform error launching ${redactUri(uri)}: ${e.code}',
          null,
          s,
        );
      }
      _isExternalAppOpened = false;
    }
  }

  Future<void> _onLoaded() async {
    final stringBuffer = StringBuffer(
      "window.meshSdkPlatform='flutter';"
      "window.meshSdkVersion='$sdkVersion';",
    );

    final integrationAccessTokens = configuration.integrationAccessTokens;
    if (integrationAccessTokens.isNotEmpty) {
      final tokensJson = integrationAccessTokens
          .map((e) => e.toJson())
          .toList();

      // Double-encoded so the JS side receives a string, not an object.
      // Link UI expects JSON.parse(window.accessTokens) to work.
      final tokensJsonString = json.encode(tokensJson);
      stringBuffer.write(
        'window.accessTokens=${json.encode(tokensJsonString)};',
      );
      logger.info('Injecting ${tokensJson.length} accessToken(s)');
    }

    await _webViewController!.runJavaScript(stringBuffer.toString());
  }
}
