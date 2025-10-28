sealed class TransferFinishedPayload {
  const TransferFinishedPayload();

  factory TransferFinishedPayload.fromJson(Map<String, dynamic> json) {
    return switch (json['status']) {
      'success' => TransferFinishedSuccessPayload.fromJson(json),
      'error' => TransferFinishedErrorPayload.fromJson(json),
      _ => throw ArgumentError('Invalid status: ${json['status']}'),
    };
  }
}

class TransferFinishedSuccessPayload extends TransferFinishedPayload {
  const TransferFinishedSuccessPayload({
    required this.txId,
    required this.fromAddress,
    required this.toAddress,
    required this.symbol,
    required this.amount,
    required this.networkId,
    this.amountInFiat,
    this.totalAmountInFiat,
    this.networkName,
    this.txHash,
    this.transferId,
    this.refundAddress,
  });

  factory TransferFinishedSuccessPayload.fromJson(Map<String, dynamic> json) {
    return TransferFinishedSuccessPayload(
      txId: json['txId'] as String,
      fromAddress: json['fromAddress'] as String,
      toAddress: json['toAddress'] as String,
      symbol: json['symbol'] as String,
      amount: (json['amount'] as num).toDouble(),
      networkId: json['networkId'] as String,
      amountInFiat: (json['amountInFiat'] as num?)?.toDouble(),
      totalAmountInFiat: (json['totalAmountInFiat'] as num?)?.toDouble(),
      networkName: json['networkName'] as String?,
      txHash: json['txHash'] as String?,
      transferId: json['transferId'] as String?,
      refundAddress: json['refundAddress'] as String?,
    );
  }

  final String txId;
  final String fromAddress;
  final String toAddress;
  final String symbol;
  final double amount;
  final String networkId;
  final double? amountInFiat;
  final double? totalAmountInFiat;
  final String? networkName;
  final String? txHash;
  final String? transferId;
  final String? refundAddress;
}

class TransferFinishedErrorPayload extends TransferFinishedPayload {
  const TransferFinishedErrorPayload({required this.errorMessage});

  factory TransferFinishedErrorPayload.fromJson(Map<String, dynamic> json) {
    return TransferFinishedErrorPayload(
      errorMessage: json['errorMessage'] as String,
    );
  }

  final String errorMessage;
}
