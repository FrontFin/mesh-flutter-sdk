import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

/// Code the store fallback in the link controller looks for.
const activityNotFoundCode = 'ACTIVITY_NOT_FOUND';

const _noActivityMessage = 'No Activity found';

/// Opens a link on Android in its own task.
///
/// In the caller's task, a wallet that sends itself to the back (Uniswap does
/// after approval) takes the host app with it and leaves the user on the home
/// screen. Tests replace it, because the plugin does nothing off Android.
Future<void> Function(Uri uri) launchInNewTask = _launchWithAndroidIntent;

@visibleForTesting
AndroidIntent buildNewTaskIntent(Uri uri) => AndroidIntent(
  action: 'action_view',
  data: uri.toString(),
  flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
);

Future<void> _launchWithAndroidIntent(Uri uri) async {
  try {
    await buildNewTaskIntent(uri).launch();
  } on PlatformException catch (e) {
    throw mapLaunchError(e);
  }
}

/// The plugin reports every failure as code "error". Maps the missing app case
/// to [activityNotFoundCode], which the store fallback expects.
@visibleForTesting
PlatformException mapLaunchError(PlatformException e) =>
    e.message?.contains(_noActivityMessage) ?? false
    ? PlatformException(code: activityNotFoundCode)
    : e;
