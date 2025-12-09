import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/mesh_sdk_flutter.dart';

void main() {
  group('MeshEvent.fromJson', () {
    group('Simple events (no payload)', () {
      test('parses LoadedEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'loaded',
          'payload': <String, dynamic>{},
        });
        expect(event, isA<LoadedEvent>());
      });

      test('parses CredentialsEnteredEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'credentialsEntered',
          'payload': <String, dynamic>{},
        });
        expect(event, isA<CredentialsEnteredEvent>());
      });

      test('parses TransferStartedEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'transferStarted',
          'payload': <String, dynamic>{},
        });
        expect(event, isA<TransferStartedEvent>());
      });

      test('parses VerifyDonePageEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'verifyDonePage',
          'payload': <String, dynamic>{},
        });
        expect(event, isA<VerifyDonePageEvent>());
      });

      test('parses VerifyWalletRejectedEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'verifyWalletRejected',
          'payload': <String, dynamic>{},
        });
        expect(event, isA<VerifyWalletRejectedEvent>());
      });

      test('parses LegalTermsViewedEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'legalTermsViewed',
          'payload': <String, dynamic>{},
        });
        expect(event, isA<LegalTermsViewedEvent>());
      });

      test('parses SeeWhatHappenedClickedEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'seeWhatHappenedClicked',
          'payload': <String, dynamic>{},
        });
        expect(event, isA<SeeWhatHappenedClickedEvent>());
      });

      test('parses FundingOptionsUpdatedEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'fundingOptionsUpdated',
          'payload': <String, dynamic>{},
        });
        expect(event, isA<FundingOptionsUpdatedEvent>());
      });

      test('parses FundingOptionsViewedEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'fundingOptionsViewed',
          'payload': <String, dynamic>{},
        });
        expect(event, isA<FundingOptionsViewedEvent>());
      });

      test('parses GasIncreaseWarningEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'gasIncreaseWarning',
          'payload': <String, dynamic>{},
        });
        expect(event, isA<GasIncreaseWarningEvent>());
      });
    });

    group('Events with structured payload', () {
      test('parses IntegrationSelectedEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'integrationSelected',
          'payload': {
            'integrationType': 'robinhood',
            'integrationName': 'Robinhood',
          },
        });

        expect(event, isA<IntegrationSelectedEvent>());
        final selected = event! as IntegrationSelectedEvent;
        expect(selected.type, 'robinhood');
        expect(selected.name, 'Robinhood');
      });

      test('parses IntegrationConnectionErrorEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'integrationConnectionError',
          'payload': {'errorMessage': 'Invalid credentials'},
        });

        expect(event, isA<IntegrationConnectionErrorEvent>());
        final error = event! as IntegrationConnectionErrorEvent;
        expect(error.errorMessage, 'Invalid credentials');
      });

      test('parses TransferPreviewedEvent with all fields', () {
        final event = MeshEvent.fromJson({
          'type': 'transferPreviewed',
          'payload': {
            'amount': 100.5,
            'symbol': 'ETH',
            'toAddress': '0x123abc',
            'networkId': 'ethereum',
            'previewId': 'preview-123',
            'networkName': 'Ethereum Mainnet',
            'amountInFiat': 250.75,
            'estimatedNetworkGasFee': {
              'fee': 0.005,
              'feeCurrency': 'ETH',
              'feeInFiat': 12.5,
            },
          },
        });

        expect(event, isA<TransferPreviewedEvent>());
        final preview = event! as TransferPreviewedEvent;
        expect(preview.amount, 100.5);
        expect(preview.symbol, 'ETH');
        expect(preview.toAddress, '0x123abc');
        expect(preview.networkId, 'ethereum');
        expect(preview.previewId, 'preview-123');
        expect(preview.networkName, 'Ethereum Mainnet');
        expect(preview.amountInFiat, 250.75);
        expect(preview.estimatedNetworkGasFee?.fee, 0.005);
        expect(preview.estimatedNetworkGasFee?.feeCurrency, 'ETH');
        expect(preview.estimatedNetworkGasFee?.feeInFiat, 12.5);
      });

      test('parses TransferPreviewedEvent with minimal fields', () {
        final event = MeshEvent.fromJson({
          'type': 'transferPreviewed',
          'payload': {
            'amount': 50,
            'symbol': 'BTC',
            'toAddress': 'bc1q...',
            'networkId': 'bitcoin',
            'previewId': 'preview-456',
          },
        });

        expect(event, isA<TransferPreviewedEvent>());
        final preview = event! as TransferPreviewedEvent;
        expect(preview.amount, 50.0);
        expect(preview.networkName, isNull);
        expect(preview.amountInFiat, isNull);
        expect(preview.estimatedNetworkGasFee, isNull);
      });

      test('parses TransferPreviewErrorEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'transferPreviewError',
          'payload': {'errorMessage': 'Insufficient balance'},
        });

        expect(event, isA<TransferPreviewErrorEvent>());
        expect(
          (event! as TransferPreviewErrorEvent).errorMessage,
          'Insufficient balance',
        );
      });

      test('parses TransferExecutionErrorEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'transferExecutionError',
          'payload': {'errorMessage': 'Transaction failed'},
        });

        expect(event, isA<TransferExecutionErrorEvent>());
        expect(
          (event! as TransferExecutionErrorEvent).errorMessage,
          'Transaction failed',
        );
      });

      test('parses TransferInitiatedEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'transferInitiated',
          'payload': {
            'integrationName': 'Coinbase',
            'status': 'pending',
            'integrationType': 'exchange',
          },
        });

        expect(event, isA<TransferInitiatedEvent>());
        final initiated = event! as TransferInitiatedEvent;
        expect(initiated.integrationName, 'Coinbase');
        expect(initiated.status, 'pending');
        expect(initiated.integrationType, 'exchange');
      });

      test('parses TransferExecutedEvent with pending status', () {
        final event = MeshEvent.fromJson({
          'type': 'transferExecuted',
          'payload': {
            'status': 'pending',
            'txId': 'tx-123',
            'fromAddress': '0xfrom',
            'toAddress': '0xto',
            'symbol': 'USDC',
            'amount': 1000,
            'networkId': 'polygon',
          },
        });

        expect(event, isA<TransferExecutedEvent>());
        final executed = event! as TransferExecutedEvent;
        expect(executed.status, TransferExecutedStatus.pending);
        expect(executed.txId, 'tx-123');
        expect(executed.fromAddress, '0xfrom');
        expect(executed.toAddress, '0xto');
        expect(executed.symbol, 'USDC');
        expect(executed.amount, 1000.0);
        expect(executed.networkId, 'polygon');
      });

      test('parses TransferExecutedEvent with success status', () {
        final event = MeshEvent.fromJson({
          'type': 'transferExecuted',
          'payload': {
            'status': 'success',
            'txId': 'tx-456',
            'fromAddress': '0xfrom',
            'toAddress': '0xto',
            'symbol': 'ETH',
            'amount': 0.5,
            'networkId': 'ethereum',
          },
        });

        expect(event, isA<TransferExecutedEvent>());
        expect(
          (event! as TransferExecutedEvent).status,
          TransferExecutedStatus.success,
        );
      });

      test('parses TransferNoEligibleAssetsEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'transferNoEligibleAssets',
          'payload': {
            'integrationName': 'Binance',
            'integrationType': 'exchange',
            'noAssetsType': 'insufficient_balance',
            'arrayOfTokensHeld': [
              {
                'symbol': 'BTC',
                'amount': 0.001,
                'amountInFiat': 50.0,
                'ineligibilityReason': 'Below minimum',
              },
            ],
          },
        });

        expect(event, isA<TransferNoEligibleAssetsEvent>());
        final noAssets = event! as TransferNoEligibleAssetsEvent;
        expect(noAssets.integrationName, 'Binance');
        expect(noAssets.integrationType, 'exchange');
        expect(noAssets.noAssetsType, 'insufficient_balance');
        expect(noAssets.arrayOfTokensHeld, hasLength(1));
        expect(noAssets.arrayOfTokensHeld.first.symbol, 'BTC');
        expect(noAssets.arrayOfTokensHeld.first.amount, 0.001);
      });

      test('parses WalletMessageSignedEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'walletMessageSigned',
          'payload': {
            'signedMessageHash': '0xhash123',
            'message': 'Sign this message',
            'address': '0xwallet',
            'timeStamp': 1699999999,
            'isVerified': true,
          },
        });

        expect(event, isA<WalletMessageSignedEvent>());
        final signed = event! as WalletMessageSignedEvent;
        expect(signed.signedMessageHash, '0xhash123');
        expect(signed.message, 'Sign this message');
        expect(signed.address, '0xwallet');
        expect(signed.timeStamp, 1699999999);
        expect(signed.isVerified, true);
      });

      test('parses ExecuteFundingStepEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'executeFundingStep',
          'payload': {
            'cryptocurrencyFundingOptionType': 'card',
            'status': 'completed',
            'errorMessage': null,
          },
        });

        expect(event, isA<ExecuteFundingStepEvent>());
        final funding = event! as ExecuteFundingStepEvent;
        expect(funding.cryptocurrencyFundingOptionType, 'card');
        expect(funding.status, 'completed');
        expect(funding.errorMessage, isNull);
      });

      test('parses LinkTransferQrGeneratedEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'linkTransferQRGenerated',
          'payload': {
            'token': 'USDC',
            'network': 'ethereum',
            'toAddress': '0xrecipient',
            'qrUrl': 'https://qr.example.com/123',
          },
        });

        expect(event, isA<LinkTransferQrGeneratedEvent>());
        final qr = event! as LinkTransferQrGeneratedEvent;
        expect(qr.token, 'USDC');
        expect(qr.network, 'ethereum');
        expect(qr.toAddress, '0xrecipient');
        expect(qr.qrUrl, 'https://qr.example.com/123');
      });
    });

    group('HomePageMethodSelectedEvent', () {
      test('parses with embedded method', () {
        final event = MeshEvent.fromJson({
          'type': 'methodSelected',
          'payload': {'method': 'embedded'},
        });

        expect(event, isA<HomePageMethodSelectedEvent>());
        expect(
          (event! as HomePageMethodSelectedEvent).method,
          HomePageMethod.embedded,
        );
      });

      test('parses with manual method', () {
        final event = MeshEvent.fromJson({
          'type': 'methodSelected',
          'payload': {'method': 'manual'},
        });

        expect(event, isA<HomePageMethodSelectedEvent>());
        expect(
          (event! as HomePageMethodSelectedEvent).method,
          HomePageMethod.manual,
        );
      });

      test('parses with buy method', () {
        final event = MeshEvent.fromJson({
          'type': 'methodSelected',
          'payload': {'method': 'buy'},
        });

        expect(event, isA<HomePageMethodSelectedEvent>());
        expect(
          (event! as HomePageMethodSelectedEvent).method,
          HomePageMethod.buy,
        );
      });

      test('defaults to embedded for unknown method', () {
        final event = MeshEvent.fromJson({
          'type': 'methodSelected',
          'payload': {'method': 'unknown_method'},
        });

        expect(event, isA<HomePageMethodSelectedEvent>());
        expect(
          (event! as HomePageMethodSelectedEvent).method,
          HomePageMethod.embedded,
        );
      });
    });

    group('Raw payload events', () {
      test('parses IntegrationMfaEnteredEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'integrationMfaEntered',
          'payload': {'mfaCode': '123456'},
        });

        expect(event, isA<IntegrationMfaEnteredEvent>());
        expect((event! as IntegrationMfaEnteredEvent).rawPayload, {
          'mfaCode': '123456',
        });
      });

      test('parses IntegrationOAuthStartedEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'integrationOAuthStarted',
          'payload': {'provider': 'google'},
        });

        expect(event, isA<IntegrationOAuthStartedEvent>());
      });

      test('parses ConnectionDeclinedEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'connectionDeclined',
          'payload': {'reason': 'user_cancelled'},
        });

        expect(event, isA<ConnectionDeclinedEvent>());
      });

      test('parses TransferDeclinedEvent', () {
        final event = MeshEvent.fromJson({
          'type': 'transferDeclined',
          'payload': null,
        });

        expect(event, isA<TransferDeclinedEvent>());
      });
    });

    group('Error handling', () {
      test('returns null for unknown event type', () {
        final event = MeshEvent.fromJson({
          'type': 'unknownEventType',
          'payload': <String, dynamic>{},
        });
        expect(event, isNull);
      });

      test('returns null when type is missing', () {
        final event = MeshEvent.fromJson({'payload': <String, dynamic>{}});
        expect(event, isNull);
      });

      test('returns null when type is null', () {
        final event = MeshEvent.fromJson({
          'type': null,
          'payload': <String, dynamic>{},
        });
        expect(event, isNull);
      });

      test('returns null for malformed payload', () {
        // TransferPreviewed requires specific fields
        final event = MeshEvent.fromJson({
          'type': 'transferPreviewed',
          'payload': {'invalid': 'data'},
        });
        expect(event, isNull);
      });
    });
  });
}
