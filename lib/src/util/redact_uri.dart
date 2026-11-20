/// Returns [url] reduced to `scheme://host[:port]` so it is safe to log.
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

  if (uri.host.isEmpty) {
    return '${uri.scheme}:';
  }

  // Rebuilding drops userinfo, path, query and fragment, and brackets IPv6.
  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
  ).toString();
}
