import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/l10n/mesh_localizations.dart';
import 'package:mesh_sdk_flutter/src/l10n/mesh_localizations_en.dart';

extension BuildContextX on BuildContext {
  MeshLocalizations get l10n {
    final l10n = MeshLocalizations.of(this);
    if (l10n != null) {
      return l10n;
    }
    final locale = Localizations.maybeLocaleOf(this);
    if (locale == null) {
      // No locale could be determined; fall back to default English.
      return MeshLocalizationsEn('en');
    }
    final isSupported = MeshLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
    if (isSupported) {
      throw Exception(
        'MeshLocalizations for locale `${locale.languageCode}` is supported '
        'but not available. Did you forget to register '
        'MeshLocalizations.delegate?',
      );
    }
    // No supported locale found; fall back to default English.
    return MeshLocalizationsEn('en');
  }
}
