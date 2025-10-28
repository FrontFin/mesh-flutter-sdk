import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final logger = Logger.detached('MeshSDK')
  ..level = Level.INFO
  ..onRecord.listen((record) {
    debugPrint(
      '${getEmojiForLevel(record.level)} ${record.loggerName} :: '
      '${record.time} :: ${record.message}',
    );

    if (record.error != null) {
      debugPrint('ERROR: ${record.error}');
    }

    if (record.stackTrace != null) {
      debugPrint('STACK TRACE: ${record.stackTrace}');
    }
  });

String getEmojiForLevel(Level level) => switch (level) {
  Level.FINEST || Level.FINER || Level.FINE => '🔍',
  Level.CONFIG => '⚙️',
  Level.INFO => 'ℹ️',
  Level.WARNING => '⚠️',
  Level.SEVERE => '❗',
  Level.SHOUT => '🚨',
  _ => 'ℹ️',
};
