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
