import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/theme.dart';

String _encodeLinkStyle(Map<String, dynamic> json) =>
    base64Encode(utf8.encode(jsonEncode(json)));

/// Encodes a session token envelope as unpadded base64url.
String _encodeEnvelope(Map<String, Object?> json) =>
    base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');

Uri _linkUri({String? token, String? linkStyle}) => Uri.https(
  'link.meshconnect.com',
  '/',
  {'token': ?token, 'link_style': ?linkStyle},
);

void main() {
  group('resolveTheme', () {
    group('configurationTheme takes priority', () {
      test('returns light when configurationTheme is light', () {
        final uri = Uri.parse('https://example.com');
        expect(resolveTheme(uri, ThemeMode.light), ThemeMode.light);
      });

      test('returns dark when configurationTheme is dark', () {
        final uri = Uri.parse('https://example.com');
        expect(resolveTheme(uri, ThemeMode.dark), ThemeMode.dark);
      });

      test('returns system when configurationTheme is system', () {
        final uri = Uri.parse('https://example.com');
        expect(resolveTheme(uri, ThemeMode.system), ThemeMode.system);
      });

      test('ignores link_style param when configurationTheme is set', () {
        final encoded = _encodeLinkStyle({'th': 'dark'});
        final uri = Uri.parse('https://example.com?link_style=$encoded');
        expect(resolveTheme(uri, ThemeMode.light), ThemeMode.light);
      });
    });

    group('falls back to link_style param', () {
      test('returns light from link_style param', () {
        final encoded = _encodeLinkStyle({'th': 'light'});
        final uri = Uri.parse('https://example.com?link_style=$encoded');
        expect(resolveTheme(uri, null), ThemeMode.light);
      });

      test('returns dark from link_style param', () {
        final encoded = _encodeLinkStyle({'th': 'dark'});
        final uri = Uri.parse('https://example.com?link_style=$encoded');
        expect(resolveTheme(uri, null), ThemeMode.dark);
      });

      test('returns system when link_style th is system', () {
        final encoded = _encodeLinkStyle({'th': 'system'});
        final uri = Uri.parse('https://example.com?link_style=$encoded');
        expect(resolveTheme(uri, null), ThemeMode.system);
      });

      test('returns system when link_style th is unrecognised', () {
        final encoded = _encodeLinkStyle({'th': 'unknown'});
        final uri = Uri.parse('https://example.com?link_style=$encoded');
        expect(resolveTheme(uri, null), ThemeMode.system);
      });

      test('returns system when link_style JSON has no th key', () {
        final encoded = _encodeLinkStyle({});
        final uri = Uri.parse('https://example.com?link_style=$encoded');
        expect(resolveTheme(uri, null), ThemeMode.system);
      });
    });

    group('no link_style param', () {
      test(
        'returns system when no link_style param and no configurationTheme',
        () {
          final uri = Uri.parse('https://example.com');
          expect(resolveTheme(uri, null), ThemeMode.system);
        },
      );
    });

    group('session token theme', () {
      final darkToken = _encodeEnvelope({
        'v': 1,
        'c': 'a1b2c3d4-session-code',
        'th': 'LINK_THEME_DARK',
      });
      final lightToken = _encodeEnvelope({
        'v': 1,
        'c': 'a1b2c3d4-session-code',
        'th': 'LINK_THEME_LIGHT',
      });

      test('envelope is base64url (exercises - and _ handling)', () {
        final token = _encodeEnvelope({
          'v': 1,
          'c': '>>>???',
          'th': 'LINK_THEME_DARK',
        });
        expect(token, matches(RegExp('[-_]')));
        expect(resolveTheme(_linkUri(token: token), null), ThemeMode.dark);
      });

      test('returns dark from a DARK envelope', () {
        expect(resolveTheme(_linkUri(token: darkToken), null), ThemeMode.dark);
      });

      test('returns light from a LIGHT envelope', () {
        expect(
          resolveTheme(_linkUri(token: lightToken), null),
          ThemeMode.light,
        );
      });

      test('token theme applies when configurationTheme is system', () {
        expect(
          resolveTheme(_linkUri(token: darkToken), ThemeMode.system),
          ThemeMode.dark,
        );
      });

      test('explicit configurationTheme wins over the token theme', () {
        expect(
          resolveTheme(_linkUri(token: darkToken), ThemeMode.light),
          ThemeMode.light,
        );
        expect(
          resolveTheme(_linkUri(token: lightToken), ThemeMode.dark),
          ThemeMode.dark,
        );
      });

      test('token theme wins over legacy link_style', () {
        final linkStyle = _encodeLinkStyle({'th': 'light'});
        expect(
          resolveTheme(_linkUri(token: darkToken, linkStyle: linkStyle), null),
          ThemeMode.dark,
        );
      });

      test('raw (legacy) token falls back to device', () {
        expect(
          resolveTheme(_linkUri(token: 'raw-legacy-link-code'), null),
          ThemeMode.system,
        );
      });

      test('raw token falls back to legacy link_style', () {
        final linkStyle = _encodeLinkStyle({'th': 'dark'});
        expect(
          resolveTheme(
            _linkUri(token: 'raw-legacy-link-code', linkStyle: linkStyle),
            null,
          ),
          ThemeMode.dark,
        );
      });

      test('malformed token falls back to device', () {
        for (final token in [
          '!!!not-base64!!!',
          base64Url.encode(utf8.encode('not json')),
          base64Url.encode([0xff, 0xfe, 0xfd]),
          _encodeEnvelope({'v': '1', 'c': 'code', 'th': 'LINK_THEME_DARK'}),
          _encodeEnvelope({'v': 1, 'c': '', 'th': 'LINK_THEME_DARK'}),
          _encodeEnvelope({'v': 1, 'th': 'LINK_THEME_DARK'}),
          base64Url.encode(utf8.encode('["LINK_THEME_DARK"]')),
        ]) {
          expect(
            resolveTheme(_linkUri(token: token), null),
            ThemeMode.system,
            reason: token,
          );
        }
      });

      test('UNSPECIFIED th falls back to device', () {
        final token = _encodeEnvelope({
          'v': 1,
          'c': 'code',
          'th': 'LINK_THEME_UNSPECIFIED',
        });
        expect(resolveTheme(_linkUri(token: token), null), ThemeMode.system);
      });

      test('missing th falls back to device', () {
        final token = _encodeEnvelope({'v': 1, 'c': 'code'});
        expect(resolveTheme(_linkUri(token: token), null), ThemeMode.system);
      });

      test('missing th falls back to legacy link_style', () {
        final token = _encodeEnvelope({'v': 1, 'c': 'code'});
        final linkStyle = _encodeLinkStyle({'th': 'light'});
        expect(
          resolveTheme(_linkUri(token: token, linkStyle: linkStyle), null),
          ThemeMode.light,
        );
      });
    });
  });
}
