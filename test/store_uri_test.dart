import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/constants.dart';

void main() {
  group('getStoreUriFromAppUri', () {
    test('Returns Play Store URL for exodus scheme', () {
      final uri = Uri.parse('exodus://some/path');
      final result = getStoreUriFromAppUri(uri);

      expect(result, isNotNull);
      expect(
        result.toString(),
        'https://play.google.com/store/apps/details?id=exodusmovement.exodus',
      );
    });

    test('Returns Play Store URL for exodus scheme with empty path', () {
      final uri = Uri.parse('exodus://');
      final result = getStoreUriFromAppUri(uri);

      expect(result, isNotNull);
      expect(
        result.toString(),
        'https://play.google.com/store/apps/details?id=exodusmovement.exodus',
      );
    });

    test('Returns null for https scheme', () {
      final uri = Uri.parse('https://example.com');
      final result = getStoreUriFromAppUri(uri);

      expect(result, isNull);
    });

    test('Returns null for http scheme', () {
      final uri = Uri.parse('http://example.com');
      final result = getStoreUriFromAppUri(uri);

      expect(result, isNull);
    });

    test('Returns null for other custom schemes', () {
      final uri = Uri.parse('robinhood://some/path');
      final result = getStoreUriFromAppUri(uri);

      expect(result, isNull);
    });

    test('Returns null for empty scheme', () {
      final uri = Uri.parse('/just/a/path');
      final result = getStoreUriFromAppUri(uri);

      expect(result, isNull);
    });
  });
}
