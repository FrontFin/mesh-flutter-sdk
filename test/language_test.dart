import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/language.dart';

void main() {
  group('resolveLanguage', () {
    test('returns the language as-is for explicit values', () {
      expect(resolveLanguage('en'), 'en');
      expect(resolveLanguage('es'), 'es');
      expect(resolveLanguage('pt-BR'), 'pt-BR');
    });

    test('trims the value', () {
      expect(resolveLanguage(' es '), 'es');
    });

    test('returns null when empty', () {
      expect(resolveLanguage(''), isNull);
      expect(resolveLanguage('  '), isNull);
    });

    testWidgets('system returns the platform locale tag', (tester) async {
      final platformLocale = tester.binding.platformDispatcher.locale
          .toLanguageTag();
      expect(resolveLanguage('system'), platformLocale);
      expect(resolveLanguage('system'), isNot('system'));
    });
  });
}
