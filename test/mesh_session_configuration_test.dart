import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/mesh_sdk_flutter.dart';
import 'package:mesh_sdk_flutter/src/util/constants.dart';
import 'package:mesh_sdk_flutter/src/util/link_uri.dart';

/// `MeshConfiguration.session` is the entry point for clients that mint a
/// session directly and get a bare token back. It wraps that token into a link
/// token so the rest of the SDK keeps a single code path.
void main() {
  const token = 'ory_ac_abc123.def456';

  String urlFor(MeshConfiguration c) => utf8.decode(base64Decode(c.linkToken));

  group('session token is wrapped into a link token', () {
    test('production is the default environment', () {
      final config = MeshConfiguration.session(token: token);
      expect(urlFor(config), 'https://link.meshpay.com/?token=$token');
    });

    test('each environment resolves to its own host', () {
      expect(
        urlFor(
          MeshConfiguration.session(
            token: token,
            environment: MeshLinkEnvironment.sbx,
          ),
        ),
        'https://link.sbx.meshpay.com/?token=$token',
      );
      expect(
        urlFor(
          MeshConfiguration.session(
            token: token,
            environment: MeshLinkEnvironment.dev,
          ),
        ),
        'https://link.dev.meshpay.com/?token=$token',
      );
    });
  });

  group('the wrapped token behaves like any other link token', () {
    test('buildLinkUri resolves the host and keeps the session token', () {
      final uri = buildLinkUri(MeshConfiguration.session(token: token));
      expect(uri.host, 'link.meshpay.com');
      expect(uri.queryParameters['token'], token);
      expect(uri.queryParameters['platform'], 'flutter');
    });

    test('every environment host is allowlisted', () {
      for (final env in MeshLinkEnvironment.values) {
        expect(
          isWhitelistedOrigin(env.linkUrl),
          isTrue,
          reason: '${env.name} (${env.linkUrl}) must load in the WebView',
        );
      }
    });

    test('SDK options are forwarded, not dropped', () {
      final uri = buildLinkUri(
        MeshConfiguration.session(
          token: token,
          language: 'es',
          displayFiatCurrency: 'EUR',
          theme: ThemeMode.dark,
        ),
      );
      expect(uri.queryParameters['lng'], 'es');
      expect(uri.queryParameters['fiatCur'], 'EUR');
      expect(uri.queryParameters['th'], 'dark');
      expect(uri.queryParameters['token'], token);
    });

    test('callbacks and flags survive the wrapping', () {
      MeshErrorType? received;
      final config = MeshConfiguration.session(
        token: token,
        isDomainWhitelistEnabled: false,
        onError: (error) => received = error,
      );
      expect(config.isDomainWhitelistEnabled, isFalse);
      config.onError?.call(MeshErrorType.connectionError);
      expect(received, MeshErrorType.connectionError);
    });
  });
}
