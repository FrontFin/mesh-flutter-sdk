import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final logger = Logger.detached('MeshSDK')
  ..level = Level.INFO
  ..onRecord.listen(_printRecord);

// Matches a URL-like token (`https://host/path`, `wc:topic@2`) followed by a
// query or fragment, and captures the part before it.
final _urlTail = RegExp(
  r'''(\b[a-zA-Z][a-zA-Z0-9+.\-]*:[^\s?#'")\]}>]*)[?#][^\s'")\]}>]*''',
);

/// Drops the query and fragment from every URL-like token in [text].
///
/// Safety net for log calls that forget `redactUri`: link URLs carry a
/// short-lived credential in the query, and OAuth callbacks carry code/state.
String scrubUrlTails(String text) {
  // Cheap guard: a URL tail needs a `?` or `#`, so skip the regex otherwise.
  if (!text.contains('?') && !text.contains('#')) {
    return text;
  }

  return text.replaceAllMapped(_urlTail, (match) => match.group(1)!);
}

/// Formats [record] into the lines the SDK prints, with URL tails scrubbed.
List<String> formatLogRecord(LogRecord record) => [
  scrubUrlTails(
    '${getEmojiForLevel(record.level)} ${record.loggerName} :: '
    '${record.time} :: ${record.message}',
  ),
  if (record.error != null) scrubUrlTails('ERROR: ${record.error}'),
  if (record.stackTrace != null)
    scrubUrlTails('STACK TRACE: ${record.stackTrace}'),
];

void _printRecord(LogRecord record) {
  // Release builds print nothing, so no diagnostics reach device logs.
  if (!kDebugMode) {
    return;
  }

  formatLogRecord(record).forEach(debugPrint);
}

String getEmojiForLevel(Level level) => switch (level) {
  Level.FINEST || Level.FINER || Level.FINE => '🔍',
  Level.CONFIG => '⚙️',
  Level.INFO => 'ℹ️',
  Level.WARNING => '⚠️',
  Level.SEVERE => '❗',
  Level.SHOUT => '🚨',
  _ => 'ℹ️',
};
