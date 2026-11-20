import 'package:flutter/material.dart';

/// The app's language as a BCP-47 tag, `system` read from the device; null
/// when not set.
String? resolveLanguage(String language) {
  final trimmed = language.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  if (trimmed == 'system') {
    return WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag();
  }
  return trimmed;
}
