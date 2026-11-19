import 'dart:convert';

import 'package:flutter/material.dart';

/// Reads the theme the backend chose for this session from the Link session
/// token (the `token` query parameter of the Link URL).
///
/// The token is either a raw code (legacy) or a base64url-encoded JSON
/// envelope such as `{"v":1,"c":"<code>","th":"LINK_THEME_DARK"}`. Mirrors
/// Link's parser: an envelope is valid only if it is an object with a numeric
/// `v` and a non-empty string `c`. Only `LINK_THEME_LIGHT` and
/// `LINK_THEME_DARK` yield a value; anything else returns null.
///
/// Never log the token or its `c` field: it is a session credential.
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
    // A raw (legacy) or malformed token carries no theme.
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
