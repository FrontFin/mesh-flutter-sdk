import 'package:android_intent_plus/flag.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/util/new_task_launcher.dart';

void main() {
  group('buildNewTaskIntent', () {
    test('opens the wallet link in a new task', () {
      final intent = buildNewTaskIntent(Uri.parse('uniswap://wc?uri=wc%3Aabc'));

      expect(intent.action, 'action_view');
      expect(intent.data, 'uniswap://wc?uri=wc%3Aabc');
      expect(intent.flags, [Flag.FLAG_ACTIVITY_NEW_TASK]);
    });
  });

  group('mapLaunchError', () {
    test('maps a missing app to the activity not found code', () {
      final error = PlatformException(
        code: 'error',
        message: 'No Activity found to handle Intent { act=VIEW }',
      );

      expect(mapLaunchError(error).code, activityNotFoundCode);
    });

    test('keeps other errors as they are', () {
      final error = PlatformException(code: 'error', message: 'Denied');

      expect(mapLaunchError(error), same(error));
    });
  });
}
