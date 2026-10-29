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

Uri _build(
  MeshConfiguration configuration, {
  Brightness platformBrightness = Brightness.light,
}) => buildLinkUri(configuration, platformBrightness: platformBrightness);

void main() {
  group('buildLinkUri', () {
    test('preserves base URL scheme, host, and path', () {
      final uri = _build(_config());
      expect(uri.scheme, 'https');
      expect(uri.host, 'link.meshconnect.com');
      expect(uri.path, '/path');
    });

    test('always sets lng from configuration language', () {
      expect(_build(_config(language: 'es')).queryParameters['lng'], 'es');
    });

    test('defaults lng to en', () {
      expect(_build(_config()).queryParameters['lng'], 'en');
    });

    test('sets platform to flutter', () {
      expect(_build(_config()).queryParameters['platform'], 'flutter');
    });

    test('sets fiatCur when displayFiatCurrency is provided', () {
      final uri = _build(_config(displayFiatCurrency: 'EUR'));
      expect(uri.queryParameters['fiatCur'], 'EUR');
    });

    test('omits fiatCur when displayFiatCurrency is null', () {
      final uri = _build(_config());
      expect(uri.queryParameters.containsKey('fiatCur'), isFalse);
    });

    test('sets th to light or dark from the configuration theme', () {
      expect(
        _build(_config(theme: ThemeMode.light)).queryParameters['th'],
        'light',
      );
      expect(
        _build(_config(theme: ThemeMode.dark)).queryParameters['th'],
        'dark',
      );
    });

    test('sends a system theme as the device theme', () {
      final config = _config(theme: ThemeMode.system);
      expect(
        _build(
          config,
          platformBrightness: Brightness.dark,
        ).queryParameters['th'],
        'dark',
      );
      expect(
        _build(
          config,
          platformBrightness: Brightness.light,
        ).queryParameters['th'],
        'light',
      );
    });

    test('omits th when theme is null', () {
      final uri = _build(_config());
      expect(uri.queryParameters.containsKey('th'), isFalse);
    });

    test('replaces the token th with the app theme', () {
      final uri = _build(
        _config(
          url: 'https://link.meshpay.com/?th=dark&token=abc&th=dark',
          theme: ThemeMode.light,
        ),
      );
      expect(uri.queryParametersAll['th'], ['light']);
    });

    test('keeps the token th when the app passes no theme', () {
      final uri = _build(_config(url: 'https://link.meshpay.com/?th=dark'));
      expect(uri.queryParameters['th'], 'dark');
    });

    test('keeps the other token params as they are', () {
      const flow = '{%22flow%22%3A%22login%22}';
      final uri = _build(
        _config(
          url: 'https://link.meshpay.com/?token=a-b_c+d&flow=$flow&th=dark',
          theme: ThemeMode.light,
        ),
      );
      // Uri.parse only escapes the raw braces, which decode the same.
      expect(
        uri.toString(),
        'https://link.meshpay.com/?token=a-b_c+d&flow=%7B%22flow%22%3A%22login%22%7D'
        '&platform=flutter&lng=en&th=light',
      );
      expect(uri.queryParameters['flow'], '{"flow":"login"}');
    });

    test('adds params before the fragment', () {
      final uri = _build(_config(url: 'https://link.meshpay.com/?a=1#x'));
      expect(uri.fragment, 'x');
      expect(uri.queryParameters['platform'], 'flutter');
    });

    test('overrides existing lng in link token URL', () {
      final uri = _build(
        _config(
          url: 'https://link.meshconnect.com/path?lng=fr',
          language: 'pt',
        ),
      );
      expect(uri.queryParametersAll['lng'], ['pt']);
    });

    test('preserves existing query parameters from link token URL', () {
      final uri = _build(
        _config(url: 'https://link.meshconnect.com/path?existing=value'),
      );
      expect(uri.queryParameters['existing'], 'value');
    });
  });
}
