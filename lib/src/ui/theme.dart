import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// One dark and one light color for every Link version and client branding,
// close enough to all of them that there's no visible seam.
const navBarColorDark = Color(0xFF1C1C1C);
const navBarColorLight = Color(0xFFF9F9F9);
const iconColorDark = Colors.white;

/// The color around Link and of the native nav bar.
Color getNavBarColor(Brightness brightness) => switch (brightness) {
  Brightness.light => navBarColorLight,
  Brightness.dark => navBarColorDark,
};

/// This will update the system bar brightness.
///
/// Call this whenever Mesh Link brightness is changed.
void onBrightnessChanged(Brightness brightness) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarBrightness: brightness,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: switch (brightness) {
        Brightness.light => Brightness.dark,
        Brightness.dark => Brightness.light,
      },
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: switch (brightness) {
        Brightness.light => Brightness.dark,
        Brightness.dark => Brightness.light,
      },
    ),
  );
}
