import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/theme.dart';

String _base64Url(Object json) =>
    base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');

// A link with a session token, the way the latest Link gets it.
String _sessionUrl(Map<String, Object?> envelope, [String extra = '']) =>
    'https://link.meshpay.com/?token=${_base64Url(envelope)}&flow=%7B%7D$extra';

// A legacy link, with the client's style in link_style (standard base64, URL
// encoded).
String _linkStyle(Object style) =>
    Uri.encodeQueryComponent(base64Encode(utf8.encode(jsonEncode(style))));
String _legacyUrl([Map<String, Object?>? style, String extra = '']) =>
    'https://link.meshconnect.com/?auth_code=x'
    '${style == null ? '' : '&link_style=${_linkStyle(style)}'}$extra';

LinkAppearance _resolve(String url, {required bool systemIsDark}) {
  final query = Uri.parse(url).queryParametersAll;
  return resolveLinkAppearance(
    urlTheme: query['th']?.first,
    token: query['token']?.first,
    linkStyle: query['link_style']?.first,
    platformBrightness: systemIsDark ? Brightness.dark : Brightness.light,
  );
}

bool _isDark(String url, {required bool systemIsDark}) =>
    _resolve(url, systemIsDark: systemIsDark).isDarkTheme;

Color _background(String url, {required bool systemIsDark}) =>
    _resolve(url, systemIsDark: systemIsDark).backgroundColor;

