## 1.1.6

### Added
- BybitPay (`https://i.bybit.com`), Kraken Pay (`https://krak.app`), Crypto.com Pay (`https://js.crypto.com`), and Cash App Pay (`https://cash.app`) added to the externally-opened origins list, enabling the hosted-QR deposit and pay flows to open the partner app or browser correctly.
- `bybit`, `cryptocom`, `krakenpay`, `cashapp` added to `allowedNativeSchemes` for custom-scheme deep link support.
- iOS platform setup section added to README documenting the `LSApplicationQueriesSchemes` entries required in client apps.

### Fixed
- `isExternallyOpenedOrigin` now compares scheme and host exactly (via URI parsing) instead of string-prefix matching, preventing lookalike-domain bypasses.

## 1.1.5

### Added
- `pay.coinbase.com` is now opened in the external browser, enabling the Coinbase Pay ramp fallback flow to complete passkey 2FA on devices where it is not supported inside the WebView.

## 1.1.4

### Fixed
- `window.accessTokens` is now injected as a stringified JSON string so the Link UI can call `JSON.parse()` on it, matching the expected contract.

## 1.1.3

- Expose `tokenId` field in `AccountToken` entity, required for Mesh’s Managed Token system (MMT).

## 1.1.2

- Enables opening Mesh OAuth redirect URLs in an external browser.

## 1.1.1

- Fixes a Flutter navigation bug caused by BuildContext shadowing in the close/exit dialog flow.

## 1.1.0

- Enabling system language, fiat currency display, and theme selection through MeshConfiguration.

## 1.0.0

- Added additional externally opened urls to open native apps.

## 0.0.3

- Added Spanish (es) and Portuguese (pt) localizations to the SDK.
- Added a fallback to English (en) if a supported locale was not found.

## 0.0.2

- Version release from CI

## 0.0.1

- Initial release
