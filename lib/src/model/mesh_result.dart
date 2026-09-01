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

  /// `page` reported when the host closes without an event summary, which is
  /// how Link v3's legacy bridge sends `close`.
  static const unknownPage = 'unknown';

  static MeshResult? fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final payload = json['payload'];

    try {
      return switch (type) {
        'close' || 'done' when payload is Map<String, dynamic> => MeshSuccess(
          payload: SuccessPayload.fromJson(payload),
        ),
        // Link v3 sends a bare `{type: 'close'}`; v1/v2 always attach an event
        // summary. Without this the message is unhandled and the page never
        // closes, and the native nav bar is hidden while on the Link host so
        // there is no other visible way out. Scoped to `close`: `done` is
        // v1/v2-only and always carries a payload.
        'close' => const MeshSuccess(
          payload: BaseSuccessPayload(page: unknownPage),
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
