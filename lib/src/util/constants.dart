import 'package:mesh_sdk_flutter/src/util/logger.dart';

bool isWhitelistedOrigin(String url) {
  try {
    if (url == 'about:blank') {
      return true;
    }

    return _whitelistedOrigins.any((origin) {
      if (origin.startsWith('*.')) {
        // Wildcard origin, e.g. "*.meshconnect.com"
        final root = origin.substring(2);
        final uri = Uri.parse(url);
        final host = uri.host;

        return host.endsWith(root) && host.length > root.length;
      }

      return url.startsWith(origin);
    });
  } catch (e) {
    return false;
  }
}

bool isExternallyOpenedOrigin(String url) {
  try {
    if (url == 'about:blank') {
      return false;
    }

    // Allow OAuth redirect URLs to open externally
    if (_oAuthRedirectRegex.hasMatch(url) ||
        _mfsOAuthRedirectRegex.hasMatch(url)) {
      return true;
    }

    final urlUri = Uri.tryParse(url);
    if (urlUri == null) {
      return false;
    }

    for (final origin in _externallyOpenedOrigins) {
      final originUri = Uri.tryParse(origin);
      if (originUri == null) {
        logger.severe('Invalid externally opened origin format: $origin');
        continue;
      }

      // Compare scheme and host exactly to prevent lookalike attacks
      // (e.g. https://i.bybit.com.evil.com matching https://i.bybit.com).
      if (urlUri.scheme != originUri.scheme || urlUri.host != originUri.host) {
        continue;
      }

      // If the origin specifies a path, the URL path must match it exactly or
      // be nested under it (segment boundary) to prevent path-prefix lookalikes
      // e.g. /authorize/CoinbaseEvil matching /authorize/Coinbase.
      final originPath = originUri.path;
      if (originPath.isNotEmpty && originPath != '/') {
        final urlPath = urlUri.path;
        final normalizedOriginPath = originPath.endsWith('/')
            ? originPath
            : '$originPath/';
        if (urlPath != originPath &&
            !urlPath.startsWith(normalizedOriginPath)) {
          continue;
        }
      }

      return true;
    }

    return false;
  } catch (e) {
    return false;
  }
}

Uri? getStoreUriFromAppUri(Uri uri) {
  if (uri.scheme == _exodusSchema) {
    return Uri.parse(_exodusPlayStoreUrl);
  }

  return null;
}

// dart format off
const _whitelistedOrigins = [
  '*.meshconnect.com',
  '*.meshpay.com', // MFS / Link v3
  '*.getfront.com',
  '*.walletconnect.com',
  '*.walletconnect.org',
  '*.walletlink.org',
  '*.okx.com',
  '*.gemini.com',
  '*.hcaptcha.com',
  '*.robinhood.com',
  '*.google.com',
  '*.local',        // LocalCan (for development purposes)
  '*.localcan.dev', // LocalCan Public URL (for development purposes)
  'https://meshconnect.com',
  'https://getfront.com',
  'https://walletconnect.com',
  'https://walletconnect.org',
  'https://walletlink.org',
  'https://okx.com',
  'https://gemini.com',
  'https://hcaptcha.com',
  'https://robinhood.com',
  'https://google.com',
  'https://front-web-platform-dev',
  'https://front-b2b-api-test.azurewebsites.net',
  'https://web.getfront.com',
  'https://web.meshconnect.com',
  'https://applink.robinhood.com',
  'https://m.stripe.network',
  'https://js.stripe.com',
  'https://app.usercentrics.eu',
];

const _externallyOpenedOrigins = [
  'https://link.trustwallet.com',   // Trust Wallet
  'https://wallet.uphold.com',      // Uphold
  'https://go.rabby.io/mobile',     // Rabby
  'https://app.binance.com',        // Binance Connect
  'https://web3.okx.com',           // Okx
  'https://metamask.app.link',      // MetaMask (WalletConnect)
  'https://link.metamask.io',       // MetaMask (in-wallet browser)
  'https://phantom.app',            // Phantom
  'https://solflare.com',           // Solflare
  'https://coinbase.com',           // Coinbase
  'https://www.coinbase.com',       // Coinbase
  'https://login.coinbase.com',     // Coinbase
  'https://pay.coinbase.com',       // Coinbase Pay (ramp fallback)
  'https://exodus.com/m/',          // Exodus
  'https://sandbox.meshconnect.com/authorize/Coinbase', // Coinbase on Sandbox
  'https://api.cb-device-intelligence.com',
  'https://i.bybit.com',           // Bybit Pay
  'https://krak.app',              // Kraken Pay
  'https://js.crypto.com',         // Crypto.com Pay
  'https://cash.app',              // Cash App Pay
  // Revolut Connect. Prod only: Revolut asked us not to carry their
  // dev/sandbox host in SDK source, so the handoff works against prod Revolut
  // but not against their sandbox.
  'https://ramp.revolut.com',
  // Block explorers. Link offers a "view transaction" link after a transfer and
  // the URL is backend-supplied per network, so this list cannot be complete
  // here: a network whose explorer is missing dead-taps. Sourcing it from the
  // backend network config is tracked separately.
  'https://basescan.org',
  'https://etherscan.io',
];
// dart format on

// Matches https://*.meshconnect.com/*/catalog/oauth/redirect/*
final _oAuthRedirectRegex = RegExp(
  r'^https://[^.]+\.meshconnect\.com/.+/catalog/oauth/redirect/.*$',
);

// The Link v3 equivalent: https://api*.meshpay.com/v2/sessions/<id>/child-sessions/<id>:redirect
// Must open externally like its v1/v2 counterpart. The host is whitelisted, so
// without this the redirect renders in the WebView, unloading Link and losing
// the in-flight OAuth session.
final _mfsOAuthRedirectRegex = RegExp(
  r'^https://api(?:\.[a-z0-9-]+)*\.meshpay\.com'
  '/v2/sessions/[^/]+/child-sessions/[^/?]+:redirect',
);

const _exodusSchema = 'exodus';
const _exodusPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=exodusmovement.exodus';

/// Native app URL schemes that may leave the WebView (wallet deep links).
/// Used by `isAppUrlChange` in app_url.dart.
/// Extend when Mesh adds wallet integrations.
const allowedNativeSchemes = {
  'tronlinkoutside',
  'bitcoin',
  'zengo',
  'okx',
  'uniswap',
  'rainbow',
  'bitkeep',
  'ledgerlive',
  'dfw',
  'exodus',
  'cbwallet',
  'bnc',
  'phantom',
  'trust',
  'metamask',
  'robinhood-wallet',
  // Hosted-QR deposit / pay flows
  'bybit',
  'cryptocom',
  'krakenpay',
  'cashapp',
};
