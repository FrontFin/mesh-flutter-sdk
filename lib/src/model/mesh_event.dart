import 'package:mesh_sdk/src/model/integration/integration_connected_payload.dart';
import 'package:mesh_sdk/src/model/transfer/ineligible_token.dart';
import 'package:mesh_sdk/src/model/transfer/network_fee.dart';
import 'package:mesh_sdk/src/model/transfer/transfer_executed_status.dart';
import 'package:mesh_sdk/src/model/transfer/transfer_finished_payload.dart';
import 'package:mesh_sdk/src/util/logger.dart';

sealed class MeshEvent {
  const MeshEvent();

  static MeshEvent? fromJson(Map<String, dynamic> json) {
    try {
      final type = json['type'] as String?;
      if (type == null) {
        return null;
      }

      final payload = json['payload'];
      final isPayloadMap = payload is Map<String, dynamic>;

      return switch (json['type']) {
        'integrationSelected' when isPayloadMap => IntegrationSelectedEvent(
          type: payload['integrationType'] as String,
          name: payload['integrationName'] as String,
        ),
        'loaded' => const LoadedEvent(),
        'integrationConnectionError' when isPayloadMap =>
          IntegrationConnectionErrorEvent(
            errorMessage: payload['errorMessage'] as String,
          ),
        'credentialsEntered' => const CredentialsEnteredEvent(),
        'transferStarted' => const TransferStartedEvent(),
        'transferPreviewed' when isPayloadMap =>
          TransferPreviewedEvent.fromJson(payload),
        'transferPreviewError' when isPayloadMap => TransferPreviewErrorEvent(
          errorMessage: payload['errorMessage'] as String,
        ),
        'transferExecutionError' when isPayloadMap =>
          TransferExecutionErrorEvent(
            errorMessage: payload['errorMessage'] as String,
          ),
        'transferInitiated' when isPayloadMap =>
          TransferInitiatedEvent.fromJson(payload),
        'transferExecuted' when isPayloadMap => TransferExecutedEvent.fromJson(
          payload,
        ),
        'transferNoEligibleAssets' when isPayloadMap =>
          TransferNoEligibleAssetsEvent.fromJson(payload),
        'walletMessageSigned' when isPayloadMap =>
          WalletMessageSignedEvent.fromJson(payload),
        'verifyDonePage' => const VerifyDonePageEvent(),
        'verifyWalletRejected' => const VerifyWalletRejectedEvent(),
        'legalTermsViewed' => const LegalTermsViewedEvent(),
        'seeWhatHappenedClicked' => const SeeWhatHappenedClickedEvent(),
        'fundingOptionsUpdated' => const FundingOptionsUpdatedEvent(),
        'fundingOptionsViewed' => const FundingOptionsViewedEvent(),
        'gasIncreaseWarning' => const GasIncreaseWarningEvent(),
        'executeFundingStep' when isPayloadMap =>
          ExecuteFundingStepEvent.fromJson(payload),
        _ => null,
      };
    } catch (e, s) {
      logger.severe('Failed to parse MeshEvent from JSON: $json', e, s);
      return null;
    }
  }
}

class LoadedEvent extends MeshEvent {
  const LoadedEvent();
}

class IntegrationSelectedEvent extends MeshEvent {
  const IntegrationSelectedEvent({required this.type, required this.name});

  final String type;
  final String name;
}

class IntegrationConnectedEvent extends MeshEvent {
  const IntegrationConnectedEvent({required this.payload});

  final IntegrationConnectedPayload payload;
}

class TransferFinishedEvent extends MeshEvent {
  const TransferFinishedEvent({required this.payload});

  final TransferFinishedPayload payload;
}

class IntegrationConnectionErrorEvent extends MeshEvent {
  const IntegrationConnectionErrorEvent({required this.errorMessage});

  final String errorMessage;
}

class CredentialsEnteredEvent extends MeshEvent {
  const CredentialsEnteredEvent();
}

class TransferStartedEvent extends MeshEvent {
  const TransferStartedEvent();
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
  });

  factory TransferPreviewedEvent.fromJson(Map<String, dynamic> json) {
    final feeJson = json['estimatedNetworkGasFee'];

    return TransferPreviewedEvent(
      amount: (json['amount'] as num).toDouble(),
      symbol: json['symbol'] as String,
      toAddress: json['toAddress'] as String,
      networkId: json['networkId'] as String,
      previewId: json['previewId'] as String,
      networkName: json['networkName'] as String?,
      amountInFiat: (json['amountInFiat'] as num?)?.toDouble(),
      estimatedNetworkGasFee: feeJson is Map<String, dynamic>
          ? NetworkFee.fromJson(feeJson)
          : null,
    );
  }

  final double amount;
  final String symbol;
  final String toAddress;
  final String networkId;
  final String previewId;
  final String? networkName;
  final double? amountInFiat;
  final NetworkFee? estimatedNetworkGasFee;
}

class TransferPreviewErrorEvent extends MeshEvent {
  const TransferPreviewErrorEvent({required this.errorMessage});

  final String errorMessage;
}

class TransferExecutionErrorEvent extends MeshEvent {
  const TransferExecutionErrorEvent({required this.errorMessage});

  final String errorMessage;
}

class TransferInitiatedEvent extends MeshEvent {
  const TransferInitiatedEvent({
    required this.integrationName,
    required this.status,
    this.integrationType,
  });

  factory TransferInitiatedEvent.fromJson(Map<String, dynamic> json) {
    return TransferInitiatedEvent(
      integrationName: json['integrationName'] as String,
      status: json['status'] as String,
      integrationType: json['integrationType'] as String?,
    );
  }

  final String integrationName;
  final String status;
  final String? integrationType;
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
    );
  }

  final TransferExecutedStatus status;
  final String txId;
  final String fromAddress;
  final String toAddress;
  final String symbol;
  final double amount;
  final String networkId;
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
  });

  factory WalletMessageSignedEvent.fromJson(Map<String, dynamic> json) {
    return WalletMessageSignedEvent(
      signedMessageHash: json['signedMessageHash'] as String?,
      message: json['message'] as String?,
      address: json['address'] as String,
      timeStamp: json['timeStamp'] as int,
      isVerified: json['isVerified'] as bool,
    );
  }

  final String? signedMessageHash;
  final String? message;
  final String address;
  final int timeStamp;
  final bool isVerified;
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
