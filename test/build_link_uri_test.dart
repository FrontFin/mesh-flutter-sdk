import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';
import 'package:mesh_sdk_flutter/src/util/link_uri.dart';

LinkUri _build(
  String url, {
  String language = 'en',
  String? displayFiatCurrency,
  ThemeMode? theme,
  Brightness platformBrightness = Brightness.light,
}) => buildLinkUri(
  MeshConfiguration(
    linkToken: base64Encode(utf8.encode(url)),
    language: language,
    displayFiatCurrency: displayFiatCurrency,
    theme: theme,
  ),
  platformBrightness: platformBrightness,
);

void main() {
  group('buildLinkUri', () {
    test('replaces the token th with the app theme', () {
      final result = _build(
        'https://link.meshpay.com/?token=abc&th=dark&clientId=org-1',
        theme: ThemeMode.light,
      );
      expect(
        result.uri.toString(),
        'https://link.meshpay.com/?token=abc&clientId=org-1'
        '&th=light&lng=en&platform=flutter',
      );
      expect(result.brightness, Brightness.light);
    });

    test('sends a system app theme as the device theme', () {
      final result = _build(
        'https://a.com/?token=abc',
        theme: ThemeMode.system,
        platformBrightness: Brightness.dark,
      );
      expect(result.uri.queryParameters['th'], 'dark');
      expect(result.brightness, Brightness.dark);
    });

    test('keeps the token th when the app sets none', () {
      final result = _build('https://a.com/?th=light&token=abc');
      expect(
        result.uri.toString(),
        'https://a.com/?th=light&token=abc&lng=en&platform=flutter',
      );
      expect(result.brightness, Brightness.light);
    });

    test('reports the link_style theme without writing th', () {
      final style = base64Encode(utf8.encode('{"th":"system"}'));
      final result = _build(
        'https://a.com/?link_style=$style',
        platformBrightness: Brightness.dark,
      );
      expect(result.uri.queryParameters.containsKey('th'), isFalse);
      expect(result.brightness, Brightness.dark);
    });

    test('reports dark when nothing sets a theme, without writing th', () {
      final result = _build('https://a.com/?token=abc');
      expect(
        result.uri.toString(),
        'https://a.com/?token=abc&lng=en&platform=flutter',
      );
      expect(result.brightness, Brightness.dark);
    });

    test('replaces every param it sets, not just th', () {
      final result = _build(
        'https://a.com/?lng=fr&token=abc&fiatCur=GBP&platform=web&lng=es',
        theme: ThemeMode.dark,
        language: 'pt',
        displayFiatCurrency: 'EUR',
      );
      expect(
        result.uri.toString(),
        'https://a.com/?token=abc&th=dark&lng=pt&fiatCur=EUR&platform=flutter',
      );
    });

    test('keeps the token currency when the app sets none', () {
      final result = _build('https://a.com/?fiatCur=GBP');
      expect(result.uri.queryParametersAll['fiatCur'], ['GBP']);
    });

    test('keeps the other params, empty parts and the fragment', () {
      final result = _build('https://a.com/?token=a+b%2F&&th=dark#x');
      expect(
        result.uri.toString(),
        'https://a.com/?token=a+b%2F&&th=dark&lng=en&platform=flutter#x',
      );
    });

    test('adds a query when the url has none', () {
      expect(
        _build('https://a.com/path#x').uri.toString(),
        'https://a.com/path?lng=en&platform=flutter#x',
      );
    });

    test('matches an encoded key when replacing th', () {
      expect(
        _build(
          'https://a.com/?t%68=light&th=dark',
          theme: ThemeMode.dark,
        ).uri.toString(),
        'https://a.com/?th=dark&lng=en&platform=flutter',
      );
    });

    test('reads the first th for the theme', () {
      expect(
        _build('https://a.com/?t%68=light&th=dark').brightness,
        Brightness.light,
      );
    });

    test('encodes the values it adds', () {
      expect(
        _build('https://a.com/', displayFiatCurrency: 'E R&').uri.toString(),
        'https://a.com/?lng=en&fiatCur=E+R%26&platform=flutter',
      );
    });

    test('ignores a blank language and currency', () {
      expect(
        _build(
          'https://a.com/',
          language: '',
          displayFiatCurrency: ' ',
        ).uri.toString(),
        'https://a.com/?platform=flutter',
      );
    });
  });
}
