import 'package:flutter/foundation.dart';

/// Schemes that must never be handed to the OS from web content. `javascript`
/// and `data` execute in whatever context receives them, `file` and `content`
/// reach local storage, `intent` and `android-app` can address an arbitrary
/// component with arbitrary extras, and `about` / `blob` are inert but
/// meaningless to launch.
const _blockedSchemes = {
  'javascript',
  'data',
  'file',
  'content',
  'intent',
  'android-app',
  'about',
  'blob',
};

final _whitespacePattern = RegExp(r'\s');

/// Returns true if [url] should be opened in an external app (e.g. wallet,
/// store) rather than in the WebView.
///
/// Any non-`http(s)` scheme is treated as an app deep link unless it is
/// blocked. Admitting by exclusion is deliberate: the wallet catalog carries
/// around 180 distinct schemes and gains more without an SDK release, so an
/// enumerated allowlist silently drops every wallet it has not caught up with.
/// Mirrors the React Native SDK's `isAppLaunchScheme`.
///
/// `http`/`https` still need an explicit match, since that is the WebView's own
/// traffic: Android `market`/`intent` hosts, the iOS App Store, and `.app.link`
/// (Branch) universal links.
bool isAppUrlChange(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return false;
  }

  final scheme = uri.scheme.toLowerCase();
  if (scheme.isEmpty) {
    return false;
  }

  if (scheme != 'http' && scheme != 'https') {
    // The URL is launched exactly as given, so reject what is not launchable
    // as-is instead of handing it to the OS and failing there. A valid URL
    // percent-encodes whitespace, so this only rejects malformed input.
    return !_blockedSchemes.contains(scheme) &&
        !url.contains(_whitespacePattern);
  }

  if (defaultTargetPlatform == TargetPlatform.android &&
      (uri.host == 'market' || uri.host == 'intent')) {
    return true;
  }

  if (defaultTargetPlatform == TargetPlatform.iOS &&
      uri.host == 'apps.apple.com') {
    return true;
  }

  return uri.host.endsWith('.app.link');
}
