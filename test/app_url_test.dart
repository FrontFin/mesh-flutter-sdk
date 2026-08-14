import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/app_url.dart';

void main() {
  group('isAppUrlChange', () {
    group('1. non-http schemes are admitted unless blocked', () {
      // Real schemes from the wallet catalog. None of these were reachable
      // under the old enumerated allowlist.
      const walletSchemes = [
        'backpack',
        'xportal',
        'safepal',
        'zerion',
        'onekey',
        'bitpay',
        'shapeshift',
        'coin98',
        'imtokenv2',
        'robinhood-wallet',
        'crypto.noone.wallet',
        'com.mpcvault.mobileapp',
      ];

      test('returns true for wallet schemes from the catalog', () {
        for (final scheme in walletSchemes) {
          expect(
            isAppUrlChange('$scheme://wc?uri=wc%3Aabc'),
            isTrue,
            reason: 'scheme: $scheme',
          );
        }
      });

      test('returns true for a raw wc: pairing URI', () {
        expect(isAppUrlChange('wc:abc123@2?relay-protocol=irn'), isTrue);
      });

      test('matches case-insensitively', () {
        expect(isAppUrlChange('MetaMask://wc'), isTrue);
        expect(isAppUrlChange('TRONLINKOUTSIDE://path'), isTrue);
      });

      test('returns true for a scheme the SDK has never heard of', () {
        expect(isAppUrlChange('myapp://open'), isTrue);
      });

      test('returns false for a relative URL with no scheme', () {
        expect(isAppUrlChange('/catalog'), isFalse);
        expect(isAppUrlChange('wallet/123'), isFalse);
      });
    });

    group('2. blocked schemes are never launched', () {
      const blocked = [
        'javascript:alert(1)',
        'data:text/html,<script>alert(1)</script>',
        'file:///etc/passwd',
        'content://com.android.provider/x',
        'intent://scan/#Intent;scheme=zxing;end',
        'android-app://com.evil.app',
        'about:blank',
        'blob:https://link.meshconnect.com/abc',
      ];

      test('returns false for every blocked scheme', () {
        for (final url in blocked) {
          expect(isAppUrlChange(url), isFalse, reason: url);
        }
      });

      test('blocks regardless of case', () {
        expect(isAppUrlChange('JavaScript:alert(1)'), isFalse);
        expect(isAppUrlChange('DATA:text/html,x'), isFalse);
      });

      test('returns false for a scheme carrying whitespace', () {
        expect(isAppUrlChange('myapp://open path'), isFalse);
        expect(isAppUrlChange('myapp://open\npath'), isFalse);
      });
    });

    group('3. Android: http/https market and intent hosts', () {
      setUp(() {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
      });

      tearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });

      test('returns true for https with market host', () {
        expect(isAppUrlChange('https://market/details?id=foo'), isTrue);
      });

      test('returns true for https with intent host', () {
        expect(isAppUrlChange('https://intent/something'), isTrue);
      });

      test('returns true for the exodus custom scheme', () {
        expect(isAppUrlChange('exodus://open'), isTrue);
      });

      test('returns false for https://exodus.com (not market/intent)', () {
        expect(isAppUrlChange('https://exodus.com'), isFalse);
      });
    });

    group(
      '4. http/https: iOS App Store host, then .app.link (any platform)',
      () {
        test('returns true for https://apps.apple.com on iOS', () {
          debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
          addTearDown(() {
            debugDefaultTargetPlatformOverride = null;
          });
          expect(isAppUrlChange('https://apps.apple.com/app/id123'), isTrue);
        });

        test('returns false for https://apps.apple.com on Android', () {
          debugDefaultTargetPlatformOverride = TargetPlatform.android;
          addTearDown(() {
            debugDefaultTargetPlatformOverride = null;
          });
          expect(isAppUrlChange('https://apps.apple.com/app/id123'), isFalse);
        });

        test('returns true for host ending with .app.link', () {
          expect(isAppUrlChange('https://foo.app.link'), isTrue);
          expect(isAppUrlChange('https://sub.branch.app.link/path'), isTrue);
        });

        test(
          'returns false for host that only contains .app.link substring',
          () {
            expect(isAppUrlChange('https://app.link.example.com'), isFalse);
          },
        );

        test('returns false for plain https URL', () {
          expect(isAppUrlChange('https://example.com'), isFalse);
        });

        test('returns false for plain http URL', () {
          expect(isAppUrlChange('http://example.com/path'), isFalse);
        });

        test('returns false for the Link host itself', () {
          expect(
            isAppUrlChange('https://link.meshconnect.com/catalog'),
            isFalse,
          );
        });
      },
    );

    group('5. itms-apps is a normal non-http scheme on every platform', () {
      // Previously iOS-only. It is now admitted by the general rule; on a
      // platform with no handler the launch fails and the caller falls back.
      for (final platform in [
        TargetPlatform.iOS,
        TargetPlatform.android,
        TargetPlatform.macOS,
      ]) {
        test('returns true on $platform', () {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() {
            debugDefaultTargetPlatformOverride = null;
          });
          expect(
            isAppUrlChange('itms-apps://apps.apple.com/app/id123'),
            isTrue,
          );
        });
      }

      test('matches itms-apps case-insensitively', () {
        expect(isAppUrlChange('ITMS-Apps://apps.apple.com/x'), isTrue);
      });
    });

    group('6. wallet deep links (examples)', () {
      test('tronlinkoutside', () {
        expect(isAppUrlChange('tronlinkoutside://some/path'), isTrue);
      });

      test('metamask', () {
        expect(isAppUrlChange('metamask://wc'), isTrue);
      });

      test('exodus', () {
        expect(isAppUrlChange('exodus://some/path'), isTrue);
      });
    });

    group('7. hosted-QR deposit / pay deep links', () {
      test('bybit', () => expect(isAppUrlChange('bybit://pay'), isTrue));
      test(
        'cryptocom',
        () => expect(isAppUrlChange('cryptocom://pay'), isTrue),
      );
      test(
        'krakenpay',
        () => expect(isAppUrlChange('krakenpay://pay'), isTrue),
      );
      test('cashapp', () => expect(isAppUrlChange('cashapp://pay'), isTrue));
    });
  });
}
