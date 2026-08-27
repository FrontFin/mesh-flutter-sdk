import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/constants.dart';

void main() {
  group('shouldExternaliseUnlistedNavigation', () {
    test('hands an https page to the browser', () {
      expect(
        shouldExternaliseUnlistedNavigation(
          'https://checkout.example/payment?amount=817',
        ),
        isTrue,
      );
    });

    test('refuses anything that is not https', () {
      for (final url in [
        'http://checkout.example/payment',
        'about:blank',
        'javascript:alert(1)',
        'data:text/html,<script>alert(1)</script>',
        'meshconnect://callback',
        ':::',
      ]) {
        expect(shouldExternaliseUnlistedNavigation(url), isFalse, reason: url);
      }
    });

    // An https URI with no authority is not navigable.
    test('refuses https with no host', () {
      expect(shouldExternaliseUnlistedNavigation('https:'), isFalse);
      expect(shouldExternaliseUnlistedNavigation('https:///path'), isFalse);
    });
  });
}
