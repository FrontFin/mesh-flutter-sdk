import 'dart:convert';
import 'dart:ui';

// The color around Link when the page has no valid color of its own, per Link
// version. Each pair matches the page background of that version.
const _sessionColors = (dark: Color(0xFF1C1C1C), light: Color(0xFFF9F9F9));
const _legacyColors = (dark: Color(0xFF0E0D0D), light: Color(0xFFFBFBFB));

// Same shape Link accepts for a page color: #RGB, #RGBA, #RRGGBB or #RRGGBBAA.
final _hexColor = RegExp(
  r'^#(?:[0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$',
);

typedef _Json = Map<String, Object?>;

typedef LinkAppearance = ({
  bool isDarkTheme,
  Color backgroundColor,

  /// Set for a legacy link whose theme comes from the device; see
  /// [resolveLinkAppearance].
  Brightness? themeToWrite,
});

enum _Choice { light, dark, device }

/// The theme Link opens in and the color around it, read from the URL the way
/// the page reads it, so the status bar, bottom area and background match with
/// no visible seam.
///
/// Theme, first one set wins:
/// 1. `th=light` or `th=dark` in the URL (the app's choice, or the token's)
/// 2. the theme in the session token, for a link that has one
/// 3. `th=system` in the URL means the device on any link
/// 4. `link_style.th` (legacy links only), `system` meaning the device
/// 5. the device for a link with a session token, otherwise dark (like link-v2)
///
/// Color: the page's own `bgd` (dark) or `bgl` (light) from the session token
/// or `link_style`, otherwise the fallback pair of that Link version.
///
/// `themeToWrite` is set for a legacy link whose theme comes from the device.
/// The WebView can read the device differently from the app, so the caller
/// writes this resolved theme into the URL and Link follows the same reading
/// as the bars.
LinkAppearance resolveLinkAppearance({
  required String? urlTheme,
  required String? token,
  required String? linkStyle,
  required Brightness platformBrightness,
}) {
  final sessionToken = _readSessionToken(token);
  final style = sessionToken == null ? _decodeJsonParam(linkStyle) : null;

  final choice =
      _fixed(urlTheme) ??
      switch (sessionToken?['th']) {
        'LINK_THEME_LIGHT' => _Choice.light,
        'LINK_THEME_DARK' => _Choice.dark,
        _ => null,
      } ??
      (urlTheme == 'system' ? _Choice.device : null) ??
      _fixed(style?['th']) ??
      (style?['th'] == 'system' ? _Choice.device : null) ??
      (sessionToken != null ? _Choice.device : _Choice.dark);
  final theme = switch (choice) {
    _Choice.light => Brightness.light,
    _Choice.dark => Brightness.dark,
    _Choice.device => platformBrightness,
  };
  final isDarkTheme = theme == Brightness.dark;

  final colors = sessionToken == null ? _legacyColors : _sessionColors;
  return (
    isDarkTheme: isDarkTheme,
    backgroundColor:
        _toOpaqueColor((sessionToken ?? style)?[isDarkTheme ? 'bgd' : 'bgl']) ??
        (isDarkTheme ? colors.dark : colors.light),
    themeToWrite: choice == _Choice.device && sessionToken == null
        ? theme
        : null,
  );
}

/// `light` and `dark` as they are, null for anything else (`system` too).
_Choice? _fixed(Object? value) => switch (value) {
  'light' => _Choice.light,
  'dark' => _Choice.dark,
  _ => null,
};

/// The session token's content, checked the way Link checks it: a numeric `v`
/// and a non-empty string `c`, by shape only. Null for a legacy link, which
/// has no such token. The token is not signed, so nothing in it is trusted.
_Json? _readSessionToken(String? token) {
  final content = _decodeJsonParam(token);
  final client = content?['c'];
  return content != null &&
          content['v'] is num &&
          client is String &&
          client.isNotEmpty
      ? content
      : null;
}

/// A param holding base64 JSON (`token`, `link_style`). URL decoding turns its
/// '+' into a space, so that is restored; the URL-safe alphabet and stripped
/// padding are accepted too.
_Json? _decodeJsonParam(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  try {
    final standard = value
        .replaceAll(' ', '+')
        .replaceAll('-', '+')
        .replaceAll('_', '/');
    final json = jsonDecode(
      utf8.decode(base64Decode(base64.normalize(standard))),
    );
    return json is _Json ? json : null;
  } on Object {
    return null;
  }
}

/// An opaque color from a valid hex color, alpha dropped; null for anything
/// else.
Color? _toOpaqueColor(Object? value) {
  if (value is! String || !_hexColor.hasMatch(value)) {
    return null;
  }
  final digits = value.substring(1);
  final full = digits.length <= 4
      ? digits.split('').map((d) => d + d).join()
      : digits;
  return Color(0xFF000000 | int.parse(full.substring(0, 6), radix: 16));
}

/// Whether [color] is dark, so light bar icons stay readable on it.
bool isDarkColor(Color color) =>
    0.299 * color.r + 0.587 * color.g + 0.114 * color.b < 0.5;
