import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/model/link_style.dart';
import 'package:mesh_sdk_flutter/src/util/session_token_theme.dart';

/// Resolves the theme for the native chrome (system bars, nav bar) so it
/// matches what Link renders.
///
/// An explicit light/dark [configurationTheme] wins. Otherwise (system or
/// null) the session token's theme is used, then the legacy `link_style`
/// param (null configuration only). [ThemeMode.system] means "follow the
/// device".
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
