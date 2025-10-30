Flutter package for integrating with Mesh Connect.

## Requirements

- Dart >= 3.9.2
- Flutter >= 3.35.7

## Getting started

To use the Mesh SDK in your Flutter application, add the following dependency to your `pubspec.yaml`
file:

```yaml
dependencies:
  mesh_sdk: <latest_version>
```

### Get Link Token

Link token should be obtained from the POST `/api/v1/linktoken` endpoint.
API reference for this request is
available [here](https://docs.meshconnect.com/reference/post_api-v1-linktoken). The request must be
performed from the server side because it requires the client's secret.
You will get the response in the following format:

```json
{
  "content": {
    "linkToken": "{linkToken}"
  },
  "status": "ok",
  "message": ""
}
```

### Usage

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
      onExit: (errorType) {
        print('Mesh exit: $errorType');
      },
      onIntegrationConnected: (integration) {
        print('Integration connected: $integration');
      },
      onTransferFinished: (transfer) {
        print('Transfer finished: $transfer');
      },
    ),
  );

  switch (result) {
    case MeshSuccess():
      print('Mesh link finished successfully');
    case MeshError():
      print('Mesh link error: ${result.type}');
  }
}
```

See full example [here](https://github.com/FrontFin/mesh-flutter-sdk/tree/main/example).

## Configuration

Here's what you can configure in the `MeshConfiguration`:

| Parameter                  | Type                                       | Required | description                                                                                            |
|----------------------------|--------------------------------------------|----------|--------------------------------------------------------------------------------------------------------|
| `linkToken`                | `String`                                   | ✅        | Link token obtained from the backend.                                                                  |
| `language`                 | `String`                                   |          | Language, defaults to "en".                                                                            |
| `isDomainWhitelistEnabled` | `bool`                                     |          | If domain should be checked against our whitelist. Defaults to `true`.                                 |
| `integrationAccessTokens`  | `List<IntegrationAccessToken>`             |          | List of cached `IntegrationAccessToken`s that you can pass, so users don't need to connect every time. |
| `onExit`                   | `ValueChanged<MeshErrorType>?`             |          | Exit callback with a `MeshErrorType` that describes the error.                                         |
| `onEvent`                  | `ValueChanged<MeshEvent>?`                 |          | Callback for when an event is triggered.                                                               |
| `onIntegrationConnected`   | `ValueChanged<IntegrationConnectedEvent>?` |          | Callback for when an integration is connected. Use this to store the access token.                     |
| `onTransferFinished`       | `ValueChanged<TransferFinishedEvent>?`     |          | Callback for when a crypto transfer is executed.                                                       |

See the full list of whitelisted
origins [here](https://github.com/FrontFin/mesh-flutter-sdk/blob/main/lib/src/util/constants.dart#L37).
