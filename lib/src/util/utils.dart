import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Returns true if [url] should be opened in an external app (e.g. wallet,
/// store) rather than in the WebView.
bool isAppUrlChange(String url) {
  final uri = Uri.parse(url);
  if (defaultTargetPlatform == TargetPlatform.android) {
    if (url.startsWith('https://solflare.com/ul/v1/browse/') ||
        url.startsWith('https://phantom.com/ul/browse/') ||
        uri.scheme == 'exodus' ||
        uri.host == 'market' ||
        uri.host == 'intent') {
      return true;
    }
  }

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    if (uri.host == 'apps.apple.com' || uri.host == 'itms-appss') {
      return true;
    }
  }

  return uri.host.endsWith('.app.link');
}

String resolveLanguage(String language) {
  if (language == 'system') {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    return locale.languageCode;
  }
  return language;
}

String themeToQueryParam(ThemeMode theme) {
  return switch (theme) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}
