import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/model/integration/integration_connected_payload.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_event.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_internal_event.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_result.dart';
import 'package:mesh_sdk_flutter/src/model/success/success.dart';
import 'package:mesh_sdk_flutter/src/model/transfer/transfer_finished_payload.dart';
import 'package:mesh_sdk_flutter/src/util/constants.dart';
import 'package:mesh_sdk_flutter/src/util/link_uri.dart';

/// Cross-SDK MFS parity suite.
///
/// The same numbered cases (P1.x, P2.x, ...) exist in every mobile SDK, so
/// "parity" is something that can be pointed at rather than asserted. Keep the
/// case ids and the fixtures below identical across repos; when one SDK's
/// behaviour has to differ, keep the case and document why in its body rather
/// than deleting it.
///
/// The contract being pinned:
///   P1  a link token is base64 of a URL, so the token alone decides which Link
///       loads. v1, v2 and MFS all arrive through this one path.
///   P2  the origin allowlist must accept both meshconnect and meshpay, and
///       must still reject lookalikes.
///   P3  Link v3 emits only four legacy events, one of which (`close`) carries
///       no payload at all.
///   P4  the v1/v2 payload shapes must keep working throughout the migration.

// ---------------------------------------------------------------------------
// Shared fixtures. Keep byte-identical across SDKs.
// ---------------------------------------------------------------------------

String tokenFor(String url) => base64Encode(utf8.encode(url));

const v1Url = 'https://web.meshconnect.com/broker-connect/catalog';
const v2Url = 'https://link.meshconnect.com/?clientId=abc&auth_code=xyz';
const mfsUrl = 'https://link.meshpay.com/?token=ory_ac_abc123';

/// Link v3 `brokerageAccountAccessToken`. The connection-id architecture keeps
/// real tokens server-side, so accessToken/accountId/tokenId all carry the
/// connectionId and there is no refreshToken or expiresInSeconds.
const v3BrokerTokens = {
  'type': 'brokerageAccountAccessToken',
  'payload': {
    'accountTokens': [
      {
        'account': {'accountId': 'conn_123', 'accountName': 'Coinbase'},
        'accessToken': 'conn_123',
        'tokenId': 'conn_123',
      },
    ],
    'brokerBrandInfo': {
      'logoLightUrl': 'https://cdn/l.png',
      'logoDarkUrl': 'https://cdn/d.png',
    },
    'brokerType': 'coinbase',
    'brokerName': 'Coinbase',
  },
};

/// Link v1/v2 `brokerageAccountAccessToken`: a real access token and the older
/// brand shape (brokerLogo / brokerPrimaryColor).
const legacyBrokerTokens = {
  'type': 'brokerageAccountAccessToken',
  'payload': {
    'accountTokens': [
      {
        'account': {'accountId': 'acc_1', 'accountName': 'Coinbase'},
        'accessToken': 'real-access-token',
        'refreshToken': 'real-refresh-token',
        'tokenId': 'tok_1',
      },
    ],
    'brokerBrandInfo': {
      'brokerLogo': 'https://cdn/logo.png',
      'brokerPrimaryColor': '#0052FF',
    },
    'expiresInSeconds': 3600,
    'brokerType': 'coinbase',
    'brokerName': 'Coinbase',
  },
};

/// Link v3 `transferFinished`: success-only and v1-shaped. Note the absence of
/// previewId / fiatCurrency / amountInUSD / smartFunding, which v2 sends.
const v3TransferFinished = {
  'type': 'transferFinished',
  'payload': {
    'status': 'success',
    'txId': 'tx_1',
    'transferId': 'tx_1',
    'fromAddress': '0xfrom',
    'toAddress': '0xto',
    'symbol': 'USDC',
    'amount': 10.5,
    'networkId': 'base',
    'networkName': 'base',
  },
};

