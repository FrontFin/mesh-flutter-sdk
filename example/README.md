# Mesh SDK Flutter Example App

Example app using Mesh Flutter SDK.

## Getting Started

This example app contains the minimum setup required to show the Mesh Link page.

Run the app, then:

1. Enter your Mesh Link Token.
2. Tap `Start` button.

And the Mesh Link page will be displayed.

## Code Example

The important part of the code is the `_showMeshLinkPage` function,
which shows how to pass params to Mesh Link and parse the result:

```dart
Future<void> _showMeshLinkPage(String linkToken) async {
  final result = await MeshSdk.show(
    context,
    configuration: MeshConfiguration(
      language: 'en',
      integrationAccessTokens: const [
        IntegrationAccessToken(
          accessToken: 'token',
          accountId: 'id',
          accountName: 'name',
          brokerName: 'broker',
          brokerType: 'type',
        ),
      ],
      linkToken: linkToken,
      onEvent: (event) {
        print('Mesh event: $event');
      },
      onError: (errorType) {
        print('Mesh exit: $errorType');
      },
      onSuccess: (payload) {
        print('Mesh success: ${payload.integration.name}');
      },
      onIntegrationConnected: (integration) {
        print('Integration connected: $integration');
      },
      onTransferFinished: (transfer) {
        print('Transfer finished: $transfer');
      },
    ),
  );

  // Handle the result
  switch (result) {
    case MeshSuccess():
      print('Mesh link finished successfully');
    case MeshError():
      print('Mesh link error: ${result.type}');
  }

  // Alternatively, use `when` method
  result.when(
    success: (success) {
      final payload = success.payload;
      print('Mesh link success: ${payload.integration.name}');
    },
    error: (error) {
      final errorType = error.type;
      print('Mesh link error: $errorType');
    },
  );
}
```
