class BrandInfo {
  const BrandInfo({
    required this.brokerLogo,
    this.brokerPrimaryColor,
    this.logoLightUrl,
    this.logoDarkUrl,
    this.iconLightUrl,
    this.iconDarkUrl,
  });

  factory BrandInfo.fromJson(Map<String, dynamic> json) {
    return BrandInfo(
      brokerLogo: json['brokerLogo'] as String,
      brokerPrimaryColor: json['brokerPrimaryColor'] as String?,
      logoLightUrl: json['logoLightUrl'] as String?,
      logoDarkUrl: json['logoDarkUrl'] as String?,
      iconLightUrl: json['iconLightUrl'] as String?,
      iconDarkUrl: json['iconDarkUrl'] as String?,
    );
  }

  final String brokerLogo;
  final String? brokerPrimaryColor;
  final String? logoLightUrl;
  final String? logoDarkUrl;
  final String? iconLightUrl;
  final String? iconDarkUrl;
}
