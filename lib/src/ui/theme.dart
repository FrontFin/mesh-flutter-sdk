import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const navBarColorDark = Color(0xFF1E1E24);
const navBarColorLight = Color(0xFFFBFBFB);
const iconColorDark = Colors.white;

// The latest Link's canvas (--color-bg-canvas-dark/light in FrontFin/link
// packages/ui/src/styles/tailwind.css), so the area around it has no seam.
const latestLinkColorDark = Color(0xFF1C1C1C);
const latestLinkColorLight = Color(0xFFF9F9F9);

Color getNavBarColor(Brightness brightness) => switch (brightness) {
  Brightness.light => navBarColorLight,
  Brightness.dark => navBarColorDark,
};

/// The color around Link, matching the page it shows.
Color getLinkBackgroundColor(
  Brightness brightness, {
  required bool isLatestLink,
}) => isLatestLink
    ? switch (brightness) {
        Brightness.light => latestLinkColorLight,
        Brightness.dark => latestLinkColorDark,
      }
    : getNavBarColor(brightness);

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
