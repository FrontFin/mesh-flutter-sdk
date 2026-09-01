import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mesh_sdk_flutter/src/model/integration/integration_connected_payload.dart';
import 'package:mesh_sdk_flutter/src/model/integration_access_token.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_error_type.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_event.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_link_environment.dart';
import 'package:mesh_sdk_flutter/src/model/success/success.dart';
import 'package:mesh_sdk_flutter/src/model/transfer/transfer_finished_payload.dart';

const _defaultLanguage = 'en';

/// Configuration for the Mesh SDK.
class MeshConfiguration {
  const MeshConfiguration({
    required this.linkToken,
    this.language = _defaultLanguage,
    this.displayFiatCurrency,
    this.theme,
    this.isDomainWhitelistEnabled = true,
    this.integrationAccessTokens = const [],
    this.onSuccess,
    this.onError,
    this.onEvent,
    this.onIntegrationConnected,
    this.onTransferFinished,
  });

  /// Opens Link from a session token minted by `POST /v2/sessions`, which
  /// returns a bare token rather than a link token.
  ///
  /// The token is wrapped into a link token for [environment], so everything
  /// downstream behaves exactly as it does for a link token from the Mesh API.
  ///
  /// ```dart
  /// MeshConfiguration.session(
  ///   token: 'ory_ac_...',
  ///   environment: MeshLinkEnvironment.prod,
  /// )
  /// ```
  factory MeshConfiguration.session({
    required String token,
    MeshLinkEnvironment environment = MeshLinkEnvironment.prod,
    String language = _defaultLanguage,
    String? displayFiatCurrency,
    ThemeMode? theme,
    bool isDomainWhitelistEnabled = true,
    List<IntegrationAccessToken> integrationAccessTokens =
        const <IntegrationAccessToken>[],
    ValueChanged<SuccessPayload>? onSuccess,
    ValueChanged<MeshErrorType>? onError,
    ValueChanged<MeshEvent>? onEvent,
    ValueChanged<IntegrationConnectedEvent>? onIntegrationConnected,
    ValueChanged<TransferFinishedEvent>? onTransferFinished,
  }) {
    final url = '${environment.linkUrl}/?token=$token';

    return MeshConfiguration(
      linkToken: base64Encode(utf8.encode(url)),
      language: language,
      displayFiatCurrency: displayFiatCurrency,
      theme: theme,
      isDomainWhitelistEnabled: isDomainWhitelistEnabled,
      integrationAccessTokens: integrationAccessTokens,
      onSuccess: onSuccess,
      onError: onError,
      onEvent: onEvent,
      onIntegrationConnected: onIntegrationConnected,
      onTransferFinished: onTransferFinished,
    );
  }

  /// To get a link token, use Mesh API.
  final String linkToken;

  /// Link UI language. Supported: 'en', 'es', 'pt'.
  /// Default: 'en'.
  final String language;

  /// The currency to display a fiat equivalent of the crypto amount in Link UI.
  /// Default: 'USD'
  final String? displayFiatCurrency;

  /// Link UI theme. Possible values: 'dark', 'light' and 'system'.
  final ThemeMode? theme;

  /// Whether to check domains against our whitelist. Defaults to true.
  final bool isDomainWhitelistEnabled;

  /// List of integration access tokens to be used in the Mesh Link.
  /// Use [onIntegrationConnected] callback to get the access token
  /// and save it on your end.
  final List<IntegrationAccessToken> integrationAccessTokens;

  /// Callback for when the Mesh Link is successfully completed.
  /// Check [SuccessPayload] for details.
  final ValueChanged<SuccessPayload>? onSuccess;

  /// Callback for when Mesh Link exits due to an error.
  /// Check [MeshErrorType] for details.
  final ValueChanged<MeshErrorType>? onError;

  /// Callback for when an event occurs.
  /// Check [MeshEvent] for details.
  final ValueChanged<MeshEvent>? onEvent;

  /// Callback for when an integration is connected.
  /// You can use [AccessTokenPayload] to save the access token
  /// and pass it to the [integrationAccessTokens] params later.
  /// This way, user will have to connect to an integration only once.
  final ValueChanged<IntegrationConnectedEvent>? onIntegrationConnected;

  /// Callback for when the transfer is finished.
  /// It can be a success or a failure.
  /// Check [TransferFinishedPayload] for details.
  final ValueChanged<TransferFinishedEvent>? onTransferFinished;
}
