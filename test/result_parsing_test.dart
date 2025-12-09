import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/mesh_sdk_flutter.dart';

void main() {
  group('MeshResult.fromJson', () {
    group('Success results (done)', () {
      test('parses BaseSuccessPayload (page only)', () {
        final result = MeshResult.fromJson({
          'type': 'done',
          'payload': {'page': 'done'},
        });

        expect(result, isA<MeshSuccess>());
        final success = result! as MeshSuccess;
        expect(success.payload, isA<BaseSuccessPayload>());
        expect(success.payload.page, 'done');
      });

      test('parses IntegrationSuccessPayload', () {
        final result = MeshResult.fromJson({
          'type': 'done',
          'payload': {
            'page': 'integrationConnected',
            'selectedIntegration': {
              'id': 'integration-123',
              'name': 'Robinhood',
            },
          },
        });

        expect(result, isA<MeshSuccess>());
        final success = result! as MeshSuccess;
        expect(success.payload, isA<IntegrationSuccessPayload>());

        final payload = success.payload as IntegrationSuccessPayload;
        expect(payload.page, 'integrationConnected');
        expect(payload.integration.id, 'integration-123');
        expect(payload.integration.name, 'Robinhood');
      });

      test('parses TransferSuccessPayload', () {
        final result = MeshResult.fromJson({
          'type': 'done',
          'payload': {
            'page': 'transferComplete',
            'selectedIntegration': {
              'id': 'integration-456',
              'name': 'Coinbase',
            },
            'transfer': {
              'amount': 100.5,
              'amountInFiat': 250.75,
              'symbol': 'ETH',
              'transactionId': 'tx-abc123',
              'networkId': 'ethereum',
              'previewId': 'preview-xyz',
            },
          },
        });

        expect(result, isA<MeshSuccess>());
        final success = result! as MeshSuccess;
        expect(success.payload, isA<TransferSuccessPayload>());

        final payload = success.payload as TransferSuccessPayload;
        expect(payload.page, 'transferComplete');
        expect(payload.integration.id, 'integration-456');
        expect(payload.integration.name, 'Coinbase');
        expect(payload.transfer.amount, 100.5);
        expect(payload.transfer.amountInFiat, 250.75);
        expect(payload.transfer.symbol, 'ETH');
        expect(payload.transfer.transactionId, 'tx-abc123');
        expect(payload.transfer.networkId, 'ethereum');
        expect(payload.transfer.previewId, 'preview-xyz');
      });

      test('parses TransferSuccessPayload with minimal transfer data', () {
        final result = MeshResult.fromJson({
          'type': 'done',
          'payload': {
            'page': 'transferComplete',
            'selectedIntegration': {'id': null, 'name': null},
            'transfer': {'amount': null},
          },
        });

        expect(result, isA<MeshSuccess>());
        final success = result! as MeshSuccess;
        expect(success.payload, isA<TransferSuccessPayload>());

        final payload = success.payload as TransferSuccessPayload;
        expect(payload.integration.id, isNull);
        expect(payload.integration.name, isNull);
        expect(payload.transfer.amount, isNull);
        expect(payload.transfer.symbol, isNull);
      });
    });

    group('Close results', () {
      test('parses close with payload as success', () {
        final result = MeshResult.fromJson({
          'type': 'close',
          'payload': {'page': 'closed'},
        });

        expect(result, isA<MeshSuccess>());
        final success = result! as MeshSuccess;
        expect(success.payload.page, 'closed');
      });
    });

    group('Error handling', () {
      test('returns null for unknown type', () {
        final result = MeshResult.fromJson({
          'type': 'unknownType',
          'payload': <String, dynamic>{},
        });

        expect(result, isNull);
      });

      test('returns null when payload is not a map', () {
        final result = MeshResult.fromJson({
          'type': 'done',
          'payload': 'invalid',
        });

        expect(result, isNull);
      });

      test('returns null when payload is missing', () {
        final result = MeshResult.fromJson({'type': 'done'});

        expect(result, isNull);
      });
    });

    group('when() pattern matching', () {
      test('calls success handler for MeshSuccess', () {
        const result = MeshSuccess(payload: BaseSuccessPayload(page: 'test'));

        String? handlerCalled;
        result.when(
          success: (s) => handlerCalled = 'success: ${s.payload.page}',
          error: (e) => handlerCalled = 'error',
        );

        expect(handlerCalled, 'success: test');
      });

      test('calls error handler for MeshError', () {
        const result = MeshError(MeshErrorType.userCancelled);

        String? handlerCalled;
        result.when(
          success: (s) => handlerCalled = 'success',
          error: (e) => handlerCalled = 'error: ${e.type}',
        );

        expect(handlerCalled, 'error: MeshErrorType.userCancelled');
      });
    });
  });

  group('SuccessPayload.fromJson', () {
    test('creates BaseSuccessPayload when no integration', () {
      final payload = SuccessPayload.fromJson({'page': 'test'});
      expect(payload, isA<BaseSuccessPayload>());
    });

    test('creates IntegrationSuccessPayload when integration present', () {
      final payload = SuccessPayload.fromJson({
        'page': 'test',
        'selectedIntegration': {'id': '1', 'name': 'Test'},
      });
      expect(payload, isA<IntegrationSuccessPayload>());
    });

    test('creates TransferSuccessPayload when transfer present', () {
      final payload = SuccessPayload.fromJson({
        'page': 'test',
        'selectedIntegration': {'id': '1', 'name': 'Test'},
        'transfer': {'amount': 50.0},
      });
      expect(payload, isA<TransferSuccessPayload>());
    });
  });
}