void main() {
  group('theme of a link with a session token', () {
    const client = {'v': 1, 'c': 'client'};

    test('th=light or th=dark in the URL wins over the token theme', () {
      expect(
        _isDark(
          _sessionUrl({...client, 'th': 'LINK_THEME_DARK'}, '&th=light'),
          systemIsDark: true,
        ),
        isFalse,
      );
      expect(
        _isDark(
          _sessionUrl({...client, 'th': 'LINK_THEME_LIGHT'}, '&th=dark'),
          systemIsDark: false,
        ),
        isTrue,
      );
    });

    test('then the theme in the token', () {
      expect(
        _isDark(
          _sessionUrl({...client, 'th': 'LINK_THEME_DARK'}),
          systemIsDark: false,
        ),
        isTrue,
      );
      expect(
        _isDark(
          _sessionUrl({...client, 'th': 'LINK_THEME_LIGHT'}),
          systemIsDark: true,
        ),
        isFalse,
      );
    });

    test('th=system leaves it to the token, so the token theme still wins', () {
      expect(
        _isDark(
          _sessionUrl({...client, 'th': 'LINK_THEME_LIGHT'}, '&th=system'),
          systemIsDark: true,
        ),
        isFalse,
      );
      expect(
        _isDark(
          _sessionUrl({...client, 'th': 'LINK_THEME_DARK'}, '&th=system'),
          systemIsDark: false,
        ),
        isTrue,
      );
    });

    test('then the device, whether th is system, missing or garbage', () {
      for (final extra in ['', '&th=system', '&th=blue', '&th=']) {
        for (final dark in [true, false]) {
          expect(_isDark(_sessionUrl(client, extra), systemIsDark: dark), dark);
        }
      }
    });

    test('a token theme that is unspecified or unknown follows the device', () {
      for (final th in ['LINK_THEME_UNSPECIFIED', 'constructor', 7, null]) {
        for (final dark in [true, false]) {
          expect(
            _isDark(_sessionUrl({...client, 'th': th}), systemIsDark: dark),
            dark,
          );
        }
      }
    });

    test('link_style is not read', () {
      final url = _sessionUrl(
        client,
        '&link_style=${_linkStyle({'th': 'dark'})}',
      );
      expect(_isDark(url, systemIsDark: false), isFalse);
    });

    test('a token that is not a session token is a legacy link', () {
      final notSession = [
        {'c': 'client', 'th': 'LINK_THEME_DARK'},
        {'v': '1', 'c': 'client', 'th': 'LINK_THEME_DARK'},
        {'v': 1, 'c': '', 'th': 'LINK_THEME_DARK'},
        {'v': 1, 'th': 'LINK_THEME_DARK'},
      ];
      for (final envelope in notSession) {
        // Legacy: the token theme is ignored and the default is dark.
        expect(_isDark(_sessionUrl(envelope), systemIsDark: false), isTrue);
      }
      expect(
        _isDark(
          'https://link.meshpay.com/?token=not-json',
          systemIsDark: false,
        ),
        isTrue,
      );
    });
  });

  group('theme of a legacy link', () {
    test('th=light or th=dark in the URL wins over link_style', () {
      expect(
        _isDark(_legacyUrl({'th': 'dark'}, '&th=light'), systemIsDark: true),
        isFalse,
      );
      expect(
        _isDark(_legacyUrl({'th': 'light'}, '&th=dark'), systemIsDark: false),
        isTrue,
      );
    });

    test('th=system means the device, even when link_style has a theme', () {
      expect(
        _isDark(_legacyUrl({'th': 'dark'}, '&th=system'), systemIsDark: false),
        isFalse,
      );
      expect(
        _isDark(_legacyUrl({'th': 'light'}, '&th=system'), systemIsDark: true),
        isTrue,
      );
    });

    test('then link_style.th, with system read from the device', () {
      expect(_isDark(_legacyUrl({'th': 'light'}), systemIsDark: true), isFalse);
      expect(_isDark(_legacyUrl({'th': 'dark'}), systemIsDark: false), isTrue);
      expect(
        _isDark(_legacyUrl({'th': 'light'}, '&th=blue'), systemIsDark: true),
        isFalse,
      );
      expect(
        _isDark(_legacyUrl({'th': 'system'}), systemIsDark: false),
        isFalse,
      );
      expect(_isDark(_legacyUrl({'th': 'system'}), systemIsDark: true), isTrue);
    });

    test('link_style survives a stripped padding and a + read as a space', () {
      // base64 of '{"th":"light","x":"?>"}' has a '+'
      const withPlus = 'eyJ0aCI6ImxpZ2h0IiwieCI6Ij8+In0=';
      String url(String value) =>
          'https://link.meshconnect.com/?link_style=$value';
      for (final value in [
        withPlus.replaceAll('=', ''),
        withPlus.replaceAll('+', ' '),
      ]) {
        final query = Uri.parse(url(value)).queryParametersAll;
        final appearance = resolveLinkAppearance(
          urlTheme: null,
          token: null,
          linkStyle: query['link_style']?.first,
          platformBrightness: Brightness.dark,
        );
        expect(appearance.isDarkTheme, isFalse);
      }
    });

    test('then the default (dark), even on a light device', () {
      expect(_isDark(_legacyUrl(), systemIsDark: false), isTrue);
      expect(
        _isDark('https://link.meshconnect.com/', systemIsDark: false),
        isTrue,
      );
      for (final value in [
        '',
        '%25%25%25',
        'bm90IGpzb24=',
        'e30=',
        'eyJ0aCI6IiJ9',
      ]) {
        expect(
          _isDark(
            'https://link.meshconnect.com/?link_style=$value',
            systemIsDark: false,
          ),
          isTrue,
        );
      }
    });
  });

  group('themeToWrite', () {
    test('is set for a legacy link the device decides', () {
      for (final dark in [true, false]) {
        for (final url in [
          _legacyUrl({'th': 'system'}),
          '${_legacyUrl()}&th=system',
        ]) {
          expect(
            _resolve(url, systemIsDark: dark).themeToWrite,
            dark ? Brightness.dark : Brightness.light,
          );
        }
      }
    });

    test(
      'is not set when the device does not decide, or on a session link',
      () {
        expect(
          _resolve(_legacyUrl(), systemIsDark: false).themeToWrite,
          isNull,
        );
        expect(
          _resolve(
            _legacyUrl({'th': 'light'}),
            systemIsDark: true,
          ).themeToWrite,
          isNull,
        );
        expect(
          _resolve(
            _sessionUrl({'v': 1, 'c': 'client'}, '&th=system'),
            systemIsDark: true,
          ).themeToWrite,
          isNull,
        );
      },
    );
  });

  group('background color', () {
    test("uses the page's bgd on dark and bgl on light, from the token", () {
      final envelope = {
        'v': 1,
        'c': 'client',
        'bgl': '#112233',
        'bgd': '#445566',
      };
      expect(
        _background(_sessionUrl(envelope, '&th=dark'), systemIsDark: false),
        const Color(0xFF445566),
      );
      expect(
        _background(_sessionUrl(envelope, '&th=light'), systemIsDark: true),
        const Color(0xFF112233),
      );
    });

    test('and from link_style on a legacy link', () {
      final style = {'bgl': '#112233', 'bgd': '#445566'};
      expect(
        _background(_legacyUrl(style, '&th=dark'), systemIsDark: false),
        const Color(0xFF445566),
      );
      expect(
        _background(_legacyUrl(style, '&th=light'), systemIsDark: true),
        const Color(0xFF112233),
      );
    });

    test('a short hex is expanded and the alpha is dropped', () {
      Color color(String bgd) => _background(
        _sessionUrl({'v': 1, 'c': 'client', 'bgd': bgd}, '&th=dark'),
        systemIsDark: false,
      );
      expect(color('#abc'), const Color(0xFFAABBCC));
      expect(color('#abcd'), const Color(0xFFAABBCC));
      expect(color('#11223344'), const Color(0xFF112233));
      expect(color('#ABCDEF'), const Color(0xFFABCDEF));
    });

    test(
      'a missing or invalid color falls back, for each theme on its own',
      () {
        for (final bad in [
          'red',
          'rgb(1,2,3)',
          '#12',
          '#12345',
          '#ggg',
          '',
          123,
          null,
        ]) {
          expect(
            _background(
              _sessionUrl({'v': 1, 'c': 'client', 'bgd': bad}, '&th=dark'),
              systemIsDark: false,
            ),
            const Color(0xFF1C1C1C),
          );
        }
        // Only the other theme has a color.
        final onlyLight = {'v': 1, 'c': 'client', 'bgl': '#123456'};
        expect(
          _background(_sessionUrl(onlyLight, '&th=dark'), systemIsDark: false),
          const Color(0xFF1C1C1C),
        );
        expect(
          _background(_sessionUrl(onlyLight, '&th=light'), systemIsDark: true),
          const Color(0xFF123456),
        );
        // A legacy link has its own pair.
        expect(
          _background(_legacyUrl(), systemIsDark: false),
          const Color(0xFF0E0D0D),
        );
        expect(
          _background(_legacyUrl({'th': 'light'}), systemIsDark: true),
          const Color(0xFFFBFBFB),
        );
        expect(
          _background(
            _sessionUrl({'v': 1, 'c': 'client'}, '&th=light'),
            systemIsDark: true,
          ),
          const Color(0xFFF9F9F9),
        );
      },
    );
  });

  group('isDarkColor', () {
    test('tells dark from light, including the fallback colors', () {
      expect(isDarkColor(const Color(0xFF000000)), isTrue);
      expect(isDarkColor(const Color(0xFF445566)), isTrue);
      expect(isDarkColor(const Color(0xFFFFFFFF)), isFalse);
      expect(isDarkColor(const Color(0xFFDDEEFF)), isFalse);
      for (final dark in [0xFF1C1C1C, 0xFF0E0D0D]) {
        expect(isDarkColor(Color(dark)), isTrue);
      }
      for (final light in [0xFFF9F9F9, 0xFFFBFBFB]) {
        expect(isDarkColor(Color(light)), isFalse);
      }
    });
  });
}
