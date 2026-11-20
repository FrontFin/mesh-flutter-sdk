import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/util/logger.dart';

/// `light`, `dark` or `system` as a [Brightness]; null for anything else.
Brightness? resolveTheme(String? theme, Brightness platformBrightness) =>
    switch (theme) {
      'light' => Brightness.light,
      'dark' => Brightness.dark,
      'system' => platformBrightness,
      _ => null,
    };

/// The theme Link opens in: app theme, then the URL's `th`, then
/// `link_style.th`, then dark (Link's default).
Brightness resolveLinkTheme({
  required Brightness? appTheme,
  required String? urlTheme,
  required String? linkStyle,
  required Brightness platformBrightness,
}) =>
    appTheme ??
    resolveTheme(urlTheme, platformBrightness) ??
    resolveTheme(_linkStyleTheme(linkStyle), platformBrightness) ??
    Brightness.dark;

String? _linkStyleTheme(String? linkStyle) {
  if (linkStyle == null || linkStyle.isEmpty) {
    return null;
  }
  try {
    // URL decoding turns '+' into a space.
    final value = base64.normalize(linkStyle.replaceAll(' ', '+'));
    final style = json.decode(utf8.decode(base64.decode(value)));
    final th = style is Map ? style['th'] : null;
    return th is String && th.isNotEmpty ? th : null;
  } on Object catch (e) {
    logger.warning("Couldn't read the theme from link_style: $e");
    return null;
  }
}
