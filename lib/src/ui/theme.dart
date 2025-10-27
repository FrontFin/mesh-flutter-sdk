import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
