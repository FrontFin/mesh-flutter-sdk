import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/model/integration_access_token.dart';

void main() {
  group('IntegrationAccessToken', () {
    test('stores all fields correctly', () {
      const token = IntegrationAccessToken(
        accountId: 'acc-123',
        accountName: 'Test Account',
        accessToken: 'token-abc',
        brokerType: 'coinbase',
        brokerName: 'Coinbase',
      );

      expect(token.accountId, 'acc-123');
      expect(token.accountName, 'Test Account');
      expect(token.accessToken, 'token-abc');
      expect(token.brokerType, 'coinbase');
      expect(token.brokerName, 'Coinbase');
    });

    test('toJson returns correct map', () {
      const token = IntegrationAccessToken(
        accountId: 'acc-456',
        accountName: 'My Account',
        accessToken: 'secret-token',
        brokerType: 'binance',
        brokerName: 'Binance',
      );

      final json = token.toJson();

      expect(json, {
        'accountId': 'acc-456',
        'accountName': 'My Account',
        'accessToken': 'secret-token',
        'brokerType': 'binance',
        'brokerName': 'Binance',
      });
    });
  });
}