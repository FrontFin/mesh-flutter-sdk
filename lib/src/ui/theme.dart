import 'package:flutter/services.dart';
import 'package:mesh_sdk_flutter/src/util/theme.dart';

/// The status bar and navigation bar style for a Link page of [color]. Their
/// icons follow the luminance of [color], not the theme: a client color can be
/// light on a dark theme.
SystemUiOverlayStyle linkBarStyle(Color color) => barStyle(
  color: color,
  iconBrightness: isDarkColor(color) ? Brightness.light : Brightness.dark,
);

/// A bar style with the bar [color] and the brightness of the icons on it.
SystemUiOverlayStyle barStyle({
  required Color color,
  required Brightness iconBrightness,
}) => SystemUiOverlayStyle(
  statusBarBrightness: iconBrightness == Brightness.light
      ? Brightness.dark
      : Brightness.light,
  statusBarColor: color,
  statusBarIconBrightness: iconBrightness,
  systemNavigationBarColor: color,
  systemNavigationBarIconBrightness: iconBrightness,
);
