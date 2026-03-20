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

    // Allow OAuth redirect URLs open externally
    if (_oAuthRedirectRegex.hasMatch(url)) {
      return true;
    }

    for (final origin in _externallyOpenedOrigins) {
      if (origin.startsWith('https://')) {
        // Full URL, e.g. "https://link.trustwallet.com"
        if (url.startsWith(origin)) {
          return true;
        }
      } else {
        logger.severe('Invalid externally opened origin format: $origin');
      }
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
  'https://ramp.revolut.codes',
  'https://sso.revolut.codes',
  'https://ramp.revolut.com',
];

const _externallyOpenedOrigins = [
  'https://link.trustwallet.com',   // Trust Wallet
  'https://wallet.uphold.com',      // Uphold
  'https://go.rabby.io/mobile',     // Rabby
  'https://app.binance.com',        // Binance Connect
  'https://web3.okx.com',           // Okx
  'https://metamask.app.link',      // MetaMask
  'https://phantom.app',            // Phantom
  'https://solflare.com',           // Solflare
  'https://coinbase.com',           // Coinbase
  'https://www.coinbase.com',       // Coinbase
  'https://login.coinbase.com',     // Coinbase
  'https://exodus.com/m/',          // Exodus
  'https://sandbox.meshconnect.com/authorize/Coinbase', // Coinbase on Sandbox
  'https://appopener.meshconnect.com',
  'https://api.cb-device-intelligence.com',
];
// dart format on

// Matches https://*.meshconnect.com/*/catalog/oauth/redirect/*
final _oAuthRedirectRegex = RegExp(
  r'^https://[^.]+\.meshconnect\.com/.+/catalog/oauth/redirect/.*$',
);

const _exodusSchema = 'exodus';
const _exodusPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=exodusmovement.exodus';
