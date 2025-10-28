class Account {
  const Account({
    required this.accountId,
    required this.accountName,
    this.fund,
    this.cash,
    this.isReconnected,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: json['accountId'] as String,
      accountName: json['accountName'] as String,
      fund: (json['fund'] as num?)?.toDouble(),
      cash: (json['cash'] as num?)?.toDouble(),
      isReconnected: json['isReconnected'] as bool?,
    );
  }

  final String accountId;
  final String accountName;
  final double? fund;
  final double? cash;
  final bool? isReconnected;
}
