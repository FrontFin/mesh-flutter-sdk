import 'package:mesh_sdk/src/model/integration/integration_connected_payload.dart';
import 'package:mesh_sdk/src/model/transfer/transfer_finished_payload.dart';
import 'package:mesh_sdk/src/util/logger.dart';

sealed class MeshInternalEvent {
  const MeshInternalEvent();

  static MeshInternalEvent? fromString(Map<String, dynamic> json) {
    try {
      return switch (json['type']) {
        'showClose' => const ShowClose(),
        'showNativeNavbar' => const ShowNativeNavBar(show: true),
        'delayedAuthentication' => IntegrationConnected(
          payload: DelayedAuthPayload.fromJson(
            json['payload'] as Map<String, dynamic>,
          ),
        ),
        'brokerageAccountAccessToken' => IntegrationConnected(
          payload: AccessTokenPayload.fromJson(
            json['payload'] as Map<String, dynamic>,
          ),
        ),
        'transferFinished' => TransferFinished(
          payload: TransferFinishedPayload.fromJson(
            json['payload'] as Map<String, dynamic>,
          ),
        ),
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
