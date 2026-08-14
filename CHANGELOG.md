## 1.1.9

### Fixed
- MetaMask, Base (Coinbase Wallet), Bitget Wallet, and Tonkeeper now open from the wallet selection screen. Their in-wallet browser deeplinks were blocked by the WebView instead of launching the app.
- Wallets that connect over WalletConnect now open too. Their deep links were matched against a hardcoded list of app schemes, so most of the catalog was silently blocked.

### Changed
- A wallet deep link is now recognised by its scheme rather than by a hardcoded list, so newly added wallets work without an SDK release. Schemes that can execute code or reach local storage stay blocked.

## 1.1.8

### Added
- Enriched existing SDK events with additional optional fields from the Link event contract.
- Send `platform=flutter` query parameter to the Link UI.

### Fixed
- Events with sparse payloads are no longer dropped.

## 1.1.7

### Removed
- Removed the hardcoded Revolut origins (`https://ramp.revolut.codes`, `https://sso.revolut.codes`, `https://ramp.revolut.com`) from the whitelisted origins list.

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
