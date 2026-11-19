import 'dart:convert';

import 'package:flutter/material.dart';

/// Reads the theme Link will use from the session token, if present.
///
/// Returns null when the token carries no light/dark theme. Never log the
/// token: it is a session credential.
ThemeMode? themeFromSessionToken(String? token) {
  if (token == null || token.isEmpty) {
    return null;
  }
  final envelope = _decodeEnvelope(token);
  if (envelope == null) {
    return null;
  }
  return switch (envelope['th']) {
    'LINK_THEME_LIGHT' => ThemeMode.light,
    'LINK_THEME_DARK' => ThemeMode.dark,
    _ => null,
  };
}

Map<String, Object?>? _decodeEnvelope(String token) {
  final base64 = token.replaceAll('-', '+').replaceAll('_', '/');
  final padded = base64.padRight((base64.length + 3) ~/ 4 * 4, '=');
  final Object? decoded;
  try {
    decoded = json.decode(utf8.decode(base64Decode(padded)));
  } on FormatException {
    // Tokens that are not an encoded envelope carry no theme.
    return null;
  }
  if (decoded is! Map<String, Object?>) {
    return null;
  }
  final code = decoded['c'];
  if (decoded['v'] is! num || code is! String || code.isEmpty) {
    return null;
  }
  return decoded;
}
