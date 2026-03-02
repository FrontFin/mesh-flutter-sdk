// ignore_for_file: avoid_print
import 'dart:async';

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
      locale: const Locale('fr'), // non-supported locale should fallback to en
      supportedLocales: MeshLocalizations.supportedLocales,
      localizationsDelegates: MeshLocalizations.localizationsDelegates,
      theme: ThemeData.from(
        colorScheme: const ColorScheme.dark(primary: Color(0xFFFAFF6E)),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _textController = TextEditingController();

  void _onButtonPressed() {
    final linkToken = _textController.text.trim();
    if (linkToken.isNotEmpty) {
      unawaited(_showMeshLinkPage(linkToken));
      _textController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    labelText: 'Link Token',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _onButtonPressed,
                  child: const Text('Start'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMeshLinkPage(String linkToken) async {
    final result = await MeshSdk.show(
      context,
      configuration: MeshConfiguration(
        language: 'en',
        integrationAccessTokens: const [
          IntegrationAccessToken(
            accessToken: 'token',
            accountId: 'id',
            accountName: 'name',
            brokerName: 'broker',
            brokerType: 'type',
          ),
        ],
        linkToken: linkToken,
        onEvent: (event) {
          print('Mesh event: $event');
        },
        onError: (errorType) {
          print('Mesh exit: $errorType');
        },
        onSuccess: (payload) {
          print('Mesh success: ${payload.page}');
        },
        onIntegrationConnected: (integration) {
          print('Integration connected: $integration');
        },
        onTransferFinished: (transfer) {
          print('Transfer finished: $transfer');
        },
      ),
    );

    // Handle the result
    switch (result) {
      case MeshSuccess():
        print('Mesh link finished successfully');
      case MeshError():
        print('Mesh link error: ${result.type}');
    }

    // Alternatively, use `when` method
    result.when(
      success: (success) {
        final payload = success.payload;
        print('Mesh link success: ${payload.page}');
      },
      error: (error) {
        final errorType = error.type;
        print('Mesh link error: $errorType');
      },
    );
  }
}
