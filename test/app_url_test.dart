import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/app_url.dart';

void main() {
  group('isAppUrlChange', () {
    group('custom URL schemes (wallet deep links)', () {
      test('returns true for tronlinkoutside scheme', () {
        expect(isAppUrlChange('tronlinkoutside://some/path'), isTrue);
      });

      test('returns true for metamask scheme', () {
        expect(isAppUrlChange('metamask://wc'), isTrue);
      });

      test('returns true for arbitrary custom scheme', () {
        expect(isAppUrlChange('myapp://open'), isTrue);
      });

      test('returns true for exodus scheme', () {
        expect(isAppUrlChange('exodus://some/path'), isTrue);
      });
    });

    group('http and https', () {
      test('returns false for plain https URL', () {
        expect(isAppUrlChange('https://example.com'), isFalse);
      });

      test('returns false for plain http URL', () {
        expect(isAppUrlChange('http://example.com/path'), isFalse);
      });

      test('returns true for host ending with .app.link', () {
        expect(isAppUrlChange('https://foo.app.link'), isTrue);
        expect(isAppUrlChange('https://sub.branch.app.link/path'), isTrue);
      });

      test('returns false for host that only contains .app.link', () {
        expect(isAppUrlChange('https://app.link.example.com'), isFalse);
      });
    });

    group('Android-specific', () {
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

      test('returns true for exodus scheme', () {
        expect(isAppUrlChange('https://exodus.com'), isFalse);
        expect(isAppUrlChange('exodus://open'), isTrue);
      });
    });

    group('iOS-specific', () {
      setUp(() {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      });

      tearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });

      test('returns true for apps.apple.com host', () {
        expect(isAppUrlChange('https://apps.apple.com/app/id123'), isTrue);
      });

      test('returns true for itms-apps scheme', () {
        expect(isAppUrlChange('itms-apps://apps.apple.com/app/id123'), isTrue);
      });

      test('returns false for regular https', () {
        expect(isAppUrlChange('https://example.com'), isFalse);
      });
    });
  });
}
