class NetworkFee {
  const NetworkFee({this.fee, this.feeCurrency, this.feeInFiat});

  factory NetworkFee.fromJson(Map<String, dynamic> json) {
    return NetworkFee(
      fee: (json['fee'] as num?)?.toDouble(),
      feeCurrency: json['feeCurrency'] as String?,
      feeInFiat: (json['feeInFiat'] as num?)?.toDouble(),
    );
  }

  final double? fee;
  final String? feeCurrency;
  final double? feeInFiat;
}
