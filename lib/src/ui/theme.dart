import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const navBarColorDark = Color(0xFF1E1E24);
const navBarColorLight = Color(0xFFFBFBFB);
const iconColorDark = Colors.white;

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
