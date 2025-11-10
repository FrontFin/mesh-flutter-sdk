import 'package:mesh_sdk_flutter/src/model/mesh_error_type.dart';
import 'package:mesh_sdk_flutter/src/model/success/success.dart';

sealed class MeshResult {
  const MeshResult();

  static MeshResult? fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final payload = json['payload'];

    return switch (type) {
      'close' when payload is Map<String, dynamic> => MeshSuccess(
        payload: TransferSuccessPayload.fromJson(payload),
      ),
      'done' when payload is Map<String, dynamic> => MeshSuccess(
        payload: IntegrationSuccessPayload.fromJson(payload),
      ),
      _ => null,
    };
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
