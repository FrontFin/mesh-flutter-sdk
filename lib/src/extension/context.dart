import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/l10n/mesh_localizations.dart';
import 'package:mesh_sdk_flutter/src/l10n/mesh_localizations_en.dart';

extension BuildContextX on BuildContext {
  MeshLocalizations get l10n {
    return MeshLocalizations.of(this) ?? MeshLocalizationsEn('en');
  }
}
