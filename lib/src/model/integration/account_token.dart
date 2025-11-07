import 'package:mesh_sdk_flutter/src/model/integration/account.dart';

class AccountToken {
  const AccountToken({
    required this.account,
    required this.accessToken,
    this.refreshToken,
  });

  factory AccountToken.fromJson(Map<String, dynamic> json) {
    return AccountToken(
      account: Account.fromJson(json['account'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  final Account account;
  final String accessToken;
  final String? refreshToken;
}
