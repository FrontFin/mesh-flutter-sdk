import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';
import 'package:mesh_sdk_flutter/src/util/language.dart';
import 'package:mesh_sdk_flutter/src/util/query_params.dart';

/// Builds the full link [Uri] from [configuration] (including its link token),
/// with query parameters for platform, language, theme, and fiat currency.
///
/// The app's theme replaces any `th` already in the token (some backends add
/// `th=dark`), and `system` is sent as the device's light or dark.
Uri buildLinkUri(
  MeshConfiguration configuration, {
  required Brightness platformBrightness,
}) {
  var url = String.fromCharCodes(base64Decode(configuration.linkToken));

  url = setQueryParam(url, 'platform', 'flutter');
  url = setQueryParam(url, 'lng', resolveLanguage(configuration.language));

  final fiatCur = configuration.displayFiatCurrency;
  if (fiatCur != null) {
    url = setQueryParam(url, 'fiatCur', fiatCur);
  }

  final th = switch (configuration.theme) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => platformBrightness.name,
    null => null,
  };
  if (th != null) {
    url = setQueryParam(url, 'th', th);
  }

  return Uri.parse(url);
}
