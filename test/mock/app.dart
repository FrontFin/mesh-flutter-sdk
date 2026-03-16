import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/l10n/mesh_localizations.dart';
import 'package:mesh_sdk_flutter/src/mesh_sdk_flutter.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';

class TestApp extends StatelessWidget {
  const TestApp({required this.configuration, super.key});

  final MeshConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: MeshLocalizations.localizationsDelegates,
      supportedLocales: MeshLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () =>
                MeshSdk.show(context, configuration: configuration),
            child: const Text('Start'),
          ),
        ),
      ),
    );
  }
}
