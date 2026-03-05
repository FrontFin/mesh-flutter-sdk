import 'dart:convert';

import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';
import 'package:mesh_sdk_flutter/src/util/utils.dart';

/// Builds the full link [Uri] from [configuration] (including its link token),
/// with query parameters for language, theme, and fiat currency.
Uri buildLinkUri(MeshConfiguration configuration) {
  final url = String.fromCharCodes(base64Decode(configuration.linkToken));
  final parsedUri = Uri.parse(url);
  final lng = resolveLanguage(configuration.language);
  final queryParams = <String, String>{
    ...parsedUri.queryParameters,
    'lng': lng,
  };
  if (configuration.displayFiatCurrency != null) {
    queryParams['fiatCur'] = configuration.displayFiatCurrency!;
  }
  if (configuration.theme != null) {
    queryParams['th'] = themeToQueryParam(configuration.theme!);
  }
  return parsedUri.replace(queryParameters: queryParams);
}
