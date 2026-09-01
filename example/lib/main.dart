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
///
/// This lives in the example app, not the SDK: a session token needs an
/// environment, and guessing it would silently send a dev token to production.
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

  /// Only consulted for session tokens; a link token carries its own host.
  MeshLinkEnvironment _environment = MeshLinkEnvironment.prod;

  @override
  Widget build(BuildContext context) {
    final input = _textController.text.trim();
    final isLinkToken = input.isEmpty || _isLinkToken(input);

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
                  decoration: const InputDecoration(
                    labelText: 'Link or session token',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Text(
                  input.isEmpty
                      ? 'Paste either kind, the type is detected'
                      : isLinkToken
                      ? 'Detected: link token'
                      : 'Detected: session token',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                // Session tokens carry no host, so the environment picks one.
                if (input.isNotEmpty && !isLinkToken) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<MeshLinkEnvironment>(
                    initialValue: _environment,
                    decoration: const InputDecoration(
                      labelText: 'Environment',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    items: [
                      for (final env in MeshLinkEnvironment.values)
                        DropdownMenuItem(value: env, child: Text(env.name)),
                    ],
                    onChanged: (env) =>
                        setState(() => _environment = env ?? _environment),
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: input.isEmpty
                      ? null
                      : () => _showMeshLinkPage(input),
                  child: const Text('Start'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMeshLinkPage(String input) async {
    final isLinkToken = _isLinkToken(input);
    print(
      'Opening Link with a ${isLinkToken ? "link" : "session"} token'
      '${isLinkToken ? "" : " (${_environment.name})"}',
    );

    _textController.clear();
    setState(() {});

    // The two constructors differ only in how Link is addressed. Every option
    // and callback below is identical, and so is everything downstream.
    final result = await MeshSdk.show(
      context,
      configuration: isLinkToken
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
              environment: _environment,
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
