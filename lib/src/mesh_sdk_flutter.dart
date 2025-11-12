import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_error_type.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_result.dart';
import 'package:mesh_sdk_flutter/src/ui/page/mesh_link_page.dart';
import 'package:mesh_sdk_flutter/src/ui/theme.dart';

/// Entry point for the Mesh SDK.
/// Use this class to show the Mesh Link with your configuration.
abstract class MeshSdk {
  const MeshSdk._();

  /// Shows the Mesh Link with the provided configuration.
  ///
  /// This future will complete with a [MeshResult],
  /// which can be either a [MeshSuccess] or a [MeshError].
  /// You can use this value to determine the outcome
  /// (use [MeshResult.when] to handle both cases).
  ///
  /// Alternatively, use [MeshConfiguration.onError] and
  /// [MeshConfiguration.onSuccess] callbacks.
  static Future<MeshResult> show(
    BuildContext context, {
    required MeshConfiguration configuration,
  }) async {
    // Save the current theme brightness, to restore it later
    final brightness = Theme.brightnessOf(context);

    final result = await Navigator.of(context).push<MeshResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => MeshLinkPage(configuration: configuration),
      ),
    );

    // Restore the original theme brightness
    onBrightnessChanged(brightness);

    return result ?? const MeshError(MeshErrorType.userCancelled);
  }
}
