import 'package:mesh_sdk_flutter/src/mesh_sdk_flutter.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_error_type.dart';
import 'package:mesh_sdk_flutter/src/model/success/success.dart';
import 'package:mesh_sdk_flutter/src/util/logger.dart';

/// Represents the result of [MeshSdk.show].
/// This can either be a [MeshSuccess] or a [MeshError].
///
/// Use [when] to handle the result based on its type.
sealed class MeshResult {
  const MeshResult();

  static MeshResult? fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final payload = json['payload'];

    try {
      return switch (type) {
        'close' || 'done' when payload is Map<String, dynamic> => MeshSuccess(
          payload: SuccessPayload.fromJson(payload),
        ),
        _ => null,
      };
    } catch (e, s) {
      logger.severe('Error parsing MeshResult from JSON: $json', e, s);
      return null;
    }
  }

  R when<R>({
    required R Function(MeshSuccess) success,
    required R Function(MeshError) error,
  }) {
    final result = this;
    return switch (result) {
      MeshSuccess() => success(result),
      MeshError() => error(result),
    };
  }
}

class MeshSuccess extends MeshResult {
  const MeshSuccess({required this.payload});

  final SuccessPayload payload;
}

class MeshError extends MeshResult {
  const MeshError(this.type);

  final MeshErrorType type;
}
