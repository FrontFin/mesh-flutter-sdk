import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/model/link_style.dart';
import 'package:mesh_sdk_flutter/src/util/session_token_theme.dart';

/// Resolves the theme for the native chrome so it matches Link.
///
/// An explicit light/dark [configurationTheme] wins; otherwise the session
/// token's theme, then `link_style`. [ThemeMode.system] follows the device.
ThemeMode resolveTheme(Uri uri, ThemeMode? configurationTheme) {
  if (configurationTheme case final explicit?
      when explicit != ThemeMode.system) {
    return explicit;
  }
  final tokenTheme = themeFromSessionToken(uri.queryParameters['token']);
  if (tokenTheme != null) {
    return tokenTheme;
  }
  if (configurationTheme == ThemeMode.system) {
    return ThemeMode.system;
  }
  final linkStyleParam = uri.queryParameters['link_style'];
  final linkStyleBytes = linkStyleParam == null
      ? null
      : base64Decode(linkStyleParam);
  final linkStyleJson = linkStyleBytes == null
      ? null
      : json.decode(utf8.decode(linkStyleBytes));
  final linkStyle = linkStyleJson is Map<String, dynamic>
      ? LinkStyle.fromJson(linkStyleJson)
      : LinkStyle.fromJson(const {});
  return linkStyle.theme;
}