/// Link v2 `transferFinished`, error branch. v3 has no error variant at all.
const legacyTransferFinishedError = {
  'type': 'transferFinished',
  'payload': {'status': 'error', 'errorMessage': 'insufficient funds'},
};

void main() {
  group('P1 token resolution: the token decides which Link loads', () {
    Uri uriFor(String url) =>
        buildLinkUri(MeshConfiguration(linkToken: tokenFor(url)));

    test('P1.1 a v1 token resolves to the v1 host', () {
      expect(uriFor(v1Url).host, 'web.meshconnect.com');
    });

    test('P1.2 a v2 token resolves to the v2 host', () {
      expect(uriFor(v2Url).host, 'link.meshconnect.com');
    });

    test(
      'P1.3 an MFS token resolves to the MFS host, session token intact',
      () {
        final uri = uriFor(mfsUrl);
        expect(uri.host, 'link.meshpay.com');
        expect(uri.queryParameters['token'], 'ory_ac_abc123');
      },
    );

    test('P1.4 SDK params are appended without dropping token params', () {
      final uri = buildLinkUri(
        MeshConfiguration(
          linkToken: tokenFor(v2Url),
          language: 'es',
          displayFiatCurrency: 'EUR',
        ),
      );
      expect(uri.queryParameters['platform'], 'flutter');
      expect(uri.queryParameters['lng'], 'es');
      expect(uri.queryParameters['fiatCur'], 'EUR');
      // The token's own params survive.
      expect(uri.queryParameters['clientId'], 'abc');
      expect(uri.queryParameters['auth_code'], 'xyz');
    });

    test('P1.5 a malformed token does not yield a loadable URL', () {
      // Flutter surfaces this as a thrown/!hasScheme URI which the controller
      // turns into MeshErrorType.connectionError. Pinned to the exact type:
      // `anyOf(throwsA, returnsNormally)` asserts nothing.
      expect(
        () => buildLinkUri(const MeshConfiguration(linkToken: 'not-base64!!')),
        throwsFormatException,
      );
      final uri = buildLinkUri(
        MeshConfiguration(linkToken: tokenFor('not a url')),
      );
      expect(uri.hasScheme, isFalse);
    });
  });

  group('P2 origin allowlist accepts both platforms', () {
    test('P2.1 meshconnect hosts are allowed', () {
      expect(isWhitelistedOrigin('https://link.meshconnect.com'), isTrue);
      expect(isWhitelistedOrigin('https://web.meshconnect.com'), isTrue);
    });

    test('P2.2 meshpay (MFS) hosts are allowed', () {
      expect(isWhitelistedOrigin('https://link.meshpay.com'), isTrue);
      expect(isWhitelistedOrigin('https://link.dev.meshpay.com'), isTrue);
      expect(isWhitelistedOrigin('https://api.meshpay.com'), isTrue);
    });

    test('P2.3 meshpay suffix lookalikes are rejected', () {
      // Holds because meshpay is a wildcard-only entry, so the explicit-prefix
      // bypass in P2.5 does not reach it. The wildcard bypass still does.
      expect(isWhitelistedOrigin('https://meshpay.com.evil.com'), isFalse);
    });

    test('P2.4 unrelated hosts are rejected', () {
      expect(isWhitelistedOrigin('https://example.com'), isFalse);
    });

    // KNOWN GAP, pre-existing and unrelated to MFS. Documented rather than
    // asserted as desired behaviour, so the eventual fix shows up here as a
    // test change. Two independent bypasses:
    //
    //   1. the wildcard branch matches on a bare suffix with no dot boundary,
    //      so `evilmeshconnect.com` satisfies `*.meshconnect.com`;
    //   2. the explicit branch uses `url.startsWith(origin)` with no boundary,
    //      so `https://meshconnect.com.evil.com` satisfies the literal entry
    //      `https://meshconnect.com`.
    //
    // Both let an attacker-registered host load inside the WebView. Fix belongs
    // in its own PR off main, not on an MFS branch.
    test('P2.5 allowlist boundary gaps (known, tracked separately)', () {
      // (1) no dot boundary on wildcards
      expect(isWhitelistedOrigin('https://evilmeshconnect.com'), isTrue);
      // Adding *.meshpay.com to this matcher WIDENS the existing gap to a new
      // domain, which is the argument for fixing the boundary alongside the
      // MFS change rather than after it.
      expect(isWhitelistedOrigin('https://evilmeshpay.com'), isTrue);
      // (2) no boundary on explicit prefixes
      expect(isWhitelistedOrigin('https://meshconnect.com.evil.com'), isTrue);
      expect(isWhitelistedOrigin('https://google.com.evil.com'), isTrue);
      expect(isWhitelistedOrigin('https://robinhood.com.evil.com'), isTrue);
    });
  });

  group('P3 Link v3 emits only four legacy events', () {
    test('P3.1 loaded is recognised', () {
      expect(MeshEvent.fromJson({'type': 'loaded'}), isA<LoadedEvent>());
    });

    test('P3.2 close arrives with NO payload and must still close', () {
      // v1/v2 always attach an event summary; v3 sends `{type: 'close'}` alone.
      // The native nav bar is hidden while on the Link host, so if this is not
      // handled the user has no visible way out of the WebView.
      final result = MeshResult.fromJson({'type': 'close'});
      expect(result, isA<MeshSuccess>());
      expect((result! as MeshSuccess).payload, isA<BaseSuccessPayload>());
    });

    test('P3.3 brokerageAccountAccessToken carries the connectionId', () {
      final event = MeshInternalEvent.fromJson(v3BrokerTokens);
      expect(event, isA<IntegrationConnected>());
      final payload =
          (event! as IntegrationConnected).payload as AccessTokenPayload;
      // The contract change: this is a connection handle, not a token.
      expect(payload.accountTokens.single.accessToken, 'conn_123');
      expect(payload.accountTokens.single.refreshToken, isNull);
      expect(payload.expiresInSeconds, isNull);
      // v3's brand shape uses logo*Url rather than brokerLogo.
      expect(payload.brokerBrandInfo.logoLightUrl, isNotNull);
      expect(payload.brokerBrandInfo.brokerLogo, isNull);
    });

    test('P3.4 transferFinished parses the v3 success-only shape', () {
      final event = MeshInternalEvent.fromJson(v3TransferFinished);
      expect(event, isA<TransferFinished>());
      final payload = (event! as TransferFinished).payload;
      expect(payload, isA<TransferFinishedSuccessPayload>());
      expect((payload as TransferFinishedSuccessPayload).txId, 'tx_1');
    });
  });

  group('P4 v1/v2 payloads keep working during the migration', () {
    test('P4.1 close with a payload still reports its page', () {
      final result = MeshResult.fromJson({
        'type': 'close',
        'payload': {'page': 'catalog'},
      });
      expect((result! as MeshSuccess).payload.page, 'catalog');
    });

    test('P4.2 legacy brokerageAccountAccessToken still parses', () {
      final event = MeshInternalEvent.fromJson(legacyBrokerTokens);
      final payload =
          (event! as IntegrationConnected).payload as AccessTokenPayload;
      expect(payload.accountTokens.single.accessToken, 'real-access-token');
      expect(payload.accountTokens.single.refreshToken, 'real-refresh-token');
      expect(payload.expiresInSeconds, 3600);
      expect(payload.brokerBrandInfo.brokerLogo, isNotNull);
    });

    test('P4.3 the v2 transferFinished error branch still parses', () {
      // v3 has no error variant, so this asserts the v2 path is untouched.
      final event = MeshInternalEvent.fromJson(legacyTransferFinishedError);
      final payload = (event! as TransferFinished).payload;
      expect(payload, isA<TransferFinishedErrorPayload>());
      expect(
        (payload as TransferFinishedErrorPayload).errorMessage,
        'insufficient funds',
      );
    });
  });
}
