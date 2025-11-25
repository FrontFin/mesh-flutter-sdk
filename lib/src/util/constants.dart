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

      if (origin.startsWith('https://')) {
        // Full URL, e.g. "https://meshconnect.com"
        return url.startsWith(origin);
      }

      if (origin.endsWith('://')) {
        // Custom scheme, e.g. "robinhood://"
        return url.startsWith(origin);
      }

      logger.severe('Invalid origin format: $origin');
      return false;
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

    return _externallyOpenedOrigins.any((origin) {
      if (origin.startsWith('https://')) {
        // Full URL, e.g. "https://link.trustwallet.com"
        return url.startsWith(origin);
      }

      logger.severe('Invalid externally opened origin format: $origin');
      return false;
    });
  } catch (e) {
    return false;
  }
}

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
  'robinhood://',
  'https://ramp.revolut.codes',
  'https://sso.revolut.codes',
  'https://ramp.revolut.com',
];

const _externallyOpenedOrigins = [
  'https://link.trustwallet.com',
  'https://appopener.meshconnect.com',
  'https://coinbase.com',
  'https://www.coinbase.com',
  'https://login.coinbase.com',
  'https://api.cb-device-intelligence.com',
];
