// ignore_for_file: avoid_print
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

  @override
  Widget build(BuildContext context) {
    final linkToken = _textController.text.trim();

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
                  onPressed: linkToken.isEmpty
                      ? null
                      : () => _showMeshLinkPage(linkToken),
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
          print('Mesh success: ${payload.integration.name}');
        },
        onIntegrationConnected: (integration) {
          print('Integration connected: $integration');
        },
        onTransferFinished: (transfer) {
          print('Transfer finished: $transfer');
        },
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
