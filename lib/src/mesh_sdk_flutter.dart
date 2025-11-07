import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_error_type.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_result.dart';
import 'package:mesh_sdk_flutter/src/ui/page/mesh_link_page.dart';
import 'package:mesh_sdk_flutter/src/ui/theme.dart';

class MeshSdk {
  const MeshSdk._();

  static Future<MeshResult> show(
    BuildContext context, {
    required MeshConfiguration configuration,
  }) async {
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
