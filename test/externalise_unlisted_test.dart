import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/constants.dart';

void main() {
  group('shouldExternaliseUnlistedNavigation', () {
    test('hands an https page to the browser', () {
      expect(
        shouldExternaliseUnlistedNavigation(
          'https://ramp.revolut.com/payment?amount=817',
        ),
        isTrue,
      );
    });

    test('refuses anything that is not https', () {
      for (final url in [
        'http://ramp.revolut.com/payment',
        'about:blank',
        'javascript:alert(1)',
        'data:text/html,<script>alert(1)</script>',
        'meshconnect://callback',
        ':::',
      ]) {
        expect(shouldExternaliseUnlistedNavigation(url), isFalse, reason: url);
      }
    });
  });
}
