import 'package:mesh_sdk/src/model/integration/integration_connected_payload.dart';
import 'package:mesh_sdk/src/model/transfer/transfer_finished_payload.dart';
import 'package:mesh_sdk/src/util/logger.dart';

sealed class MeshInternalEvent {
  const MeshInternalEvent();

  static MeshInternalEvent? fromJson(Map<String, dynamic> json) {
    try {
      final type = json['type'] as String?;
      if (type == null) {
        return null;
      }

      final payload = json['payload'];

      return switch (type) {
        'showClose' => const ShowClose(),
        'showNativeNavbar' when payload is bool => ShowNativeNavBar(
          show: payload,
        ),
        'delayedAuthentication' when payload is Map<String, dynamic> =>
          IntegrationConnected(payload: DelayedAuthPayload.fromJson(payload)),
        'brokerageAccountAccessToken' when payload is Map<String, dynamic> =>
          IntegrationConnected(payload: AccessTokenPayload.fromJson(payload)),
        'transferFinished' when payload is Map<String, dynamic> =>
          TransferFinished(payload: TransferFinishedPayload.fromJson(payload)),
        _ => null,
      };
    } catch (e, s) {
      logger.severe('Failed to parse MeshInternalEvent from JSON: $json', e, s);
      return null;
    }
  }
}

class ShowClose extends MeshInternalEvent {
  const ShowClose();
}

class ShowNativeNavBar extends MeshInternalEvent {
  const ShowNativeNavBar({required this.show});

  final bool show;
}

class IntegrationConnected extends MeshInternalEvent {
  const IntegrationConnected({required this.payload});

  final IntegrationConnectedPayload payload;
}

class TransferFinished extends MeshInternalEvent {
  const TransferFinished({required this.payload});

  final TransferFinishedPayload payload;
}
