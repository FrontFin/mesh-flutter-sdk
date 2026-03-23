import 'package:flutter/foundation.dart';
import 'package:mesh_sdk_flutter/src/util/constants.dart';

/// Returns true if [url] should be opened in an external app (e.g. wallet,
/// store) rather than in the WebView.
///
/// Custom schemes are allowed only if listed in [allowedCustomUrlSchemes].
bool isAppUrlChange(String url) {
  final uri = Uri.parse(url);

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

    return uri.host.endsWith('.app.link');
  }

  return allowedCustomUrlSchemes.contains(uri.scheme.toLowerCase());
}
