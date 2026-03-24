import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/app_url.dart';
import 'package:mesh_sdk_flutter/src/util/constants.dart';

void main() {
  group('isAppUrlChange', () {
    group('1. allowedNativeSchemes (cross-platform wallet schemes)', () {
      test('returns true for every scheme in allowedNativeSchemes', () {
        for (final scheme in allowedNativeSchemes) {
          expect(
            isAppUrlChange('$scheme://x'),
            isTrue,
            reason: 'scheme: $scheme',
          );
        }
      });

      test('itms-apps is not in allowedNativeSchemes (iOS-only, see iOS group)',
          () {
        expect(allowedNativeSchemes.contains('itms-apps'), isFalse);
      });

      test('matches schemes case-insensitively', () {
        expect(isAppUrlChange('MetaMask://wc'), isTrue);
        expect(isAppUrlChange('TRONLINKOUTSIDE://path'), isTrue);
      });

      test('returns false for unknown custom scheme', () {
        expect(isAppUrlChange('myapp://open'), isFalse);
      });
    });

    group('internal WebView schemes', () {
      test('returns false for about:blank', () {
        expect(isAppUrlChange('about:blank'), isFalse);
      });

      test('returns false for about:blank with fragment', () {
        expect(isAppUrlChange('about:blank#'), isFalse);
        expect(isAppUrlChange('about:blank#anchor'), isFalse);
      });

      test('returns false for data: URL', () {
        expect(isAppUrlChange('data:text/html,<p>hi</p>'), isFalse);
      });

      test('returns false for blob: URL', () {
        expect(isAppUrlChange('blob:https://example.com/uuid'), isFalse);
      });
    });

    group('2. Android: http/https market and intent hosts', () {
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

      test('returns true for exodus custom scheme via allowedNativeSchemes', () {
        expect(isAppUrlChange('exodus://open'), isTrue);
      });

      test('returns false for https://exodus.com (not market/intent)', () {
        expect(isAppUrlChange('https://exodus.com'), isFalse);
      });
    });

    group('3. http/https: iOS App Store host, then .app.link (any platform)', () {
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

      test('returns false for host that only contains .app.link substring', () {
        expect(isAppUrlChange('https://app.link.example.com'), isFalse);
      });

      test('returns false for plain https URL', () {
        expect(isAppUrlChange('https://example.com'), isFalse);
      });

      test('returns false for plain http URL', () {
        expect(isAppUrlChange('http://example.com/path'), isFalse);
      });
    });

    group('4. iOS-only: itms-apps scheme (not in allowedNativeSchemes)', () {
      test('returns true for itms-apps on iOS', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() {
          debugDefaultTargetPlatformOverride = null;
        });
        expect(isAppUrlChange('itms-apps://apps.apple.com/app/id123'), isTrue);
      });

      test('returns false for itms-apps on Android', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        addTearDown(() {
          debugDefaultTargetPlatformOverride = null;
        });
        expect(isAppUrlChange('itms-apps://apps.apple.com/app/id123'), isFalse);
      });

      test('returns false for itms-apps on macOS', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        addTearDown(() {
          debugDefaultTargetPlatformOverride = null;
        });
        expect(isAppUrlChange('itms-apps://apps.apple.com/app/id123'), isFalse);
      });

      test('matches itms-apps case-insensitively on iOS', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() {
          debugDefaultTargetPlatformOverride = null;
        });
        expect(isAppUrlChange('ITMS-Apps://apps.apple.com/x'), isTrue);
      });
    });

    group('wallet deep links (examples)', () {
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
  });
}
