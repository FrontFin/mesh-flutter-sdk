import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/model/link_style.dart';

void main() {
  group('LinkStyle.fromJson', () {
    test('parses light theme', () {
      final style = LinkStyle.fromJson({'th': 'light'});
      expect(style.theme, ThemeMode.light);
    });

    test('parses dark theme', () {
      final style = LinkStyle.fromJson({'th': 'dark'});
      expect(style.theme, ThemeMode.dark);
    });

    test('parses system theme', () {
      final style = LinkStyle.fromJson({'th': 'system'});
      expect(style.theme, ThemeMode.system);
    });

    test('defaults to system for invalid theme', () {
      final style = LinkStyle.fromJson({'th': 'invalid'});
      expect(style.theme, ThemeMode.system);
    });

    test('defaults to system for missing key', () {
      final style = LinkStyle.fromJson({});
      expect(style.theme, ThemeMode.system);
    });
  });
}