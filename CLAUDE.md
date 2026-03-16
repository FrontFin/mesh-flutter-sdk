# Mesh Flutter SDK — Claude Development Notes

## What this repo is

The `mesh-flutter-sdk` is a Flutter package that Mesh's enterprise clients integrate into their mobile apps to offer crypto deposit, payment, and account-connection flows to their end users. Clients like **Kalshi, PayPal, Shift4, Stake.com, Uphold, and Kraken** ship this SDK in their own Flutter apps — their users never know they're interacting with Mesh.

The SDK works by loading the **Mesh Link web UI** (a React app hosted at `link.meshconnect.com`, built in the `mesh-link` repo) inside a `webview_flutter` WebView and bridging events back to the host app via Dart callbacks. The Flutter SDK's job is to host that web UI faithfully, handle native concerns (deep-linking to wallet apps, theming, localization), and expose a clean Dart API.

**This SDK is in the critical path of real financial transactions.** When a user on Kalshi taps "Add Funds", this code runs. If it crashes, hangs, or delivers a broken UX, that user doesn't fund their account — Kalshi loses the transaction, and Mesh loses client trust. Treat every change accordingly.

---

## How clients integrate

1. Client backend calls the Mesh API (`POST /api/v1/linktoken`) to generate a short-lived link token scoped to the user and product mode (deposit, pay, verify).
2. Client app receives the token and calls `MeshSdk.show()`, passing the token and callback handlers.
3. The SDK presents the Mesh Link UI. The user connects their broker/wallet and completes the flow.
4. The SDK fires `onIntegrationConnected`, `onTransferFinished`, or `onError` back to the client app.
5. The client app updates its own UI (e.g. shows a "Deposit successful" screen).

The client never touches the link token's internals — it's opaque to them. All product configuration (destination address, network, asset, amount limits) is encoded server-side when the token is issued.

---

## How to run locally

```bash
# Install dependencies
flutter pub get

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Static analysis
flutter analyze

# Format check
dart format --set-exit-if-changed .

# Run the example app
cd example && flutter run
```

---

## Tech stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter / Dart |
| WebView | webview_flutter ^4.13.0 |
| External app launching | url_launcher ^6.3.2 |
| Localization | flutter_localizations + intl |
| Version reporting | package_info_plus |
| Logging | logging ^1.3.0 |
| Lint | flutter_lints |

---

## Project structure

```
lib/
  mesh_sdk_flutter.dart        # Public API — only export from here
  src/
    mesh_sdk_flutter.dart      # MeshSdk.show() entry point
    model/
      mesh_configuration.dart  # All customizable parameters (linkToken, callbacks, language, theme)
      mesh_result.dart         # Sealed success/error union
      mesh_event.dart          # 30+ typed event classes (funnel analytics)
      success/                 # SuccessPayload sealed types
      integration/             # IntegrationAccessToken (cached broker auth)
      transfer/                # Transfer-related models
    ui/
      page/
        mesh_link_page.dart    # StatefulWidget — main WebView page
      widget/
        mesh_link_controller.dart  # WebViewController wrapper + JS bridge
        mesh_link_nav_bar.dart     # Native nav bar (adapts to theme)
      dialog/
        exit_confirmation_dialog.dart
    util/
      link_uri.dart            # Decodes base64 linkToken → full URL, merges query params
      constants.dart           # Domain whitelist + externally-opened origins
      language.dart            # Resolves 'system' locale to device language
      logger.dart              # Logging setup
    l10n/                      # Generated localization delegates
    extension/                 # Dart extension methods
test/                          # Unit tests (18 files)
example/                       # Example Flutter app demonstrating integration
```

---

## SDK contract — do not break

The SDK communicates with the Mesh Link web UI via a JavaScript bridge (`JSBridge` channel). **All client apps — Kalshi, PayPal, etc. — are wired against these exact callback signatures and payload field names.** Renaming or removing anything here is a breaking change that silently breaks production apps in the field.

```dart
MeshSdk.show(
  context,
  MeshConfiguration(
    linkToken: token,           // from client's backend
    onIntegrationConnected: (payload) { ... },  // broker connected
    onTransferFinished: (payload) { ... },       // transfer done
    onSuccess: (payload) { ... },               // generic success
    onError: (error) { ... },                   // connectionError | userCancelled | unknown
    onEvent: (event) { ... },                   // 30+ funnel events for client analytics
  ),
);
```

On the `LoadedEvent`, the SDK runs JavaScript to inject context into the page:
- `window.meshSdkPlatform = 'flutter'` — tells the web UI which SDK is hosting it
- `window.meshSdkVersion = '<x.y.z>'` — enables backend compatibility checks
- `window.accessTokens = [...]` — JSON array of cached broker tokens for returning users (skips re-auth); only set when `integrationAccessTokens` is non-empty

---

## Relationship with mesh-link (the web UI)

The Mesh Link web UI (`mesh-link` repo) is a separate React app. The Flutter SDK loads it in a WebView. When the web UI ships a new feature or event type, this SDK may need to be updated to handle it — and vice versa. Keep that dependency in mind when making changes to the JS bridge or event parsing.

The Android SDK (`mesh-android-sdk`) does the same thing in Kotlin. The two SDKs should behave identically from a client's perspective. If you're adding a feature to Flutter, check whether Android needs the same change.

---

## Domain whitelist / navigation

`MeshLinkController` validates all navigation. This is a security boundary — it prevents the WebView from being navigated to malicious domains if the web UI is ever compromised.

- **Whitelisted** (render in WebView): `*.meshconnect.com`, `*.getfront.com`, `*.walletconnect.com`, `*.walletconnect.org`, `*.walletlink.org`, `*.okx.com`, `*.gemini.com`, `*.hcaptcha.com`, `*.robinhood.com`, `*.google.com`, plus explicit URLs for Stripe, Usercentrics, and Revolut. See `lib/src/util/constants.dart` for the authoritative list.
- **Externally opened** (via `url_launcher` → native app): Trust Wallet, Uphold, Rabby, Binance, OKX, MetaMask, Phantom, Solflare, Coinbase, Exodus. See `_externallyOpenedOrigins` in `constants.dart`.
- **Everything else**: blocked

Clients can disable the whitelist via `MeshConfiguration` for custom flows, but this is not recommended.

---

## Localization

- 3 locales: `en`, `es`, `pt`
- `language: 'system'` resolves to device locale at runtime
- Generated via `flutter gen-l10n` from ARB files in `lib/src/l10n/`
- After editing ARB files, run: `flutter gen-l10n`

---

## Theming

- `ThemeMode.light`, `.dark`, `.system` — passed to Link UI as `th` query param
- System theme resolves to device brightness at render time
- Native nav bar adapts brightness to match

---

## Publishing

- Published to **pub.dev** as `mesh_sdk_flutter`
- Version is in `pubspec.yaml` — bump before releasing
- CI publishes automatically on `v*.*.*` tags via `.github/workflows/publish.yml`

---

## Guardrails

- Never commit credentials or link tokens
- PR target is `main`
- No `dynamic` in Dart — use sealed classes, generics, or `Object?` + narrowing
- No hardcoded UI strings — use `MeshLocalizations`
- No `print()` — use the `logging` package
- No floating-point arithmetic on financial values — pass through exactly as received from the API
- Backwards-compatible changes only on public API surface and JS bridge payloads
