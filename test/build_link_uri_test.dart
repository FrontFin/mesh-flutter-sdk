import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';
import 'package:mesh_sdk_flutter/src/util/link_uri.dart';

String _encodeToken(String url) => base64Encode(utf8.encode(url));

MeshConfiguration _config({
  String url = 'https://link.meshconnect.com/path',
  String language = 'en',
  String? displayFiatCurrency,
  ThemeMode? theme,
}) => MeshConfiguration(
      linkToken: _encodeToken(url),
      language: language,
      displayFiatCurrency: displayFiatCurrency,
      theme: theme,
    );

void main() {
  group('buildLinkUri', () {
    test('preserves base URL scheme, host, and path', () {
      final uri = buildLinkUri(_config());
      expect(uri.scheme, 'https');
      expect(uri.host, 'link.meshconnect.com');
      expect(uri.path, '/path');
    });

    test('always sets lng from configuration language', () {
      final uri = buildLinkUri(_config(language: 'es'));
      expect(uri.queryParameters['lng'], 'es');
    });

    test('defaults lng to en', () {
      final uri = buildLinkUri(_config());
      expect(uri.queryParameters['lng'], 'en');
    });

    test('sets fiatCur when displayFiatCurrency is provided', () {
      final uri = buildLinkUri(_config(displayFiatCurrency: 'EUR'));
      expect(uri.queryParameters['fiatCur'], 'EUR');
    });

    test('omits fiatCur when displayFiatCurrency is null', () {
      final uri = buildLinkUri(_config());
      expect(uri.queryParameters.containsKey('fiatCur'), isFalse);
    });

    test('sets th to light when theme is ThemeMode.light', () {
      final uri = buildLinkUri(_config(theme: ThemeMode.light));
      expect(uri.queryParameters['th'], 'light');
    });

    test('sets th to dark when theme is ThemeMode.dark', () {
      final uri = buildLinkUri(_config(theme: ThemeMode.dark));
      expect(uri.queryParameters['th'], 'dark');
    });

    test('sets th to system when theme is ThemeMode.system', () {
      final uri = buildLinkUri(_config(theme: ThemeMode.system));
      expect(uri.queryParameters['th'], 'system');
    });

    test('omits th when theme is null', () {
      final uri = buildLinkUri(_config());
      expect(uri.queryParameters.containsKey('th'), isFalse);
    });

    test('preserves existing query parameters from link token URL', () {
      final uri = buildLinkUri(
        _config(url: 'https://link.meshconnect.com/path?existing=value'),
      );
      expect(uri.queryParameters['existing'], 'value');
    });

    test('overrides existing lng in link token URL', () {
      final uri = buildLinkUri(
        _config(
          url: 'https://link.meshconnect.com/path?lng=fr',
          language: 'pt',
        ),
      );
      expect(uri.queryParameters['lng'], 'pt');
    });

    test('sets all params together', () {
      final uri = buildLinkUri(
        _config(
          language: 'es',
          displayFiatCurrency: 'GBP',
          theme: ThemeMode.dark,
        ),
      );
      expect(uri.queryParameters['lng'], 'es');
      expect(uri.queryParameters['fiatCur'], 'GBP');
      expect(uri.queryParameters['th'], 'dark');
    });
  });
}
