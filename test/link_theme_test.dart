import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/ui/theme.dart';
import 'package:mesh_sdk_flutter/src/util/theme.dart';

String _linkStyle(String json) => base64Encode(utf8.encode(json));

Brightness _resolve({
  Brightness? appTheme,
  String? urlTheme,
  String? linkStyle,
  Brightness platformBrightness = Brightness.light,
}) => resolveLinkTheme(
  appTheme: appTheme,
  urlTheme: urlTheme,
  linkStyle: linkStyle,
  platformBrightness: platformBrightness,
);

void main() {
  group('resolveTheme', () {
    test('maps light, dark and system', () {
      expect(resolveTheme('light', Brightness.dark), Brightness.light);
      expect(resolveTheme('dark', Brightness.light), Brightness.dark);
      expect(resolveTheme('system', Brightness.dark), Brightness.dark);
    });

    test('returns null for anything else', () {
      expect(resolveTheme(null, Brightness.dark), isNull);
      expect(resolveTheme('unknown', Brightness.dark), isNull);
    });
  });

  group('resolveLinkTheme', () {
    test('prefers the app theme', () {
      expect(
        _resolve(
          appTheme: Brightness.light,
          urlTheme: 'dark',
          linkStyle: _linkStyle('{"th":"dark"}'),
        ),
        Brightness.light,
      );
    });

    test('then the url th, including system', () {
      expect(
        _resolve(urlTheme: 'dark', linkStyle: _linkStyle('{"th":"light"}')),
        Brightness.dark,
      );
      expect(
        _resolve(urlTheme: 'system', platformBrightness: Brightness.dark),
        Brightness.dark,
      );
    });

    test('then link_style when there is no usable th', () {
      expect(
        _resolve(urlTheme: 'unknown', linkStyle: _linkStyle('{"th":"dark"}')),
        Brightness.dark,
      );
      expect(
        _resolve(
          linkStyle: _linkStyle('{"th":"system"}'),
          platformBrightness: Brightness.dark,
        ),
        Brightness.dark,
      );
    });

    test('reads link_style with a plus turned into a space and no padding', () {
      final style = _linkStyle('{"th":"light","x":"~~~"}');
      expect(style, contains('+'));
      expect(
        _resolve(
          linkStyle: style.replaceAll('+', ' ').replaceAll('=', ''),
          platformBrightness: Brightness.dark,
        ),
        Brightness.light,
      );
    });

    test('defaults to dark when nothing is set or link_style is broken', () {
      expect(_resolve(), Brightness.dark);
      expect(_resolve(linkStyle: _linkStyle('{"other":1}')), Brightness.dark);
      expect(_resolve(linkStyle: '%%%'), Brightness.dark);
    });
  });

  group('getNavBarColor', () {
    test('uses one color per theme', () {
      expect(getNavBarColor(Brightness.dark), const Color(0xFF1C1C1C));
      expect(getNavBarColor(Brightness.light), const Color(0xFFF9F9F9));
    });
  });
}
