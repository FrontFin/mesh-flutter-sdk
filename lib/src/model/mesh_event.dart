import 'package:mesh_sdk_flutter/src/model/integration/integration_connected_payload.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_configuration.dart';
import 'package:mesh_sdk_flutter/src/model/transfer/cryptocurrency_funding_option.dart';
import 'package:mesh_sdk_flutter/src/model/transfer/ineligible_token.dart';
import 'package:mesh_sdk_flutter/src/model/transfer/network_fee.dart';
import 'package:mesh_sdk_flutter/src/model/transfer/transfer_executed_status.dart';
import 'package:mesh_sdk_flutter/src/model/transfer/transfer_finished_payload.dart';
import 'package:mesh_sdk_flutter/src/util/logger.dart';

/// Represents an event that can occur in the Mesh SDK.
///
/// Use [MeshConfiguration.onEvent] to listen for these events.
sealed class MeshEvent {
  const MeshEvent();

  static MeshEvent? fromJson(Map<String, dynamic> json) {
    try {
      final type = json['type'] as String?;
      if (type == null) {
        return null;
      }

      final payload = json['payload'];
      final hasPayload = json.containsKey('payload');
      final isPayloadMap = payload is Map<String, dynamic>;

      // Events nest their fields under 'payload'. Only fall back to the root
      // JSON when there is genuinely no 'payload' key; if 'payload' is present
      // but not a map (e.g. null), treat it as an empty payload rather than
      // misreading root-level keys.
      final p = isPayloadMap
          ? payload
          : (hasPayload ? const <String, dynamic>{} : json);

      // Backward-compatible rawPayload: keep the original nested 'payload' when
      // present. For a message with no 'payload' key, expose the root without
      // the internal 'type' key so the shape stays consistent for consumers.
      final rawP = hasPayload
          ? payload
          : (Map<String, dynamic>.of(json)..remove('type'));

      return switch (json['type']) {
        'integrationSelected' => IntegrationSelectedEvent.fromJson(p),
        'loaded' => const LoadedEvent(),
        'integrationConnectionError' => IntegrationConnectionErrorEvent(
          errorMessage: p['errorMessage'] as String,
          requestId: p['requestId'] as String?,
        ),
        'credentialsEntered' => const CredentialsEnteredEvent(),
        'transferStarted' => TransferStartedEvent.fromJson(p),
        'transferPreviewed' => TransferPreviewedEvent.fromJson(p),
        'transferPreviewError' => TransferPreviewErrorEvent(
          errorMessage: p['errorMessage'] as String,
          requestId: p['requestId'] as String?,
        ),
        'transferExecutionError' => TransferExecutionErrorEvent(
          errorMessage: p['errorMessage'] as String,
          requestId: p['requestId'] as String?,
        ),
        'transferInitiated' => TransferInitiatedEvent.fromJson(p),
        'transferExecuted' => TransferExecutedEvent.fromJson(p),
        'transferNoEligibleAssets' => TransferNoEligibleAssetsEvent.fromJson(p),
        'walletMessageSigned' => WalletMessageSignedEvent.fromJson(p),
        'verifyDonePage' => const VerifyDonePageEvent(),
        'verifyWalletRejected' => const VerifyWalletRejectedEvent(),
        'legalTermsViewed' => const LegalTermsViewedEvent(),
        'seeWhatHappenedClicked' => const SeeWhatHappenedClickedEvent(),
        'fundingOptionsUpdated' => const FundingOptionsUpdatedEvent(),
        'fundingOptionsViewed' => const FundingOptionsViewedEvent(),
        'gasIncreaseWarning' => const GasIncreaseWarningEvent(),
        'executeFundingStep' => ExecuteFundingStepEvent.fromJson(p),
        'integrationMfaEntered' => IntegrationMfaEnteredEvent(rawPayload: rawP),
        'integrationOAuthStarted' => IntegrationOAuthStartedEvent(
          rawPayload: rawP,
        ),
        'integrationAccountSelectionRequired' =>
          IntegrationAccountSelectionRequiredEvent(rawPayload: rawP),
        'transferAssetSelected' => TransferAssetSelectedEvent(
          symbol: p['symbol'] as String?,
          rawPayload: rawP,
        ),
        'transferNetworkSelected' => TransferNetworkSelectedEvent(
          id: p['id'] as String?,
          name: p['name'] as String?,
          rawPayload: rawP,
        ),
        'transferAmountEntered' => TransferAmountEnteredEvent(rawPayload: rawP),
        'transferMfaRequired' => TransferMfaRequiredEvent(rawPayload: rawP),
        'transferMfaEntered' => TransferMfaEnteredEvent(rawPayload: rawP),
        'transferKycRequired' => TransferKycRequiredEvent(rawPayload: rawP),
        'connectionDeclined' => ConnectionDeclinedEvent.fromJson(
          p,
          rawPayload: rawP,
        ),
        // errorMessage is optional here (unlike the pure error events) because
        // this event also carries rawPayload and must never be dropped on a
        // sparse payload, matching the other rawPayload-bearing events.
        'transferConfigureError' => TransferConfigureErrorEvent(
          errorMessage: p['errorMessage'] as String?,
          requestId: p['requestId'] as String?,
          rawPayload: rawP,
        ),
        'connectionUnavailable' => ConnectionUnavailableEvent.fromJson(
          p,
          rawPayload: rawP,
        ),
        'transferDeclined' => TransferDeclinedEvent.fromJson(
          p,
          rawPayload: rawP,
        ),
        'linkTransferQRGenerated' => LinkTransferQrGeneratedEvent.fromJson(p),
        'methodSelected' => HomePageMethodSelectedEvent.fromJson(p),
        'integrationMfaRequired' => const IntegrationMfaRequiredEvent(),
        'defiWalletError' => DefiWalletErrorEvent.fromJson(p),
        'homePageLoaded' => const HomePageLoadedEvent(),
        _ => null,
      };
    } catch (e, s) {
      logger.severe('Failed to parse MeshEvent from JSON: $json', e, s);
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Keep-as-is events (internal SDK / backward compat)
// ---------------------------------------------------------------------------

class LoadedEvent extends MeshEvent {
  const LoadedEvent();
}

class IntegrationConnectedEvent extends MeshEvent {
  const IntegrationConnectedEvent({required this.payload});

  final IntegrationConnectedPayload payload;
}

class TransferFinishedEvent extends MeshEvent {
  const TransferFinishedEvent({required this.payload});

  final TransferFinishedPayload payload;
}

class CredentialsEnteredEvent extends MeshEvent {
  const CredentialsEnteredEvent();
}

class VerifyDonePageEvent extends MeshEvent {
  const VerifyDonePageEvent();
}

class VerifyWalletRejectedEvent extends MeshEvent {
  const VerifyWalletRejectedEvent();
}

class LegalTermsViewedEvent extends MeshEvent {
  const LegalTermsViewedEvent();
}

class SeeWhatHappenedClickedEvent extends MeshEvent {
  const SeeWhatHappenedClickedEvent();
}

class FundingOptionsUpdatedEvent extends MeshEvent {
  const FundingOptionsUpdatedEvent();
}

class FundingOptionsViewedEvent extends MeshEvent {
  const FundingOptionsViewedEvent();
}

class GasIncreaseWarningEvent extends MeshEvent {
  const GasIncreaseWarningEvent();
}

// ---------------------------------------------------------------------------
// Fixed / updated existing event classes
// ---------------------------------------------------------------------------

class IntegrationSelectedEvent extends MeshEvent {
  const IntegrationSelectedEvent({
    required this.type,
    required this.name,
    this.nativeLink,
    this.userSearched,
  });

  factory IntegrationSelectedEvent.fromJson(Map<String, dynamic> json) {
    return IntegrationSelectedEvent(
      type: json['integrationType'] as String,
      name: json['integrationName'] as String,
      nativeLink: json['nativeLink'] as String?,
      userSearched: json['userSearched'] as bool?,
    );
  }

  final String type;
  final String name;
  final String? nativeLink;
  final bool? userSearched;
}

class IntegrationConnectionErrorEvent extends MeshEvent {
  const IntegrationConnectionErrorEvent({
    required this.errorMessage,
    this.requestId,
  });

  final String errorMessage;
  final String? requestId;
}

class TransferStartedEvent extends MeshEvent {
  const TransferStartedEvent({this.integrationName, this.integrationType});

  factory TransferStartedEvent.fromJson(Map<String, dynamic> json) =>
      TransferStartedEvent(
        integrationName: json['integrationName'] as String?,
        integrationType: json['integrationType'] as String?,
      );

  final String? integrationName;
  final String? integrationType;
}

class TransferPreviewedEvent extends MeshEvent {
  const TransferPreviewedEvent({
    required this.amount,
    required this.symbol,
    required this.toAddress,
    required this.networkId,
    required this.previewId,
    this.networkName,
    this.amountInFiat,
    this.estimatedNetworkGasFee,
    this.fiatCurrency,
    this.integrationName,
    this.integrationType,
    this.institutionTransferFee,
    this.customClientFee,
    this.userId,
    this.clientTransactionId,
    this.cryptocurrencyFundingOptions,
  });

  factory TransferPreviewedEvent.fromJson(Map<String, dynamic> json) {
    final feeJson = json['estimatedNetworkGasFee'];
    final institutionFeeJson = json['institutionTransferFee'];
    final customClientFeeJson = json['customClientFee'];
    final fundingOptionsJson = json['cryptocurrencyFundingOptions'];

    return TransferPreviewedEvent(
      amount: (json['amount'] as num?)?.toDouble(),
      symbol: json['symbol'] as String,
      toAddress: json['toAddress'] as String,
      networkId: json['networkId'] as String,
      previewId: json['previewId'] as String,
      networkName: json['networkName'] as String?,
      amountInFiat: (json['amountInFiat'] as num?)?.toDouble(),
      estimatedNetworkGasFee: feeJson is Map<String, dynamic>
          ? NetworkFee.fromJson(feeJson)
          : null,
      fiatCurrency: json['fiatCurrency'] as String?,
      integrationName: json['integrationName'] as String?,
      integrationType: json['integrationType'] as String?,
      institutionTransferFee: institutionFeeJson is Map<String, dynamic>
          ? NetworkFee.fromJson(institutionFeeJson)
          : null,
      customClientFee: customClientFeeJson is Map<String, dynamic>
          ? NetworkFee.fromJson(customClientFeeJson)
          : null,
      userId: json['userId'] as String?,
      clientTransactionId: json['clientTransactionId'] as String?,
      cryptocurrencyFundingOptions: fundingOptionsJson is List
          ? fundingOptionsJson
                .whereType<Map<String, dynamic>>()
                .map(CryptocurrencyFundingOption.fromJson)
                .toList()
          : null,
    );
  }

  final double? amount;
  final String symbol;
  final String toAddress;
  final String networkId;
  final String previewId;
  final String? networkName;
  final double? amountInFiat;
  final NetworkFee? estimatedNetworkGasFee;
  final String? fiatCurrency;
  final String? integrationName;
  final String? integrationType;
  final NetworkFee? institutionTransferFee;
  final NetworkFee? customClientFee;
  final String? userId;
  final String? clientTransactionId;
  final List<CryptocurrencyFundingOption>? cryptocurrencyFundingOptions;
}

class TransferPreviewErrorEvent extends MeshEvent {
  const TransferPreviewErrorEvent({required this.errorMessage, this.requestId});

  final String errorMessage;
  final String? requestId;
}

class TransferExecutionErrorEvent extends MeshEvent {
  const TransferExecutionErrorEvent({
    required this.errorMessage,
    this.requestId,
  });

  final String errorMessage;
  final String? requestId;
}

class TransferInitiatedEvent extends MeshEvent {
  const TransferInitiatedEvent({
    required this.integrationName,
    required this.status,
    this.integrationType,
    this.clientName,
  });

  factory TransferInitiatedEvent.fromJson(Map<String, dynamic> json) {
    return TransferInitiatedEvent(
      integrationName:
          (json['integrationName'] as String?) ??
          (json['brokerName'] as String?) ??
          (throw const FormatException('Missing integrationName/brokerName')),
      status: json['status'] as String,
      integrationType: json['integrationType'] as String?,
      clientName: json['clientName'] as String?,
    );
  }

  final String integrationName;
  final String status;
  final String? integrationType;
  final String? clientName;
}

class TransferExecutedEvent extends MeshEvent {
  const TransferExecutedEvent({
    required this.status,
    required this.txId,
    required this.fromAddress,
    required this.toAddress,
    required this.symbol,
    required this.amount,
    required this.networkId,
    this.userId,
    this.clientTransactionId,
  });

  factory TransferExecutedEvent.fromJson(Map<String, dynamic> json) {
    return TransferExecutedEvent(
      status: TransferExecutedStatus.fromString(json['status'] as String),
      txId: json['txId'] as String,
      fromAddress: json['fromAddress'] as String,
      toAddress: json['toAddress'] as String,
      symbol: json['symbol'] as String,
      amount: (json['amount'] as num).toDouble(),
      networkId: json['networkId'] as String,
      userId: json['userId'] as String?,
      clientTransactionId: json['clientTransactionId'] as String?,
    );
  }

  final TransferExecutedStatus status;
  final String txId;
  final String fromAddress;
  final String toAddress;
  final String symbol;
  final double amount;
  final String networkId;
  final String? userId;
  final String? clientTransactionId;
}

class TransferNoEligibleAssetsEvent extends MeshEvent {
  const TransferNoEligibleAssetsEvent({
    required this.integrationType,
    required this.integrationName,
    required this.noAssetsType,
    required this.arrayOfTokensHeld,
  });

  factory TransferNoEligibleAssetsEvent.fromJson(Map<String, dynamic> json) {
    final tokensJson = json['arrayOfTokensHeld'];
    final tokens = tokensJson is List
        ? tokensJson
              .map((e) => IneligibleToken.fromJson(e as Map<String, dynamic>))
              .toList()
        : <IneligibleToken>[];

    return TransferNoEligibleAssetsEvent(
      integrationType: json['integrationType'] as String?,
      integrationName: json['integrationName'] as String,
      noAssetsType: json['noAssetsType'] as String?,
      arrayOfTokensHeld: tokens,
    );
  }

  final String? integrationType;
  final String integrationName;
  final String? noAssetsType;
  final List<IneligibleToken> arrayOfTokensHeld;
}

class WalletMessageSignedEvent extends MeshEvent {
  const WalletMessageSignedEvent({
    required this.signedMessageHash,
    required this.message,
    required this.address,
    required this.timeStamp,
    required this.isVerified,
    this.verifiedAddresses,
  });

  factory WalletMessageSignedEvent.fromJson(Map<String, dynamic> json) {
    return WalletMessageSignedEvent(
      signedMessageHash: json['signedMessageHash'] as String?,
      message: json['message'] as String?,
      address: json['address'] as String,
      timeStamp: (json['timeStamp'] as num).toInt(),
      isVerified: json['isVerified'] as bool,
      verifiedAddresses: (json['verifiedAddresses'] as List<dynamic>?)
          ?.whereType<String>()
          .toList(),
    );
  }

  final String? signedMessageHash;
  final String? message;
  final String address;
  final int timeStamp;
  final bool isVerified;
  final List<String>? verifiedAddresses;
}

class ExecuteFundingStepEvent extends MeshEvent {
  const ExecuteFundingStepEvent({
    required this.cryptocurrencyFundingOptionType,
    required this.status,
    this.errorMessage,
  });

  factory ExecuteFundingStepEvent.fromJson(Map<String, dynamic> json) {
    return ExecuteFundingStepEvent(
      cryptocurrencyFundingOptionType:
          json['cryptocurrencyFundingOptionType'] as String,
      status: json['status'] as String,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  final String cryptocurrencyFundingOptionType;
  final String status;
  final String? errorMessage;
}

// ---------------------------------------------------------------------------
// Simple (no-payload) events
// ---------------------------------------------------------------------------

class IntegrationMfaEnteredEvent extends MeshEvent {
  const IntegrationMfaEnteredEvent({this.rawPayload});

  final dynamic rawPayload;
}

class IntegrationOAuthStartedEvent extends MeshEvent {
  const IntegrationOAuthStartedEvent({this.rawPayload});

  final dynamic rawPayload;
}

class IntegrationAccountSelectionRequiredEvent extends MeshEvent {
  const IntegrationAccountSelectionRequiredEvent({this.rawPayload});

  final dynamic rawPayload;
}

class TransferAmountEnteredEvent extends MeshEvent {
  const TransferAmountEnteredEvent({this.rawPayload});

  final dynamic rawPayload;
}

class TransferMfaRequiredEvent extends MeshEvent {
  const TransferMfaRequiredEvent({this.rawPayload});

  final dynamic rawPayload;
}

class TransferMfaEnteredEvent extends MeshEvent {
  const TransferMfaEnteredEvent({this.rawPayload});

  final dynamic rawPayload;
}

class TransferKycRequiredEvent extends MeshEvent {
  const TransferKycRequiredEvent({this.rawPayload});

  final dynamic rawPayload;
}

// ---------------------------------------------------------------------------
// Typed events
// ---------------------------------------------------------------------------

class TransferAssetSelectedEvent extends MeshEvent {
  const TransferAssetSelectedEvent({this.symbol, this.rawPayload});

  final String? symbol;
  final dynamic rawPayload;
}

class TransferNetworkSelectedEvent extends MeshEvent {
  const TransferNetworkSelectedEvent({this.id, this.name, this.rawPayload});

  final String? id;
  final String? name;
  final dynamic rawPayload;
}

class TransferConfigureErrorEvent extends MeshEvent {
  const TransferConfigureErrorEvent({
    this.errorMessage,
    this.requestId,
    this.rawPayload,
  });

  final String? errorMessage;
  final String? requestId;
  final dynamic rawPayload;
}

class ConnectionUnavailableEvent extends MeshEvent {
  const ConnectionUnavailableEvent({
    this.integrationName,
    this.reason,
    this.integrationType,
    this.rawPayload,
  });

  factory ConnectionUnavailableEvent.fromJson(
    Map<String, dynamic> json, {
    dynamic rawPayload,
  }) => ConnectionUnavailableEvent(
    integrationName: json['integrationName'] as String?,
    reason: json['reason'] as String?,
    integrationType: json['integrationType'] as String?,
    rawPayload: rawPayload,
  );

  final String? integrationName;
  final String? reason;
  final String? integrationType;
  final dynamic rawPayload;
}

class ConnectionDeclinedEvent extends MeshEvent {
  const ConnectionDeclinedEvent({
    this.integrationName,
    this.reason,
    this.integrationType,
    this.networkId,
    this.toAddress,
    this.errorMessage,
    this.rawPayload,
  });

  factory ConnectionDeclinedEvent.fromJson(
    Map<String, dynamic> json, {
    dynamic rawPayload,
  }) => ConnectionDeclinedEvent(
    integrationName: json['integrationName'] as String?,
    reason: json['reason'] as String?,
    integrationType: json['integrationType'] as String?,
    networkId: json['networkId'] as String?,
    toAddress: json['toAddress'] as String?,
    errorMessage: json['errorMessage'] as String?,
    rawPayload: rawPayload,
  );

  final String? integrationName;
  final String? reason;
  final String? integrationType;
  final String? networkId;
  final String? toAddress;
  final String? errorMessage;
  final dynamic rawPayload;
}

class TransferDeclinedEvent extends MeshEvent {
  const TransferDeclinedEvent({
    this.integrationName,
    this.status,
    this.integrationType,
    this.toAddress,
    this.token,
    this.network,
    this.amount,
    this.rawPayload,
  });

  factory TransferDeclinedEvent.fromJson(
    Map<String, dynamic> json, {
    dynamic rawPayload,
  }) => TransferDeclinedEvent(
    integrationName: json['integrationName'] as String?,
    status: json['status'] as String?,
    integrationType: json['integrationType'] as String?,
    toAddress: json['toAddress'] as String?,
    token: json['token'] as String?,
    network: json['network'] as String?,
    amount: (json['amount'] as num?)?.toDouble(),
    rawPayload: rawPayload,
  );

  final String? integrationName;
  final String? status;
  final String? integrationType;
  final String? toAddress;
  final String? token;
  final String? network;
  final double? amount;
  final dynamic rawPayload;
}

// ---------------------------------------------------------------------------
// Existing keep-as-is events
// ---------------------------------------------------------------------------

class LinkTransferQrGeneratedEvent extends MeshEvent {
  const LinkTransferQrGeneratedEvent({
    required this.token,
    required this.network,
    required this.toAddress,
    required this.qrUrl,
  });

  factory LinkTransferQrGeneratedEvent.fromJson(Map<String, dynamic> json) {
    return LinkTransferQrGeneratedEvent(
      token: json['token'] as String?,
      network: json['network'] as String?,
      toAddress: json['toAddress'] as String?,
      qrUrl: json['qrUrl'] as String?,
    );
  }

  final String? token;
  final String? network;
  final String? toAddress;
  final String? qrUrl;
}

enum HomePageMethod {
  embedded('embedded'),
  manual('manual'),
  buy('buy');

  const HomePageMethod(this.id);

  final String id;

  static HomePageMethod fromString(String value) {
    return HomePageMethod.values.firstWhere(
      (e) => e.id == value,
      orElse: () {
        logger.warning('Unknown HomePageMethod: $value');
        return HomePageMethod.embedded;
      },
    );
  }
}

class HomePageMethodSelectedEvent extends MeshEvent {
  const HomePageMethodSelectedEvent({required this.method});

  factory HomePageMethodSelectedEvent.fromJson(Map<String, dynamic> json) {
    return HomePageMethodSelectedEvent(
      method: HomePageMethod.fromString(json['method'] as String),
    );
  }

  final HomePageMethod method;
}

// ---------------------------------------------------------------------------
// New events added in this update
// ---------------------------------------------------------------------------

class IntegrationMfaRequiredEvent extends MeshEvent {
  const IntegrationMfaRequiredEvent();
}

class DefiWalletErrorEvent extends MeshEvent {
  const DefiWalletErrorEvent({
    required this.integrationName,
    required this.errorType,
    required this.timeStamp,
    this.requestedAddress,
    this.connectedAddress,
    this.requestedNetwork,
    this.connectedNetwork,
    this.connectUri,
  });

  factory DefiWalletErrorEvent.fromJson(Map<String, dynamic> json) {
    final detailsJson = json['details'];
    final details = detailsJson is Map<String, dynamic>
        ? detailsJson
        : const <String, dynamic>{};
    return DefiWalletErrorEvent(
      integrationName: json['integrationName'] as String,
      errorType: json['errorType'] as String,
      timeStamp: (json['timeStamp'] as num).toInt(),
      requestedAddress: details['requestedAddress'] as String?,
      connectedAddress: details['connectedAddress'] as String?,
      requestedNetwork: details['requestedNetwork'] as String?,
      connectedNetwork: details['connectedNetwork'] as String?,
      connectUri: details['connectUri'] as String?,
    );
  }

  final String integrationName;
  final String errorType;
  final int timeStamp;
  final String? requestedAddress;
  final String? connectedAddress;
  final String? requestedNetwork;
  final String? connectedNetwork;
  final String? connectUri;
}

class HomePageLoadedEvent extends MeshEvent {
  const HomePageLoadedEvent();
}
