// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/mesh_sdk_flutter.dart';

void main() {
  runApp(const MeshExampleApp());
}

class MeshExampleApp extends StatelessWidget {
  const MeshExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: MeshLocalizations.supportedLocales,
      localizationsDelegates: MeshLocalizations.localizationsDelegates,
      theme: ThemeData.from(
        colorScheme: const ColorScheme.dark(primary: Color(0xFFFAFF6E)),
      ),
      home: const HomePage(),
    );
  }
}

/// A link token is base64 of a Link URL; a session token (`ory_ac_...`) is not
/// valid base64 at all, so the two are told apart by trying to decode one.
bool _isLinkToken(String input) {
  try {
    final decoded = utf8.decode(base64Decode(base64.normalize(input)));
    return decoded.startsWith('https://');
  } catch (_) {
    return false;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _textController = TextEditingController();
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final input = _textController.text.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Mesh Example App')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _textController,
                  enabled: !_isBusy,
                  decoration: const InputDecoration(
                    labelText: 'Link or session token',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: input.isEmpty || _isBusy
                      ? null
                      : () => _connect(input),
                  child: _isBusy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Connect'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _connect(String input) async {
    // A link token carries its own host, so it needs nothing else. A session
    // token does not, and the environment cannot be guessed from the token, so
    // ask rather than assume: a dev token opened against prod fails in a way
    // that is hard to read.
    MeshLinkEnvironment? environment;
    if (!_isLinkToken(input)) {
      environment = await _askEnvironment();
      if (environment == null || !mounted) {
        return;
      }
    }

    setState(() => _isBusy = true);
    _textController.clear();

    try {
      await _showMeshLinkPage(input, environment);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<MeshLinkEnvironment?> _askEnvironment() {
    return showDialog<MeshLinkEnvironment>(
      context: context,
      builder: (context) => AlertDialog(
        // Claw back the horizontal room the three buttons need.
        contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        title: Row(
          children: [
            const Expanded(child: Text('MFS native token')),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'This looks like a session token rather than a link token, so it '
              'is an MFS native session. It will be wrapped into a link token '
              'for the environment you pick.\n\n'
              'Pick the environment the token was minted in.',
            ),
            const SizedBox(height: 24),
            // A Row rather than `actions`: four buttons overflow the dialog's
            // OverflowBar and it silently stacks them vertically.
            Row(
              children: [
                for (final env in MeshLinkEnvironment.values) ...[
                  if (env != MeshLinkEnvironment.values.first)
                    const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      // Default button padding is wider than a third of a
                      // dialog, which wraps even a 4-character label.
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(env),
                      child: Text(
                        env.name.toUpperCase(),
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMeshLinkPage(
    String input,
    MeshLinkEnvironment? environment,
  ) async {
    print(
      environment == null
          ? 'Opening Link with a link token'
          : 'Opening Link with a session token (${environment.name})',
    );

    // The two constructors differ only in how Link is addressed. Every option
    // and callback below is identical, and so is everything downstream.
    final result = await MeshSdk.show(
      context,
      configuration: environment == null
          ? MeshConfiguration(
              linkToken: input,
              language: 'system',
              displayFiatCurrency: 'USD',
              theme: ThemeMode.system,
              onEvent: (event) => print('Mesh event: $event'),
              onError: (errorType) => print('Mesh exit: $errorType'),
              onSuccess: (payload) => print('Mesh success: ${payload.page}'),
              onIntegrationConnected: (integration) =>
                  print('Mesh integration connected: $integration'),
              onTransferFinished: (transfer) =>
                  print('Mesh transfer finished: $transfer'),
            )
          : MeshConfiguration.session(
              token: input,
              environment: environment,
              language: 'system',
              displayFiatCurrency: 'USD',
              theme: ThemeMode.system,
              onEvent: (event) => print('Mesh event: $event'),
              onError: (errorType) => print('Mesh exit: $errorType'),
              onSuccess: (payload) => print('Mesh success: ${payload.page}'),
              onIntegrationConnected: (integration) =>
                  print('Mesh integration connected: $integration'),
              onTransferFinished: (transfer) =>
                  print('Mesh transfer finished: $transfer'),
            ),
    );

    switch (result) {
      case MeshSuccess():
        print('Mesh link finished successfully');
      case MeshError():
        print('Mesh link error: ${result.type}');
    }
  }
}
