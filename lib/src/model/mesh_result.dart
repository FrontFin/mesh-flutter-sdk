import 'package:mesh_sdk/src/model/mesh_error_type.dart';

sealed class MeshResult {
  const MeshResult();

  R when<R>({
    required R Function() success,
    required R Function(MeshError) error,
  }) {
    final result = this;
    return switch (result) {
      MeshSuccess() => success(),
      MeshError() => error(result),
    };
  }
}

class MeshSuccess extends MeshResult {
  const MeshSuccess();
}

class MeshError extends MeshResult {
  const MeshError(this.type);

  final MeshErrorType type;
}
