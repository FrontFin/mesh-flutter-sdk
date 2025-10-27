import 'package:mesh_sdk/src/model/integration_access_token.dart';

class MeshConfiguration {
  const MeshConfiguration({
    required this.linkToken,
    this.integrationAccessTokens = const [],
  });

  final String linkToken;
  final List<IntegrationAccessToken> integrationAccessTokens;
}
