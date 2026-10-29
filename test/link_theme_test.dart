import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/ui/theme.dart';
import 'package:mesh_sdk_flutter/src/util/theme.dart';

const _legacyUrl = 'https://web.meshconnect.com/b64?link_token=abc';

String _linkStyle(Map<String, Object?> json) =>
    base64Encode(utf8.encode(jsonEncode(json)));

String _envelope(String json) =>
    base64Url.encode(utf8.encode(json)).replaceAll('=', '');

String _latestLinkUrl([String? theme]) {
  final th = theme == null ? '' : ',"th":"$theme"';
  return 'https://link.meshpay.com/?token=${_envelope('{"v":1,"c":"code"$th}')}'
      '&clientId=org-1';
}

void main() {
  group('resolveLinkBrightness', () {
    test('follows the first th param', () {
      expect(
        resolveLinkBrightness('$_legacyUrl&th=dark&th=light', Brightness.light),
        Brightness.dark,
      );
      expect(
        resolveLinkBrightness('$_legacyUrl&th=light&th=dark', Brightness.dark),
        Brightness.light,
      );
    });

    test('prefers th over link_style and the token theme', () {
      final style = _linkStyle({'th': 'dark'});
      expect(
        resolveLinkBrightness(
          '$_legacyUrl&th=light&link_style=$style',
          Brightness.dark,
        ),
        Brightness.light,
      );
      expect(
        resolveLinkBrightness(
          '${_latestLinkUrl('LINK_THEME_DARK')}&th=light',
          Brightness.dark,
        ),
        Brightness.light,
      );
    });

    test('uses link_style when th is missing or not light or dark', () {
      expect(
        resolveLinkBrightness(
          '$_legacyUrl&link_style=${_linkStyle({'th': 'dark'})}',
          Brightness.light,
        ),
        Brightness.dark,
      );
      expect(
        resolveLinkBrightness(
          '$_legacyUrl&th=system&link_style=${_linkStyle({'th': 'light'})}',
          Brightness.dark,
        ),
        Brightness.light,
      );
    });

    test('follows the device for a link_style system theme', () {
      final url = '$_legacyUrl&link_style=${_linkStyle({'th': 'system'})}';
      expect(resolveLinkBrightness(url, Brightness.dark), Brightness.dark);
      expect(resolveLinkBrightness(url, Brightness.light), Brightness.light);
    });

    test('reads unpadded and URL-encoded link_style', () {
      final style = _linkStyle({'th': 'dark'}).replaceAll('=', '');
      expect(
        resolveLinkBrightness(
          '$_legacyUrl&link_style=${Uri.encodeQueryComponent(style)}',
          Brightness.light,
        ),
        Brightness.dark,
      );
    });

    test('defaults a legacy link without a theme to light', () {
      expect(
        resolveLinkBrightness(_legacyUrl, Brightness.dark),
        Brightness.light,
      );
      expect(
        resolveLinkBrightness(
          '$_legacyUrl&link_style=${_linkStyle({'other': 'value'})}',
          Brightness.dark,
        ),
        Brightness.light,
      );
    });

    test('defaults to light when link_style cannot be decoded', () {
      expect(
        resolveLinkBrightness('$_legacyUrl&link_style=%%%', Brightness.dark),
        Brightness.light,
      );
    });

    test('uses the latest Link token theme', () {
      expect(
        resolveLinkBrightness(
          _latestLinkUrl('LINK_THEME_DARK'),
          Brightness.light,
        ),
        Brightness.dark,
      );
      expect(
        resolveLinkBrightness(
          _latestLinkUrl('LINK_THEME_LIGHT'),
          Brightness.dark,
        ),
        Brightness.light,
      );
    });

    test('follows the device for a latest Link token without a theme', () {
      expect(
        resolveLinkBrightness(_latestLinkUrl(), Brightness.dark),
        Brightness.dark,
      );
      expect(
        resolveLinkBrightness(_latestLinkUrl(), Brightness.light),
        Brightness.light,
      );
    });
  });

  group('isLatestLinkUrl', () {
    test('accepts a valid token envelope', () {
      expect(isLatestLinkUrl(_latestLinkUrl()), isTrue);
    });

    test('rejects legacy and malformed tokens', () {
      expect(isLatestLinkUrl(_legacyUrl), isFalse);
      expect(
        isLatestLinkUrl('https://link.meshpay.com/?token=not-json'),
        isFalse,
      );
      expect(
        isLatestLinkUrl(
          'https://link.meshpay.com/?token=${_envelope('{"v":"1","c":"code"}')}',
        ),
        isFalse,
      );
      expect(
        isLatestLinkUrl(
          'https://link.meshpay.com/?token=${_envelope('{"v":1,"c":""}')}',
        ),
        isFalse,
      );
      expect(isLatestLinkUrl('https://link.meshpay.com/?token='), isFalse);
    });
  });

  group('getLinkBackgroundColor', () {
    test('uses the latest Link canvas colors', () {
      expect(
        getLinkBackgroundColor(Brightness.dark, isLatestLink: true),
        latestLinkColorDark,
      );
      expect(
        getLinkBackgroundColor(Brightness.light, isLatestLink: true),
        latestLinkColorLight,
      );
    });

    test('keeps the legacy colors', () {
      expect(
        getLinkBackgroundColor(Brightness.dark, isLatestLink: false),
        navBarColorDark,
      );
      expect(
        getLinkBackgroundColor(Brightness.light, isLatestLink: false),
        navBarColorLight,
      );
    });
  });
}
