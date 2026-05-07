import 'package:mesh_sdk_flutter/src/model/integration/account.dart';

class AccountToken {
  const AccountToken({
    required this.account,
    required this.accessToken,
    this.refreshToken,
    this.tokenId,
  });

  factory AccountToken.fromJson(Map<String, dynamic> json) {
    return AccountToken(
      account: Account.fromJson(json['account'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      tokenId: json['tokenId'] as String?,
    );
  }

  final Account account;
  final String accessToken;
  final String? refreshToken;
  final String? tokenId;
}
