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
      expect(isWhitelistedOrigin('https://preview1.meshconnect.com'), isTrue);
      expect(isWhitelistedOrigin('https://preview2.getfront.com'), isTrue);
      expect(isWhitelistedOrigin('https://pay.meshpay.com'), isTrue);
      expect(isWhitelistedOrigin('https://sandbox.meshpay.com/path'), isTrue);
      expect(isWhitelistedOrigin('https://myapp.local'), isTrue);
      expect(isWhitelistedOrigin('https://myapp.localcan.dev'), isTrue);
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

    test('Returns false for wildcard lookalikes without a dot boundary', () {
      expect(isWhitelistedOrigin('https://evilmeshpay.com'), isFalse);
      expect(isWhitelistedOrigin('https://notmeshpay.com'), isFalse);
      expect(isWhitelistedOrigin('https://evilmeshconnect.com'), isFalse);
      expect(isWhitelistedOrigin('https://evilgetfront.com'), isFalse);
      expect(isWhitelistedOrigin('https://meshpay.com.evil.com'), isFalse);
    });

    test('Returns false for the bare wildcard root', () {
      expect(isWhitelistedOrigin('https://meshpay.com'), isFalse);
    });
  });
}
