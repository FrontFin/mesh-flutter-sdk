/// Returns [url] reduced to `scheme://host` so it is safe to log.
///
/// Link URLs carry a short-lived credential in the query string, and OAuth
/// callbacks carry `code` and `state`. Never log anything beyond the origin.
String redactUri(Object? url) {
  final uri = switch (url) {
    final Uri uri => uri,
    final String text => Uri.tryParse(text),
    _ => null,
  };

  if (uri == null || uri.scheme.isEmpty) {
    return '<unparsable url>';
  }

  return uri.host.isEmpty ? '${uri.scheme}:' : '${uri.scheme}://${uri.host}';
}
