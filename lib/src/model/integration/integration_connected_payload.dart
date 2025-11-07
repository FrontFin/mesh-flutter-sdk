import 'package:mesh_sdk_flutter/src/model/integration/account_token.dart';
import 'package:mesh_sdk_flutter/src/model/integration/brand_info.dart';

sealed class IntegrationConnectedPayload {
  const IntegrationConnectedPayload();
}

class DelayedAuthPayload extends IntegrationConnectedPayload {
  const DelayedAuthPayload({
    required this.brokerType,
    required this.refreshToken,
    required this.brokerName,
    required this.brokerBrandInfo,
    this.refreshTokenExpiresInSeconds,
  });

  factory DelayedAuthPayload.fromJson(Map<String, dynamic> json) {
    return DelayedAuthPayload(
      brokerType: json['brokerType'] as String,
      refreshToken: json['refreshToken'] as String,
      brokerName: json['brokerName'] as String,
      brokerBrandInfo: BrandInfo.fromJson(
        json['brokerBrandInfo'] as Map<String, dynamic>,
      ),
      refreshTokenExpiresInSeconds:
          json['refreshTokenExpiresInSeconds'] as int?,
    );
  }

  final int? refreshTokenExpiresInSeconds;
  final String brokerType;
  final String refreshToken;
  final String brokerName;
  final BrandInfo brokerBrandInfo;
}

class AccessTokenPayload extends IntegrationConnectedPayload {
  const AccessTokenPayload({
    required this.accountTokens,
    required this.brokerBrandInfo,
    required this.brokerType,
    required this.brokerName,
    this.expiresInSeconds,
    this.refreshTokenExpiresInSeconds,
  });

  factory AccessTokenPayload.fromJson(Map<String, dynamic> json) {
    return AccessTokenPayload(
      accountTokens: (json['accountTokens'] as List<dynamic>)
          .map((e) => AccountToken.fromJson(e as Map<String, dynamic>))
          .toList(),
      brokerBrandInfo: BrandInfo.fromJson(
        json['brokerBrandInfo'] as Map<String, dynamic>,
      ),
      expiresInSeconds: json['expiresInSeconds'] as int?,
      refreshTokenExpiresInSeconds:
          json['refreshTokenExpiresInSeconds'] as int?,
      brokerType: json['brokerType'] as String,
      brokerName: json['brokerName'] as String,
    );
  }

  final List<AccountToken> accountTokens;
  final BrandInfo brokerBrandInfo;
  final int? expiresInSeconds;
  final int? refreshTokenExpiresInSeconds;
  final String brokerType;
  final String brokerName;
}
