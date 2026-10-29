// Plain string helpers instead of Uri.replace, so the token URL is never
// re-encoded.

({String beforeFragment, String fragment}) _splitFragment(String url) {
  final hash = url.indexOf('#');
  return hash == -1
      ? (beforeFragment: url, fragment: '')
      : (beforeFragment: url.substring(0, hash), fragment: url.substring(hash));
}

List<String> _queryPairs(String url) {
  final beforeFragment = _splitFragment(url).beforeFragment;
  final queryStart = beforeFragment.indexOf('?');
  return queryStart == -1
      ? const []
      : beforeFragment.substring(queryStart + 1).split('&');
}

String _decode(String value) {
  try {
    return Uri.decodeQueryComponent(value);
  } on Object {
    // A malformed escape like %zz stays as is.
    return value.replaceAll('+', ' ');
  }
}

String _pairKey(String pair) {
  final separator = pair.indexOf('=');
  return _decode(separator == -1 ? pair : pair.substring(0, separator));
}

/// First value of [name], or null when it's missing.
String? getFirstQueryParam(String url, String name) {
  for (final pair in _queryPairs(url)) {
    if (pair.isEmpty || _pairKey(pair) != name) {
      continue;
    }
    final separator = pair.indexOf('=');
    return separator == -1 ? '' : _decode(pair.substring(separator + 1));
  }
  return null;
}

/// Removes every [name], leaving the rest of the URL byte for byte.
String removeQueryParam(String url, String name) {
  final (:beforeFragment, :fragment) = _splitFragment(url);
  final queryStart = beforeFragment.indexOf('?');
  if (queryStart == -1) {
    return url;
  }
  final kept = _queryPairs(
    url,
  ).where((pair) => pair.isEmpty || _pairKey(pair) != name);
  final base = beforeFragment.substring(0, queryStart);
  return '$base${kept.isEmpty ? '' : '?${kept.join('&')}'}$fragment';
}

/// Sets [name] to [value], replacing any existing value. Added before any
/// fragment, so Link still sees it.
String setQueryParam(String url, String name, String value) {
  final (:beforeFragment, :fragment) = _splitFragment(
    removeQueryParam(url, name),
  );
  final separator = beforeFragment.contains('?') ? '&' : '?';
  final pair =
      '${Uri.encodeQueryComponent(name)}=${Uri.encodeQueryComponent(value)}';
  return '$beforeFragment$separator$pair$fragment';
}
