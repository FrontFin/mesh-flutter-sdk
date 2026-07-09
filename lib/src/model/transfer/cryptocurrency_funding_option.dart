/// A cryptocurrency funding option offered during a transfer preview.
///
/// Mirrors the `CryptocurrencyFundingOption` payload type from the Link event
/// contract. All fields are optional to match the source and to avoid dropping
/// the parent event on a sparse payload.
class CryptocurrencyFundingOption {
  const CryptocurrencyFundingOption({
    this.cryptocurrencyFundingOptionType,
    this.name,
    this.paymentMethodType,
    this.usedAmountInCryptocurrency,
    this.usedAmountInFiat,
    this.cryptocurrencySymbol,
    this.fee,
  });

  factory CryptocurrencyFundingOption.fromJson(Map<String, dynamic> json) {
    final feeJson = json['fee'];
    return CryptocurrencyFundingOption(
      cryptocurrencyFundingOptionType:
          json['cryptocurrencyFundingOptionType'] as String?,
      name: json['name'] as String?,
      paymentMethodType: json['paymentMethodType'] as String?,
      usedAmountInCryptocurrency: (json['usedAmountInCryptocurrency'] as num?)
          ?.toDouble(),
      usedAmountInFiat: (json['usedAmountInFiat'] as num?)?.toDouble(),
      cryptocurrencySymbol: json['cryptocurrencySymbol'] as String?,
      fee: feeJson is Map<String, dynamic>
          ? CryptocurrencyFundingOptionFee.fromJson(feeJson)
          : null,
    );
  }

  final String? cryptocurrencyFundingOptionType;
  final String? name;
  final String? paymentMethodType;
  final double? usedAmountInCryptocurrency;
  final double? usedAmountInFiat;
  final String? cryptocurrencySymbol;
  final CryptocurrencyFundingOptionFee? fee;
}

/// The fee breakdown attached to a [CryptocurrencyFundingOption].
class CryptocurrencyFundingOptionFee {
  const CryptocurrencyFundingOptionFee({
    this.amountInFiat,
    this.fiatSymbol,
    this.amountInCryptocurrency,
    this.cryptocurrencySymbol,
    this.isInclusive,
    this.usedCurrencyType,
  });

  factory CryptocurrencyFundingOptionFee.fromJson(Map<String, dynamic> json) {
    return CryptocurrencyFundingOptionFee(
      amountInFiat: (json['amountInFiat'] as num?)?.toDouble(),
      fiatSymbol: json['fiatSymbol'] as String?,
      amountInCryptocurrency: (json['amountInCryptocurrency'] as num?)
          ?.toDouble(),
      cryptocurrencySymbol: json['cryptocurrencySymbol'] as String?,
      isInclusive: json['isInclusive'] as bool?,
      usedCurrencyType: json['usedCurrencyType'] as String?,
    );
  }

  final double? amountInFiat;
  final String? fiatSymbol;
  final double? amountInCryptocurrency;
  final String? cryptocurrencySymbol;
  final bool? isInclusive;
  final String? usedCurrencyType;
}
