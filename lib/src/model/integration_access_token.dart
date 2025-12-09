import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';

/// Represents an access token for a specific integration.
///
/// To skip the need to authenticate the user every time,
/// pass a list of integration access tokens to Mesh SDK
/// using [MeshConfiguration.integrationAccessTokens].
///
/// To save the access token on your end,
/// use [MeshConfiguration.onIntegrationConnected] callback.
class IntegrationAccessToken {
  const IntegrationAccessToken({
    required this.accountId,
    required this.accountName,
    required this.accessToken,
    required this.brokerType,
    required this.brokerName,
  });

  final String accountId;
  final String accountName;
  final String accessToken;
  final String brokerType;
  final String brokerName;

  Map<String, dynamic> toJson() => {
    'accountId': accountId,
    'accountName': accountName,
    'accessToken': accessToken,
    'brokerType': brokerType,
    'brokerName': brokerName,
  };
}
