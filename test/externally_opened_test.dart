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
      expect(
        isExternallyOpenedOrigin('https://ramp.revolut.com/order/abc123'),
        isTrue,
      );
    });

    // Without this entry the Revolut Connect handoff was a dead tap: the ramp
    // URL is in no list, so `onNavigationRequest` fell through to
    // `NavigationDecision.prevent` and only a device log recorded it. iOS is
    // unaffected because its default for an unlisted host is to leave the
    // WebView; Flutter's is to refuse.
    // Both environments: `.com` is Revolut prod, `.codes` is Revolut's dev env
    // wired to Mesh dev. The hosts differ per environment, so listing only one
    // leaves the handoff dead on the other.
    test('Returns true for the Revolut Connect ramp handoff', () {
      expect(isExternallyOpenedOrigin('https://ramp.revolut.com'), isTrue);
      expect(
        isExternallyOpenedOrigin(
          'https://ramp.revolut.com/?order_id=abc&amount=50',
        ),
        isTrue,
      );
      expect(isExternallyOpenedOrigin('https://ramp.revolut.codes'), isTrue);
      expect(
        isExternallyOpenedOrigin(
          'https://ramp.revolut.codes/?order_id=abc&amount=50',
        ),
        isTrue,
      );
    });

    // Revolut's own sign-in hop happens in the browser, after we have handed
    // over, so it must NOT be listed here. Pinned so nobody "completes the set"
    // and widens the surface for no reason.
    test('Returns false for other revolut hosts', () {
      expect(isExternallyOpenedOrigin('https://sso.revolut.com'), isFalse);
      expect(isExternallyOpenedOrigin('https://revolut.com'), isFalse);
      expect(isExternallyOpenedOrigin('https://sso.revolut.codes'), isFalse);
      expect(isExternallyOpenedOrigin('https://revolut.codes'), isFalse);
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
      expect(
        isExternallyOpenedOrigin('https://ramp.revolut.com.evil.com/order/1'),
        isFalse,
      );
      expect(
        isExternallyOpenedOrigin('https://ramp.revolut.codes.evil.com/order/1'),
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
