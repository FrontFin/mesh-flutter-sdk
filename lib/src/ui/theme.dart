import 'package:flutter/services.dart';
import 'package:mesh_sdk_flutter/src/util/theme.dart';

/// Sets the status bar and navigation bar to [color]. Their icons follow the
/// luminance of [color], not the theme: a client color can be light on a dark
/// theme.
///
/// Call this whenever the color around Link changes.
void onBarColorChanged(Color color) {
  final icons = isDarkColor(color) ? Brightness.light : Brightness.dark;
  setSystemBars(color: color, iconBrightness: icons);
}

/// Sets the bar [color] and the brightness of the icons on it.
void setSystemBars({required Color color, required Brightness iconBrightness}) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarBrightness: iconBrightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      statusBarColor: color,
      statusBarIconBrightness: iconBrightness,
      systemNavigationBarColor: color,
      systemNavigationBarIconBrightness: iconBrightness,
    ),
  );
}
