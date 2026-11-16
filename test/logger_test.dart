import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:mesh_sdk_flutter/src/util/logger.dart';

void main() {
  group('scrubUrlTails', () {
    test('drops the query and fragment of a URL', () {
      expect(
        scrubUrlTails('Opened https://a.com/p?code=SECRET&state=S#frag now'),
        'Opened https://a.com/p now',
      );
    });

    test('drops the query of a scheme without slashes', () {
      expect(scrubUrlTails('wc:topic@2?symKey=SECRET'), 'wc:topic@2');
    });

    test('handles a URL inside quotes or parentheses', () {
      expect(
        scrubUrlTails('Failed (https://a.com/?code=SECRET) "trust://wc?u=S"'),
        'Failed (https://a.com/) "trust://wc"',
      );
    });

    test('keeps closing brackets that follow a URL', () {
      expect(
        scrubUrlTails('{url: https://a.com/?code=SECRET}, [x: wc:t?k=S]'),
        '{url: https://a.com/}, [x: wc:t]',
      );
    });

    test('leaves text without URLs untouched', () {
      expect(
        scrubUrlTails('Result received: MeshSuccess'),
        'Result received: MeshSuccess',
      );
    });
  });

  group('formatLogRecord', () {
    test('scrubs the message, error and stack trace', () {
      final record = LogRecord(
        Level.SEVERE,
        'bad https://a.com/?code=SECRET',
        'MeshSDK',
        'https://b.com/?state=SECRET',
        StackTrace.fromString('at https://c.com/x.dart?token=SECRET:1:1'),
      );

      expect(formatLogRecord(record).join('\n'), isNot(contains('SECRET')));
    });
  });
}
