import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/query_params.dart';

void main() {
  group('getFirstQueryParam', () {
    test('returns the first value', () {
      expect(
        getFirstQueryParam('https://a.com/?th=dark&th=light', 'th'),
        'dark',
      );
    });

    test('decodes the value and matches a decoded key', () {
      expect(getFirstQueryParam('https://a.com/?t%68=a%20b', 'th'), 'a b');
    });

    test('ignores the fragment', () {
      expect(getFirstQueryParam('https://a.com/?a=1#th=dark', 'th'), isNull);
    });

    test('returns empty for a key without a value', () {
      expect(getFirstQueryParam('https://a.com/?th', 'th'), '');
    });

    test('keeps a malformed escape as is', () {
      expect(getFirstQueryParam('https://a.com/?th=%zz', 'th'), '%zz');
    });
  });

  group('removeQueryParam', () {
    test('removes every value and keeps the rest byte for byte', () {
      const flow = '{%22flow%22%3A%22login%22}';
      expect(
        removeQueryParam(
          'https://a.com/?token=x&th=dark&flow=$flow&th=light',
          'th',
        ),
        'https://a.com/?token=x&flow=$flow',
      );
    });

    test('keeps empty query parts', () {
      expect(
        removeQueryParam('https://a.com/?a=1&&b=2&', 'th'),
        'https://a.com/?a=1&&b=2&',
      );
    });

    test('drops the question mark when nothing is left', () {
      expect(
        removeQueryParam('https://a.com/?th=dark', 'th'),
        'https://a.com/',
      );
    });

    test('keeps the fragment', () {
      expect(
        removeQueryParam('https://a.com/?th=dark&a=1#th=x', 'th'),
        'https://a.com/?a=1#th=x',
      );
    });
  });

  group('setQueryParam', () {
    test('replaces an existing value', () {
      expect(
        setQueryParam('https://a.com/?th=dark&a=1', 'th', 'light'),
        'https://a.com/?a=1&th=light',
      );
    });

    test('adds a query when there is none, before the fragment', () {
      expect(
        setQueryParam('https://a.com/#x', 'th', 'dark'),
        'https://a.com/?th=dark#x',
      );
    });
  });
}
