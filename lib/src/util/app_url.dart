import 'package:flutter/foundation.dart';

/// Returns true if [url] should be opened in an external app (e.g. wallet,
/// store) rather than in the WebView.
bool isAppUrlChange(String url) {
  final uri = Uri.parse(url);

  // Custom URL schemes (e.g. wallet deep links: tronlinkoutside etc.)
  // should be opened in the external app, not in the webview.
  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return true;
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    if (uri.scheme == 'exodus' ||
        uri.host == 'market' ||
        uri.host == 'intent') {
      return true;
    }
  }

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    if (uri.host == 'apps.apple.com' || uri.scheme == 'itms-apps') {
      return true;
    }
  }

  return uri.host.endsWith('.app.link');
}
