import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/theme.dart';

String _encodeLinkStyle(Map<String, dynamic> json) =>
    base64Encode(utf8.encode(jsonEncode(json)));

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
  });
}
