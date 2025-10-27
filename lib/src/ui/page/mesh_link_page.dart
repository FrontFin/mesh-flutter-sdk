import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mesh_sdk/src/extension/context.dart';
import 'package:mesh_sdk/src/model/link_style.dart';
import 'package:mesh_sdk/src/model/mesh_configuration.dart';
import 'package:mesh_sdk/src/model/mesh_error_type.dart';
import 'package:mesh_sdk/src/model/mesh_event.dart';
import 'package:mesh_sdk/src/model/mesh_result.dart';
import 'package:mesh_sdk/src/ui/theme.dart';
import 'package:mesh_sdk/src/ui/widget/mesh_link_toolbar.dart';
import 'package:mesh_sdk/src/util/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MeshLinkPage extends StatefulWidget {
  const MeshLinkPage({required this.configuration, super.key});

  final MeshConfiguration configuration;

  @override
  State<MeshLinkPage> createState() => _MeshLinkPageState();
}

class _MeshLinkPageState extends State<MeshLinkPage> {
  WebViewController? _webViewController;
  final _logger = createLogger();
  bool _isMeshLinkUrl = true;
  late Brightness _brightness;

  @override
  void initState() {
    unawaited(_init());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _webViewController;
    final Widget body;
    if (controller == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final webView = WebViewWidget(controller: controller);
      if (_isMeshLinkUrl) {
        body = webView;
      } else {
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MeshLinkToolbar(
              brightness: _brightness,
              onBackPressed: _goBack,
              onClosePressed: () => _showCloseDialog(context),
            ),
            Expanded(child: webView),
          ],
        );
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final canGoBack = await _webViewController?.canGoBack() ?? false;
        if (!context.mounted) {
          return;
        }

        if (canGoBack) {
          await _goBack();
          return;
        }

        _showCloseDialog(context);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: body),
      ),
    );
  }

  Future<void> _init() async {
    try {
      final configuration = widget.configuration;
      final url = String.fromCharCodes(base64Decode(configuration.linkToken));
      final uri = Uri.parse(url);
      final linkHost = uri.host;

      _initStyle(uri);
      final controller = WebViewController();
      await Future.wait([
        controller.setBackgroundColor(Colors.transparent),
        controller.setJavaScriptMode(JavaScriptMode.unrestricted),
        controller.setOnConsoleMessage((consoleMessage) {
          // TODO: move event parsing to onMessageReceived
          final message = consoleMessage.message;
          _logger.info('Console message (${consoleMessage.level}): $message');
          if (message.startsWith('Failed to send a message with webkit')) {
            return;
          }

          final match = RegExp(r'\(type:(.*?)\)').firstMatch(message);
          final eventString = match?.group(1);
          final event = MeshEvent.fromString(eventString);
          if (event != null) {
            _handleEvent(context, event);
          }
        }),
        controller.addJavaScriptChannel(
          'JSBridge',
          onMessageReceived: (json) {
            _logger.info('JS message received: ${json.message}');
          },
        ),
        controller.setNavigationDelegate(
          NavigationDelegate(
            onHttpAuthRequest: (navigation) {
              _logger.info('HTTP auth request: ${navigation.host}');
            },
            onUrlChange: (navigation) {
              _logger.info('URL changed: ${navigation.url}');
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

              setState(() {
                _isMeshLinkUrl = newUri.host == linkHost;
              });
            },
            onNavigationRequest: (navigation) {
              _logger.info('Navigation request: ${navigation.url}');
              final uri = Uri.parse(navigation.url);

              switch (uri.scheme) {
                case 'itms-appss':
                  _logger.info('Opening App Store link: $uri');
                  unawaited(
                    launchUrl(uri, mode: LaunchMode.externalApplication),
                  );
                  return NavigationDecision.prevent;

                default:
                  return NavigationDecision.navigate;
              }
            },
            onHttpError: (error) {
              _logger.severe('HTTP error: ${error.response}');
            },
            onWebResourceError: (error) {
              _logger.severe(
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

      if (configuration.integrationAccessTokens.isNotEmpty) {
        final tokensJson = configuration.integrationAccessTokens
            .map((e) => e.toJson())
            .toList();

        stringBuffer.write(
          'window.integrationAccessTokens=${json.encode(tokensJson)};',
        );
      }

      await controller.runJavaScript(stringBuffer.toString());
      setState(() {
        _webViewController = controller;
        _isMeshLinkUrl = true;
      });
    } catch (e, s) {
      _logger.severe('Error initializing MeshLinkPage: $e', e, s);
      if (mounted) {
        _finish(context, const MeshError(MeshErrorType.unknown));
      }
    }
  }

  void _initStyle(Uri uri) {
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
    setState(() => _brightness = brightness);
  }

  Future<void> _goBack() async {
    await _webViewController?.runJavaScript('window.history.go(-1)');
  }

  void _showCloseDialog(BuildContext context) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.exitDialogTitle),
      content: Text(context.l10n.exitDialogMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _finish(context, const MeshError(MeshErrorType.userCancelled));
          },
          child: Text(context.l10n.exit),
        ),
      ],
    ),
  );

  void _handleEvent(BuildContext context, MeshEvent event) {
    _logger.info('Event received: $event');

    switch (event) {
      case MeshEvent.showClose:
        _showCloseDialog(context);
    }
  }

  void _finish(BuildContext context, MeshResult result) {
    Navigator.of(context).pop(result);
  }
}
