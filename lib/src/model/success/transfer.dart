class Transfer {
  const Transfer({
    required this.amount,
    required this.amountInFiat,
    required this.symbol,
    required this.transactionId,
    required this.networkId,
    required this.previewId,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      amount: (json['amount'] as num).toDouble(),
      amountInFiat: (json['amountInFiat'] as num).toDouble(),
      symbol: json['symbol'] as String,
      transactionId: json['transactionId'] as String,
      networkId: json['networkId'] as String,
      previewId: json['previewId'] as String,
    );
  }

  final double amount;
  final double amountInFiat;
  final String symbol;
  final String transactionId;
  final String networkId;
  final String previewId;
}
