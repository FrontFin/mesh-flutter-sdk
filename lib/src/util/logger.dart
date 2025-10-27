import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

Logger createLogger() => Logger.detached('MeshSDK')
  ..level = Level.INFO
  ..onRecord.listen((record) {
    debugPrint(
      '${record.loggerName}(${record.level.name}) :: '
      '${record.time} :: ${record.message}',
    );

    if (record.error != null) {
      debugPrint('ERROR: ${record.error}');
    }

    if (record.stackTrace != null) {
      debugPrint('STACK TRACE: ${record.stackTrace}');
    }
  });
