import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/constants.dart';

void main() {
  group('isExternallyOpenedOrigin', () {
    test('Returns true for whitelisted origins', () {
      expect(
        isExternallyOpenedOrigin('https://link.trustwallet.com/something'),
        isTrue,
      );
      expect(
        isExternallyOpenedOrigin('https://appopener.meshconnect.com/something'),
        isTrue,
      );
      expect(
        isExternallyOpenedOrigin('https://coinbase.com/something'),
        isTrue,
      );
      expect(
        isExternallyOpenedOrigin('https://www.coinbase.com/something'),
        isTrue,
      );
      expect(
        isExternallyOpenedOrigin('https://login.coinbase.com/something'),
        isTrue,
      );
      expect(
        isExternallyOpenedOrigin(
          'https://api.cb-device-intelligence.com/something',
        ),
        isTrue,
      );
      expect(
        isExternallyOpenedOrigin(
          'https://exodus.com/m/wc?uri=wc%3A935389b9989400492b52a78a14f5a514',
        ),
        isTrue,
      );
    });

    test('Returns false for about:blank', () {
      expect(isExternallyOpenedOrigin('about:blank'), isFalse);
    });

    test('Returns false for non-whitelisted origins', () {
      expect(isExternallyOpenedOrigin('https://example.com'), isFalse);
      expect(isExternallyOpenedOrigin('http://meshconnect.com'), isFalse);
      expect(isExternallyOpenedOrigin('ftp://getfront.com'), isFalse);
      expect(isExternallyOpenedOrigin('meshconnect://'), isFalse);
    });
  });
}
