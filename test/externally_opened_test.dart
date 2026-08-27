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
        isExternallyOpenedOrigin('https://pay.coinbase.com/something'),
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
      expect(isExternallyOpenedOrigin('https://i.bybit.com/1TYabIso'), isTrue);
      expect(
        isExternallyOpenedOrigin('https://krak.app/request/abc123'),
        isTrue,
      );
      expect(
        isExternallyOpenedOrigin(
          'https://js.crypto.com/sdk/payments/checkout/set_wallet?id=abc',
        ),
        isTrue,
      );
      expect(
        isExternallyOpenedOrigin('https://cash.app/launch/abc123'),
        isTrue,
      );
    });

    // Revolut asked us not to carry their domains in SDK source; the checkout
    // reaches the browser via shouldExternaliseUnlistedNavigation instead.
    test('Returns false for every revolut host', () {
      expect(isExternallyOpenedOrigin('https://ramp.revolut.com'), isFalse);
      expect(isExternallyOpenedOrigin('https://ramp.revolut.codes'), isFalse);
      expect(isExternallyOpenedOrigin('https://sso.revolut.com'), isFalse);
      expect(isExternallyOpenedOrigin('https://revolut.com'), isFalse);
    });

    // The real value the backend serves for MetaMask's in-wallet browser, so a
    // change to the catalog shows up here.
    test('Returns true for the MetaMask in-wallet browser link', () {
      expect(
        isExternallyOpenedOrigin(
          'https://link.metamask.io/dapp/link.meshconnect.com/dapp/eyJhIjoiYiJ9',
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

    test('Returns false for lookalike domains (host-prefix attack)', () {
      expect(
        isExternallyOpenedOrigin('https://i.bybit.com.evil.com/path'),
        isFalse,
      );
      expect(
        isExternallyOpenedOrigin('https://cash.app.evil.com/launch/abc'),
        isFalse,
      );
      expect(
        isExternallyOpenedOrigin('https://link.trustwallet.com.evil.com/wc'),
        isFalse,
      );
      expect(
        isExternallyOpenedOrigin('https://link.metamask.io.evil.com/dapp/x'),
        isFalse,
      );
    });

    test('Returns false for lookalike paths (path-prefix attack)', () {
      expect(
        isExternallyOpenedOrigin(
          'https://sandbox.meshconnect.com/authorize/CoinbaseEvil',
        ),
        isFalse,
      );
      expect(
        isExternallyOpenedOrigin('https://go.rabby.io/mobileEvil/path'),
        isFalse,
      );
    });

    group('OAuth redirect regex', () {
      test('Returns true for matching subdomain and path', () {
        expect(
          isExternallyOpenedOrigin(
            'https://integration-api.meshconnect.com/api/v1/catalog/oauth/redirect/coinbase',
          ),
          isTrue,
        );
        expect(
          isExternallyOpenedOrigin(
            'https://sandbox-api.meshconnect.com/api/v1/catalog/oauth/redirect/some-provider',
          ),
          isTrue,
        );
      });

      test(
        'Returns true for variable path prefix before /catalog/oauth/redirect/',
        () {
          expect(
            isExternallyOpenedOrigin(
              'https://integration-api.meshconnect.com/api/v2/catalog/oauth/redirect/coinbase',
            ),
            isTrue,
          );
          expect(
            isExternallyOpenedOrigin(
              'https://integration-api.meshconnect.com/v3/catalog/oauth/redirect/coinbase',
            ),
            isTrue,
          );
          expect(
            isExternallyOpenedOrigin(
              'https://sandbox-api.meshconnect.com/some/nested/path/catalog/oauth/redirect/provider',
            ),
            isTrue,
          );
        },
      );

      test('Returns false when path does not match', () {
        expect(
          isExternallyOpenedOrigin(
            'https://integration-api.meshconnect.com/api/v1/catalog/oauth/other',
          ),
          isFalse,
        );
        expect(
          isExternallyOpenedOrigin(
            'https://integration-api.meshconnect.com/api/v1/catalog/oauth/redirect',
          ),
          isFalse,
        );
      });

      test('Returns false for non-meshconnect.com domains', () {
        expect(
          isExternallyOpenedOrigin(
            'https://integration-api.evil.com/api/v1/catalog/oauth/redirect/x',
          ),
          isFalse,
        );
        expect(
          isExternallyOpenedOrigin(
            'https://integration-api.meshconnect.com.evil.com/api/v1/catalog/oauth/redirect/x',
          ),
          isFalse,
        );
      });

      test('Returns false for bare meshconnect.com (no subdomain)', () {
        expect(
          isExternallyOpenedOrigin(
            'https://meshconnect.com/api/v1/catalog/oauth/redirect/x',
          ),
          isFalse,
        );
      });
    });
  });
}
