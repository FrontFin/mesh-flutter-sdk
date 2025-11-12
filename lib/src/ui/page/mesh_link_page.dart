import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_error_type.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_event.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_internal_event.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_result.dart';
import 'package:mesh_sdk_flutter/src/ui/dialog/exit_dialog.dart';
import 'package:mesh_sdk_flutter/src/ui/widget/mesh_link_controller.dart';
import 'package:mesh_sdk_flutter/src/ui/widget/mesh_link_nav_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A page that displays the Mesh Link web view.
class MeshLinkPage extends StatefulWidget {
  const MeshLinkPage({required this.configuration, super.key});

  final MeshConfiguration configuration;

  @override
  State<MeshLinkPage> createState() => _MeshLinkPageState();
}

class _MeshLinkPageState extends State<MeshLinkPage> {
  late final MeshLinkController _controller;

  /// Whether to show the native navigation bar
  /// (for example, when we navigate to a 3rd party integration webpage).
  bool _showNativeNavBar = false;

  @override
  void initState() {
    super.initState();

    _controller = MeshLinkController(
      configuration: widget.configuration,
      onInternalEvent: (event) {
        if (mounted) {
          _handleInternalEvent(context, event);
        }
      },
      onEvent: (event) {
        if (mounted) {
          _handleEvent(context, event);
        }
      },
      onError: (error) {
        if (mounted) {
          _finish(context, MeshError(error));
        }
      },
      onSuccess: (success) {
        if (mounted) {
          _finish(context, MeshSuccess(payload: success));
        }
      },
    );

    unawaited(
      _controller.init(context).then((_) {
        if (mounted) {
          // Update the UI
          setState(() {});
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (!_controller.isInitialized) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = WebViewWidget(controller: _controller.webViewController);

      if (_showNativeNavBar) {
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MeshLinkNavBar(
              brightness: _controller.brightness,
              onBackPressed: _controller.goBack,
              onClosePressed: () => _showCloseDialog(context),
            ),
            Expanded(child: body),
          ],
        );
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          // Pop happened, no need to handle it
          return;
        }

        final canGoBack = await _controller.canGoBack();
        if (!context.mounted) {
          return;
        }

        if (canGoBack) {
          // Pass the back action to the web view controller
          await _controller.goBack();
          return;
        }

        // We're on the root page, show the close dialog
        _showCloseDialog(context);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: body),
      ),
    );
  }

  void _showCloseDialog(BuildContext context) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ExitDialog(
      onConfirm: () {
        _finish(context, const MeshError(MeshErrorType.userCancelled));
      },
    ),
  );

  void _handleInternalEvent(BuildContext context, MeshInternalEvent event) {
    switch (event) {
      case ShowClose():
        _showCloseDialog(context);

      case ShowNativeNavBar():
        setState(() => _showNativeNavBar = event.show);

      case IntegrationConnected():
        final externalEvent = IntegrationConnectedEvent(payload: event.payload);

        _handleEvent(context, externalEvent);
        widget.configuration.onIntegrationConnected?.call(externalEvent);

      case TransferFinished():
        final externalEvent = TransferFinishedEvent(payload: event.payload);

        _handleEvent(context, externalEvent);
        widget.configuration.onTransferFinished?.call(externalEvent);
    }
  }

  void _handleEvent(BuildContext context, MeshEvent event) {
    widget.configuration.onEvent?.call(event);
  }

  void _finish(BuildContext context, MeshResult result) {
    result.when(
      success: (success) {
        widget.configuration.onSuccess?.call(success.payload);
      },
      error: (error) {
        widget.configuration.onError?.call(error.type);
      },
    );

    Navigator.pop(context, result);
  }
}
