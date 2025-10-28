import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mesh_sdk/src/model/mesh_configuration.dart';
import 'package:mesh_sdk/src/model/mesh_error_type.dart';
import 'package:mesh_sdk/src/model/mesh_event.dart';
import 'package:mesh_sdk/src/model/mesh_internal_event.dart';
import 'package:mesh_sdk/src/model/mesh_result.dart';
import 'package:mesh_sdk/src/ui/dialog/exit_dialog.dart';
import 'package:mesh_sdk/src/ui/widget/mesh_link_controller.dart';
import 'package:mesh_sdk/src/ui/widget/mesh_link_nav_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MeshLinkPage extends StatefulWidget {
  const MeshLinkPage({required this.configuration, super.key});

  final MeshConfiguration configuration;

  @override
  State<MeshLinkPage> createState() => _MeshLinkPageState();
}

class _MeshLinkPageState extends State<MeshLinkPage> {
  late final MeshLinkController _controller;
  bool _showNativeNavBar = false;

  @override
  void initState() {
    _controller = MeshLinkController(
      configuration: widget.configuration,
      onInternalEvent: (event) => _handleInternalEvent(context, event),
      onEvent: (event) => _handleEvent(context, event),
      onError: (error) => _finish(context, MeshError(error)),
    );
    unawaited(
      _controller.init(context).then((_) {
        if (mounted) {
          setState(() {});
        }
      }),
    );

    super.initState();
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
          return;
        }

        final canGoBack = await _controller.canGoBack();
        if (!context.mounted) {
          return;
        }

        if (canGoBack) {
          await _controller.goBack();
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
    switch (result) {
      case MeshSuccess():
        throw UnimplementedError('MeshSuccess handling is not implemented');
      case MeshError():
        widget.configuration.onExit?.call(result.type);
    }

    Navigator.of(context).pop(result);
  }
}
