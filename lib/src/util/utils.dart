import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/model/link_style.dart';

/// Returns true if [url] should be opened in an external app (e.g. wallet,
/// store) rather than in the WebView.
bool isAppUrlChange(String url) {
  final uri = Uri.parse(url);
  if (defaultTargetPlatform == TargetPlatform.android) {
    if (  uri.scheme == 'exodus' ||
        uri.host == 'market' ||
        uri.host == 'intent') {
      return true;
    }
  }

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    if (uri.host == 'apps.apple.com' || uri.scheme == 'itms-apps') {
      return true;
    }
  }

  return uri.host.endsWith('.app.link');
}

String resolveLanguage(String language) {
  if (language == 'system') {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    return locale.languageCode;
  }
  return language;
}

String themeToQueryParam(ThemeMode theme) {
  return theme.name;
}

ThemeMode getThemeModeFromUri(Uri uri, ThemeMode? configurationTheme) {
  if (configurationTheme != null) {
    return configurationTheme;
  }
  final linkStyleParam = uri.queryParameters['link_style'];
  final linkStyleBytes =
      linkStyleParam == null ? null : base64Decode(linkStyleParam);
  final linkStyleJson = linkStyleBytes == null
      ? null
      : json.decode(utf8.decode(linkStyleBytes));
  final linkStyle = linkStyleJson is Map<String, dynamic>
      ? LinkStyle.fromJson(linkStyleJson)
      : LinkStyle.fromJson(const {});
  return linkStyle.theme;
}
