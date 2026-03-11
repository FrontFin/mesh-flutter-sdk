import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/language.dart';

void main() {
  group('resolveLanguage', () {
    test('returns the language as-is for explicit values', () {
      expect(resolveLanguage('en'), 'en');
      expect(resolveLanguage('es'), 'es');
      expect(resolveLanguage('pt'), 'pt');
    });

    test('returns any arbitrary string unchanged', () {
      expect(resolveLanguage('fr'), 'fr');
      expect(resolveLanguage('zh'), 'zh');
    });

    testWidgets('returns a non-empty language code for system', (tester) async {
      final result = resolveLanguage('system');
      expect(result, isNotEmpty);
      expect(result, isNot('system'));
    });

    testWidgets('system returns the platform locale language code',
        (tester) async {
      final platformLocale =
          tester.binding.platformDispatcher.locale.languageCode;
      expect(resolveLanguage('system'), platformLocale);
    });
  });
}
