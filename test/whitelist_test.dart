import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/constants.dart';

void main() {
  group('isWhitelistedOrigin', () {
    test('Returns true for whitelisted origins', () {
      expect(isWhitelistedOrigin('https://meshconnect.com'), isTrue);
      expect(isWhitelistedOrigin('https://getfront.com'), isTrue);
      expect(isWhitelistedOrigin('https://walletconnect.com'), isTrue);
      expect(isWhitelistedOrigin('https://walletconnect.org'), isTrue);
      expect(isWhitelistedOrigin('https://walletlink.org'), isTrue);
      expect(isWhitelistedOrigin('https://okx.com'), isTrue);
      expect(isWhitelistedOrigin('https://gemini.com'), isTrue);
      expect(isWhitelistedOrigin('https://hcaptcha.com'), isTrue);
      expect(isWhitelistedOrigin('https://robinhood.com'), isTrue);
      expect(isWhitelistedOrigin('https://google.com'), isTrue);
    });

    test('Returns true for wildcard origins', () {
      expect(isWhitelistedOrigin('https://subdomain.meshconnect.com'), isTrue);
      expect(isWhitelistedOrigin('https://subdomain.getfront.com'), isTrue);
    });

    test('returns true for custom schemes', () {
      expect(isWhitelistedOrigin('robinhood://'), isTrue);
    });

    test('Returns true for about:blank', () {
      expect(isWhitelistedOrigin('about:blank'), isTrue);
    });

    test('Returns false for non-whitelisted origins', () {
      expect(isWhitelistedOrigin('https://example.com'), isFalse);
      expect(isWhitelistedOrigin('http://meshconnect.com'), isFalse);
      expect(isWhitelistedOrigin('ftp://getfront.com'), isFalse);
      expect(isWhitelistedOrigin('meshconnect://'), isFalse);
    });
  });
}
