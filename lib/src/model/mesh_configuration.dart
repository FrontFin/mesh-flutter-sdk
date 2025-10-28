import 'package:flutter/foundation.dart';
import 'package:mesh_sdk/src/model/integration_access_token.dart';
import 'package:mesh_sdk/src/model/mesh_error_type.dart';
import 'package:mesh_sdk/src/model/mesh_event.dart';

const _defaultLanguage = 'en';

class MeshConfiguration {
  const MeshConfiguration({
    required this.linkToken,
    this.language = _defaultLanguage,
    this.integrationAccessTokens = const [],
    this.onExit,
    this.onEvent,
    this.onIntegrationConnected,
    this.onTransferFinished,
  });

  final String linkToken;
  final String language;
  final List<IntegrationAccessToken> integrationAccessTokens;
  final ValueChanged<MeshErrorType>? onExit;
  final ValueChanged<MeshEvent>? onEvent;
  final ValueChanged<IntegrationConnectedEvent>? onIntegrationConnected;
  final ValueChanged<TransferFinishedEvent>? onTransferFinished;
}
