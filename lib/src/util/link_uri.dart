import 'dart:convert';

import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';
import 'package:mesh_sdk_flutter/src/util/language.dart';

/// Builds the full link [Uri] from [configuration] (including its link token),
/// with query parameters for language, theme, and fiat currency.
Uri buildLinkUri(MeshConfiguration configuration) {
  final url = String.fromCharCodes(base64Decode(configuration.linkToken));
  final parsedUri = Uri.parse(url);
  final queryParams = parsedUri.queryParameters;

  final lng = resolveLanguage(configuration.language);
  queryParams['lng'] = lng;

  final fiatCur = configuration.displayFiatCurrency;
  if (fiatCur != null) {
    queryParams['fiatCur'] = fiatCur;
  }

  final th = configuration.theme?.name;
  if (th != null) {
    queryParams['th'] = th;
  }

  return parsedUri.replace(queryParameters: queryParams);
}
