import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/redact_uri.dart';

void main() {
  group('redactUri', () {
    test('keeps scheme and host only', () {
      expect(
        redactUri('https://link.meshconnect.com/path?code=abc&state=xyz#frag'),
        'https://link.meshconnect.com',
      );
    });

    test('accepts a Uri', () {
      expect(
        redactUri(Uri.parse('https://example.com/cb?code=abc')),
        'https://example.com',
      );
    });

    test('keeps the host of a custom scheme and drops the query', () {
      expect(redactUri('trust://wc?uri=secret'), 'trust://wc');
    });

    test('drops everything after the scheme when there is no host', () {
      expect(redactUri('wc:topic@2?symKey=secret'), 'wc:');
    });

    test('drops userinfo', () {
      expect(
        redactUri('https://user:pass@example.com/x'),
        'https://example.com',
      );
    });

    test('handles an IPv6 host', () {
      expect(redactUri('http://[::1]:8080/x?code=secret'), 'http://::1');
    });

    test('returns a placeholder for null or unparsable input', () {
      expect(redactUri(null), '<unparsable url>');
      expect(redactUri('not a url'), '<unparsable url>');
      expect(
        redactUri('https://example.com:badport/?code=secret'),
        isNot(contains('secret')),
      );
    });
  });
}
