class IneligibleToken {
  const IneligibleToken({
    required this.symbol,
    required this.amount,
    this.amountInFiat,
    this.ineligibilityReason,
  });

  factory IneligibleToken.fromJson(Map<String, dynamic> json) {
    return IneligibleToken(
      symbol: json['symbol'] as String,
      amount: (json['amount'] as num).toDouble(),
      amountInFiat: (json['amountInFiat'] as num?)?.toDouble(),
      ineligibilityReason: json['ineligibilityReason'] as String?,
    );
  }

  final String symbol;
  final double amount;
  final double? amountInFiat;
  final String? ineligibilityReason;
}
