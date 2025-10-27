import 'package:flutter/material.dart';

class LinkStyle {
  const LinkStyle({required this.theme});

  factory LinkStyle.fromJson(Map<String, dynamic> json) => LinkStyle(
    theme: switch (json['th']) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    },
  );

  final ThemeMode theme;
}
