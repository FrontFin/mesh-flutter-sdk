import 'package:flutter/material.dart';
import 'package:mesh_sdk/src/l10n/mesh_localizations.dart';

extension BuildContextX on BuildContext {
  MeshLocalizations get l10n {
    final l10n = MeshLocalizations.of(this);
    if (l10n == null) {
      throw Exception(
        '$MeshLocalizations not found. '
        'Did you forget to add it to MaterialApp.localizationsDelegates?',
      );
    }

    return l10n;
  }
}
