import 'package:mesh_sdk/src/model/integration/integration_connected_payload.dart';
import 'package:mesh_sdk/src/model/transfer/transfer_finished_payload.dart';
import 'package:mesh_sdk/src/util/logger.dart';

sealed class MeshEvent {
  const MeshEvent();

  static MeshEvent? fromJson(Map<String, dynamic> json) {
    try {
      final type = json['type'] as String?;
      if (type == null) {
        return null;
      }

      final payload = json['payload'];

      return switch (json['type']) {
        'integrationSelected' when payload is Map<String, dynamic> =>
          IntegrationSelectedEvent(
            type: payload['integrationType'] as String,
            name: payload['integrationName'] as String,
          ),
        _ => null,
      };
    } catch (e, s) {
      logger.severe('Failed to parse MeshEvent from JSON: $json', e, s);
      return null;
    }
  }
}

class LoadedEvent extends MeshEvent {
  const LoadedEvent();
}

class IntegrationSelectedEvent extends MeshEvent {
  const IntegrationSelectedEvent({required this.type, required this.name});

  final String type;
  final String name;
}

class IntegrationConnectedEvent extends MeshEvent {
  const IntegrationConnectedEvent({required this.payload});

  final IntegrationConnectedPayload payload;
}

class TransferFinishedEvent extends MeshEvent {
  const TransferFinishedEvent({required this.payload});

  final TransferFinishedPayload payload;
}
