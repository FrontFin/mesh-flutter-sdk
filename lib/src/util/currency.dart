/// The app's display currency, or null when it's not set.
String? resolveCurrency(String? currency) {
  final trimmed = currency?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
