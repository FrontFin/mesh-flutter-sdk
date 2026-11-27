import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';
import 'package:mesh_sdk_flutter/src/util/currency.dart';
import 'package:mesh_sdk_flutter/src/util/language.dart';
import 'package:mesh_sdk_flutter/src/util/theme.dart';

/// The URL to open, whether it opens dark, and the color around it.
typedef LinkUrl = ({Uri url, bool isDarkTheme, Color backgroundColor});

/// The token URL with the app's `th`, `lng`, `fiatCur` and `platform`
/// replacing any already in it, in one pass. The rest of the URL is not
/// edited (only [Uri.parse] can normalize a malformed escape). An app theme of
/// `system` is sent as `system`, so Link decides; on a legacy link, when the
/// device decides, the resolved theme is sent instead (see
/// [resolveLinkAppearance]).
LinkUrl buildLinkUrl(
  MeshConfiguration configuration, {
  required Brightness platformBrightness,
}) {
  final url = String.fromCharCodes(base64Decode(configuration.linkToken));
  final query = _Query.parse(url);

  final language = resolveLanguage(configuration.language);
  final currency = resolveCurrency(configuration.displayFiatCurrency);
  final params = {
    if (configuration.theme case final theme?) 'th': theme.name,
    'lng': ?language,
    'fiatCur': ?currency,
    'platform': 'flutter',
  };

  final appearance = resolveLinkAppearance(
    urlTheme: params['th'] ?? query.get('th'),
    token: query.get('token'),
    linkStyle: query.get('link_style'),
    platformBrightness: platformBrightness,
  );
  if (appearance.themeToWrite case final theme?) {
    params['th'] = theme.name;
  }

  return (
    url: Uri.parse(query.replace(params)),
    isDarkTheme: appearance.isDarkTheme,
    backgroundColor: appearance.backgroundColor,
  );
}

// Edits the query as plain text, so only the params we set change.
class _Query {
  _Query(this.base, this.pairs, this.fragment);

  factory _Query.parse(String url) {
    final hash = url.indexOf('#');
    final path = hash == -1 ? url : url.substring(0, hash);
    final fragment = hash == -1 ? '' : url.substring(hash);
    final start = path.indexOf('?');
    if (start == -1) {
      return _Query(path, const [], fragment);
    }
    return _Query(
      path.substring(0, start),
      path.substring(start + 1).split('&'),
      fragment,
    );
  }

  final String base;
  final List<String> pairs;
  final String fragment;

  /// First value of [name], like Link reads it.
  String? get(String name) {
    for (final pair in pairs) {
      final (key, value) = _split(pair);
      if (key == name) {
        return value;
      }
    }
    return null;
  }

  /// Drops existing [params] keys and adds the new values.
  String replace(Map<String, String> params) {
    final kept = pairs.where((p) => !params.containsKey(_split(p).$1));
    final added = params.entries.map(
      (e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}',
    );
    return '$base?${[...kept, ...added].join('&')}$fragment';
  }

  static (String, String) _split(String pair) {
    final i = pair.indexOf('=');
    return i == -1
        ? (_decode(pair), '')
        : (_decode(pair.substring(0, i)), _decode(pair.substring(i + 1)));
  }

  static String _decode(String value) {
    try {
      return Uri.decodeQueryComponent(value);
    } on Object {
      return value; // malformed escape, e.g. %zz
    }
  }
}
