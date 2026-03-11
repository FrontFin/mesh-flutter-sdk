import 'package:flutter/material.dart';

String resolveLanguage(String language) {
  if (language == 'system') {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    return locale.languageCode;
  }
  return language;
}
