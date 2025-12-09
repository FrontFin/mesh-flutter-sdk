import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/mesh_sdk_flutter.dart';
import 'package:mesh_sdk_flutter/src/model/mesh_internal_event.dart';

void main() {
  group('MeshInternalEvent.fromJson', () {
    group('ShowClose', () {
      test('parses showClose event', () {
        final event = MeshInternalEvent.fromJson({
          'type': 'showClose',
          'payload': null,
        });

        expect(event, isA<ShowClose>());
      });
    });

    group('ShowNativeNavBar', () {
      test('parses with show=true', () {
        final event = MeshInternalEvent.fromJson({
          'type': 'showNativeNavbar',
          'payload': true,
        });

        expect(event, isA<ShowNativeNavBar>());
        expect((event! as ShowNativeNavBar).show, true);
      });

      test('parses with show=false', () {
        final event = MeshInternalEvent.fromJson({
          'type': 'showNativeNavbar',
          'payload': false,
        });

        expect(event, isA<ShowNativeNavBar>());
        expect((event! as ShowNativeNavBar).show, false);
      });

      test('returns null when payload is not bool', () {
        final event = MeshInternalEvent.fromJson({
          'type': 'showNativeNavbar',
          'payload': 'invalid',
        });

        expect(event, isNull);
      });
    });

    group('IntegrationConnected (delayedAuthentication)', () {
      test('parses DelayedAuthPayload', () {
        final event = MeshInternalEvent.fromJson({
          'type': 'delayedAuthentication',
          'payload': {
            'brokerType': 'robinhood',
            'refreshToken': 'refresh-token-123',
            'brokerName': 'Robinhood',
            'brokerBrandInfo': {
              'brokerLogo': 'https://logo.url',
              'brokerPrimaryColor': '#00FF00',
            },
            'refreshTokenExpiresInSeconds': 3600,
          },
        });

        expect(event, isA<IntegrationConnected>());
        final connected = event! as IntegrationConnected;
        expect(connected.payload, isA<DelayedAuthPayload>());

        final payload = connected.payload as DelayedAuthPayload;
        expect(payload.brokerType, 'robinhood');
        expect(payload.refreshToken, 'refresh-token-123');
        expect(payload.brokerName, 'Robinhood');
        expect(payload.refreshTokenExpiresInSeconds, 3600);
        expect(payload.brokerBrandInfo.brokerLogo, 'https://logo.url');
        expect(payload.brokerBrandInfo.brokerPrimaryColor, '#00FF00');
      });
    });

    group('IntegrationConnected (brokerageAccountAccessToken)', () {
      test('parses AccessTokenPayload', () {
        final event = MeshInternalEvent.fromJson({
          'type': 'brokerageAccountAccessToken',
          'payload': {
            'accountTokens': [
              {
                'account': {
                  'accountId': 'acc-123',
                  'accountName': 'Main Account',
                  'fund': 1000.0,
                  'cash': 500.0,
                  'isReconnected': false,
                },
                'accessToken': 'access-token-xyz',
                'refreshToken': 'refresh-token-abc',
              },
            ],
            'brokerBrandInfo': {
              'brokerLogo': 'https://brand.logo',
              'logoLightUrl': 'https://light.logo',
              'logoDarkUrl': 'https://dark.logo',
            },
            'expiresInSeconds': 7200,
            'refreshTokenExpiresInSeconds': 86400,
            'brokerType': 'coinbase',
            'brokerName': 'Coinbase',
          },
        });

        expect(event, isA<IntegrationConnected>());
        final connected = event! as IntegrationConnected;
        expect(connected.payload, isA<AccessTokenPayload>());

        final payload = connected.payload as AccessTokenPayload;
        expect(payload.brokerType, 'coinbase');
        expect(payload.brokerName, 'Coinbase');
        expect(payload.expiresInSeconds, 7200);
        expect(payload.refreshTokenExpiresInSeconds, 86400);
        expect(payload.accountTokens, hasLength(1));

        final accountToken = payload.accountTokens.first;
        expect(accountToken.accessToken, 'access-token-xyz');
        expect(accountToken.refreshToken, 'refresh-token-abc');
        expect(accountToken.account.accountId, 'acc-123');
        expect(accountToken.account.accountName, 'Main Account');
        expect(accountToken.account.fund, 1000.0);
        expect(accountToken.account.cash, 500.0);
        expect(accountToken.account.isReconnected, false);
      });

      test('parses AccessTokenPayload with multiple accounts', () {
        final event = MeshInternalEvent.fromJson({
          'type': 'brokerageAccountAccessToken',
          'payload': {
            'accountTokens': [
              {
                'account': {'accountId': 'acc-1', 'accountName': 'Account 1'},
                'accessToken': 'token-1',
              },
              {
                'account': {'accountId': 'acc-2', 'accountName': 'Account 2'},
                'accessToken': 'token-2',
              },
            ],
            'brokerBrandInfo': {'brokerLogo': null},
            'brokerType': 'binance',
            'brokerName': 'Binance',
          },
        });

        expect(event, isA<IntegrationConnected>());
        final connected = event! as IntegrationConnected;
        final payload = connected.payload as AccessTokenPayload;
        expect(payload.accountTokens, hasLength(2));
        expect(payload.accountTokens[0].account.accountId, 'acc-1');
        expect(payload.accountTokens[1].account.accountId, 'acc-2');
      });
    });

    group('TransferFinished', () {
      test('parses TransferFinishedSuccessPayload', () {
        final event = MeshInternalEvent.fromJson({
          'type': 'transferFinished',
          'payload': {
            'status': 'success',
            'txId': 'tx-success-123',
            'fromAddress': '0xfrom',
            'toAddress': '0xto',
            'symbol': 'ETH',
            'amount': 1.5,
            'networkId': 'ethereum',
            'amountInFiat': 4500.0,
            'totalAmountInFiat': 4510.0,
            'networkName': 'Ethereum Mainnet',
            'txHash': '0xhash123',
            'transferId': 'transfer-abc',
            'refundAddress': '0xrefund',
          },
        });

        expect(event, isA<TransferFinished>());
        final finished = event! as TransferFinished;
        expect(finished.payload, isA<TransferFinishedSuccessPayload>());

        final payload = finished.payload as TransferFinishedSuccessPayload;
        expect(payload.txId, 'tx-success-123');
        expect(payload.fromAddress, '0xfrom');
        expect(payload.toAddress, '0xto');
        expect(payload.symbol, 'ETH');
        expect(payload.amount, 1.5);
        expect(payload.networkId, 'ethereum');
        expect(payload.amountInFiat, 4500.0);
        expect(payload.totalAmountInFiat, 4510.0);
        expect(payload.networkName, 'Ethereum Mainnet');
        expect(payload.txHash, '0xhash123');
        expect(payload.transferId, 'transfer-abc');
        expect(payload.refundAddress, '0xrefund');
      });

      test('parses TransferFinishedErrorPayload', () {
        final event = MeshInternalEvent.fromJson({
          'type': 'transferFinished',
          'payload': {
            'status': 'error',
            'errorMessage': 'Transfer failed: insufficient funds',
          },
        });

        expect(event, isA<TransferFinished>());
        final finished = event! as TransferFinished;
        expect(finished.payload, isA<TransferFinishedErrorPayload>());

        final payload = finished.payload as TransferFinishedErrorPayload;
        expect(payload.errorMessage, 'Transfer failed: insufficient funds');
      });
    });

    group('Error handling', () {
      test('returns null for unknown type', () {
        final event = MeshInternalEvent.fromJson({
          'type': 'unknownInternalEvent',
          'payload': <String, dynamic>{},
        });

        expect(event, isNull);
      });

      test('returns null when type is missing', () {
        final event = MeshInternalEvent.fromJson({
          'payload': <String, dynamic>{},
        });

        expect(event, isNull);
      });

      test('returns null when type is null', () {
        final event = MeshInternalEvent.fromJson({
          'type': null,
          'payload': <String, dynamic>{},
        });

        expect(event, isNull);
      });

      test('returns null for malformed payload', () {
        final event = MeshInternalEvent.fromJson({
          'type': 'delayedAuthentication',
          'payload': 'not a map',
        });

        expect(event, isNull);
      });
    });
  });
}
