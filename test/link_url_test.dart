import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';
import 'package:mesh_sdk_flutter/src/util/link_url.dart';

String _base64Url(Object json) =>
    base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');

String _sessionBase(Map<String, Object?> envelope) =>
    'https://link.meshpay.com/?token=${_base64Url(envelope)}'
    '&flow=%7B%22flow%22%3A%22login%22%7D';

final _mfsUrl = _sessionBase({'v': 1, 'c': 'client', 'th': 'LINK_THEME_LIGHT'});
const _legacyUrl =
    'https://link.meshconnect.com/?link_style=eyJ0aCI6ImxpZ2h0In0%3D&x=%7B%7D';

LinkUrl _build(
  String url, {
  String language = '',
  String? displayFiatCurrency,
  ThemeMode? theme,
  bool systemIsDark = false,
}) => buildLinkUrl(
  MeshConfiguration(
    linkToken: base64Encode(utf8.encode(url)),
    language: language,
    displayFiatCurrency: displayFiatCurrency,
    theme: theme,
  ),
  platformBrightness: systemIsDark ? Brightness.dark : Brightness.light,
);

String _url(String url, {ThemeMode? theme, bool systemIsDark = false}) =>
    _build(url, theme: theme, systemIsDark: systemIsDark).url.toString();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('buildLinkUrl', () {
    test('replaces th, lng, fiatCur and platform, keeps the rest as is', () {
      final built = _build(
        '$_mfsUrl&th=dark&lng=fr&fiatCur=EUR&platform=web#f',
        theme: ThemeMode.light,
        language: 'de',
        displayFiatCurrency: 'USD',
      );
      expect(
        built.url.toString(),
        '$_mfsUrl&th=light&lng=de&fiatCur=USD&platform=flutter#f',
      );
      expect(built.isDarkTheme, isFalse);
    });

    test('a token with th twice ends up with one th', () {
      final url = _url('$_mfsUrl&th=dark&th=dark', theme: ThemeMode.light);
      expect(RegExp('[?&]th=').allMatches(url), hasLength(1));
      expect(url, contains('&th=light'));
    });

    test("without an app theme the token's th stays and decides the theme", () {
      final built = _build('$_mfsUrl&th=dark');
      expect(built.url.toString(), '$_mfsUrl&th=dark&platform=flutter');
      expect(built.isDarkTheme, isTrue);
      expect(built.backgroundColor, const Color(0xFF1C1C1C));

      final legacy = _build(_legacyUrl, systemIsDark: true);
      expect(legacy.url.toString(), '$_legacyUrl&platform=flutter');
      expect(legacy.isDarkTheme, isFalse);
      expect(legacy.backgroundColor, const Color(0xFFFBFBFB));
    });

    test(
      'system is sent as system, the theme follows the token, then the device',
      () {
        for (final dark in [true, false]) {
          final built = _build(
            _mfsUrl,
            theme: ThemeMode.system,
            systemIsDark: dark,
          );
          expect(built.url.toString(), contains('&th=system&'));
          // The token says light, so the device does not matter.
          expect(built.isDarkTheme, isFalse);

          final noTokenTheme = _sessionBase({'v': 1, 'c': 'client'});
          expect(
            _build(
              noTokenTheme,
              theme: ThemeMode.system,
              systemIsDark: dark,
            ).isDarkTheme,
            dark,
          );
          expect(
            _build(
              _legacyUrl,
              theme: ThemeMode.system,
              systemIsDark: dark,
            ).isDarkTheme,
            dark,
          );
        }
      },
    );

    test('on a legacy link, a device-decided theme is written resolved', () {
      const style = 'eyJ0aCI6InN5c3RlbSJ9'; // {"th":"system"}
      const systemStyle = 'https://link.meshconnect.com/?link_style=$style';
      // App system, link_style system, th=system in the token: all follow
      // the device.
      for (final (link, theme) in [
        (_legacyUrl, ThemeMode.system),
        (systemStyle, null),
        ('$_legacyUrl&th=system', null),
      ]) {
        final dark = _build(link, theme: theme, systemIsDark: true);
        expect(dark.isDarkTheme, isTrue);
        expect(dark.url.queryParametersAll['th'], ['dark']);
        expect(Uri.parse(_url(link, theme: theme)).queryParametersAll['th'], [
          'light',
        ]);
      }
    });

    test(
      'on a legacy link, a theme the device does not decide is not written',
      () {
        expect(_url(_legacyUrl, systemIsDark: true), isNot(contains('th=')));
        expect(_url('https://link.meshconnect.com/'), isNot(contains('th=')));
      },
    );

    test('on a link with a session token, system stays system', () {
      expect(
        _url(_mfsUrl, theme: ThemeMode.system, systemIsDark: true),
        contains('&th=system&'),
      );
      expect(_url(_mfsUrl, systemIsDark: true), isNot(contains('th=')));
    });

    test(
      'system replaces the th=dark the backend adds on silent migration',
      () {
        expect(
          _url('$_mfsUrl&th=dark', theme: ThemeMode.system, systemIsDark: true),
          '$_mfsUrl&th=system&platform=flutter',
        );
      },
    );

    test("returns the page's own color from the token", () {
      final url = _sessionBase({
        'v': 1,
        'c': 'client',
        'bgl': '#112233',
        'bgd': '#445566',
      });
      expect(
        _build(url, theme: ThemeMode.dark).backgroundColor,
        const Color(0xFF445566),
      );
      expect(
        _build(url, theme: ThemeMode.light, systemIsDark: true).backgroundColor,
        const Color(0xFF112233),
      );
    });

    test('system language is sent as the full device tag', () {
      final dispatcher = TestWidgetsFlutterBinding.instance.platformDispatcher
        ..localesTestValue = const [Locale('en', 'US')];
      addTearDown(dispatcher.clearLocalesTestValue);

      expect(
        _build(_mfsUrl, language: 'system').url.toString(),
        contains('&lng=en-US&'),
      );
    });

    test('blank language and currency are not sent', () {
      expect(
        _build(_mfsUrl, language: ' ', displayFiatCurrency: ' ').url.toString(),
        '$_mfsUrl&platform=flutter',
      );
    });

    test('values are trimmed and encoded', () {
      expect(
        _build(
          _mfsUrl,
          language: ' pt-BR ',
          displayFiatCurrency: ' EUR ',
        ).url.toString(),
        contains('&lng=pt-BR&fiatCur=EUR&'),
      );
      expect(
        _build('https://a.com/', displayFiatCurrency: 'E R&').url.toString(),
        'https://a.com/?fiatCur=E+R%26&platform=flutter',
      );
    });

    test('keeps the other params, empty parts and the fragment', () {
      expect(
        _url('https://a.com/?token=a+b%2F&&th=dark#x'),
        'https://a.com/?token=a+b%2F&&th=dark&platform=flutter#x',
      );
    });

    test('adds a query when the url has none', () {
      expect(
        _url('https://a.com/path#x'),
        'https://a.com/path?platform=flutter#x',
      );
    });

    test('matches an encoded key when replacing th', () {
      expect(
        _url('https://a.com/?t%68=light&th=dark', theme: ThemeMode.dark),
        'https://a.com/?th=dark&platform=flutter',
      );
    });

    test('reads the first th for the theme', () {
      expect(_build('https://a.com/?t%68=light&th=dark').isDarkTheme, isFalse);
    });
  });
}
