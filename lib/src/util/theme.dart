import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/util/query_params.dart';

// Base64 or base64url, padded; a '+' turned into a space by URL decoding is
// restored.
Object? _decodeBase64Json(String value) {
  final base64 = base64Url.normalize(value.replaceAll(' ', '+'));
  return json.decode(utf8.decode(base64Url.decode(base64)));
}

String? _linkStyleTheme(String url) {
  final linkStyle = getFirstQueryParam(url, 'link_style');
  if (linkStyle == null) {
    return null;
  }
  try {
    final style = _decodeBase64Json(linkStyle);
    final th = style is Map ? style['th'] : null;
    return th is String && th.isNotEmpty ? th : null;
  } on Object {
    return null;
  }
}

// The latest Link's `token` param, validated the way Link does; null for
// older links.
Map<Object?, Object?>? _tokenEnvelope(String url) {
  final token = getFirstQueryParam(url, 'token');
  if (token == null || token.isEmpty) {
    return null;
  }
  try {
    final envelope = _decodeBase64Json(token);
    if (envelope is! Map) {
      return null;
    }
    final client = envelope['c'];
    final isEnvelope =
        envelope['v'] is num && client is String && client.isNotEmpty;
    return isEnvelope ? envelope : null;
  } on Object {
    return null;
  }
}

bool isLatestLinkUrl(String url) => _tokenEnvelope(url) != null;

/// The brightness Link will render in, resolved the way the page does so the
/// native background matches it: the first `th` param wins, then legacy
/// `link_style`, then the latest Link token's theme. Such a token without a
/// theme follows the device; legacy links default to light.
Brightness resolveLinkBrightness(String url, Brightness platformBrightness) {
  final th = getFirstQueryParam(url, 'th');
  if (th == 'dark') {
    return Brightness.dark;
  }
  if (th == 'light') {
    return Brightness.light;
  }

  final linkStyleTheme = _linkStyleTheme(url);
  if (linkStyleTheme == 'system') {
    return platformBrightness;
  }
  if (linkStyleTheme == 'dark') {
    return Brightness.dark;
  }
  if (linkStyleTheme == 'light') {
    return Brightness.light;
  }

  final envelope = _tokenEnvelope(url);
  if (envelope == null) {
    return Brightness.light;
  }
  return switch (envelope['th']) {
    'LINK_THEME_DARK' => Brightness.dark,
    'LINK_THEME_LIGHT' => Brightness.light,
    _ => platformBrightness,
  };
}
