import 'package:flutter/foundation.dart';
import 'package:mesh_sdk_flutter/src/util/constants.dart';

/// Returns true if [url] should be opened in an external app (e.g. wallet,
/// store) rather than in the WebView.
///
/// Checks in order: [allowedNativeSchemes], Android-specific `http`/`https`
/// hosts, iOS-specific rules, then returns false if none match.
bool isAppUrlChange(String url) {
  final uri = Uri.parse(url);
  final scheme = uri.scheme.toLowerCase();

  if (allowedNativeSchemes.contains(scheme)) {
    return true;
  }

  if (uri.scheme == 'http' || uri.scheme == 'https') {
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (uri.host == 'market' || uri.host == 'intent') {
        return true;
      }
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (uri.host == 'apps.apple.com') {
        return true;
      }
    }

    if (uri.host.endsWith('.app.link')) {
      return true;
    }
  }

  if (defaultTargetPlatform == TargetPlatform.iOS && scheme == 'itms-apps') {
    return true;
  }

  return false;
}
