import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/model/link_style.dart';

ThemeMode resolveTheme(Uri uri, ThemeMode? configurationTheme) {
  if (configurationTheme != null) {
    return configurationTheme;
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
