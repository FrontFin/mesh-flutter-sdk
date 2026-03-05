Flutter package for integrating with Mesh Connect.

## Requirements

- Dart >= 3.9.2
- Flutter >= 3.35.7

## Getting started

To use the Mesh SDK in your Flutter application, add the following dependency to your `pubspec.yaml`
file:

```yaml
dependencies:
  mesh_sdk_flutter: <latest_version>
```

### Localization

Mesh SDK uses the `flutter_localizations` package for localization.

For it to work, you need to add `MeshLocalizations.localizationsDelegates`
to your `MaterialApp.localizationsDelegates`, like so:

```dart
import 'package:mesh_sdk_flutter/mesh_sdk_flutter.dart';

@override
Widget build(BuildContext context) {
  return MaterialApp(
    localizationsDelegates: [
      ...
      MeshLocalizations.localizationsDelegates,
    ],
  );
}
```

### Get Link Token

Link token should be obtained from the POST `/api/v1/linktoken` endpoint.
API reference for this request is
available [here](https://docs.meshconnect.com/api-reference/managed-account-authentication/get-link-token-with-parameters).
The request must be performed from the server side because it requires the client's secret.
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
      onError: (errorType) {
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

See full example app [here](https://github.com/FrontFin/mesh-flutter-sdk/tree/main/example).

## Configuration

Here's what you can configure in the `MeshConfiguration`:

| Parameter                  | Type                                       | Required | description                                                                                                     |
| -------------------------- | ------------------------------------------ | -------- | --------------------------------------------------------------------------------------------------------------- |
| `linkToken`                | `String`                                   | ✅       | Link token obtained from the backend.                                                                           |
| `language`                 | `String`                                   |          | Link UI language. Supported: `"en"`, `"es"`, `"pt"`. Use `"system"` to follow the device locale. Defaults to `"en"`. |
| `displayFiatCurrency`      | `String?`                                  |          | Fiat currency code for displaying amounts in Link UI (e.g. `"USD"`). Passed as `fiatCur` in the link URL.       |
| `theme`                    | `ThemeMode?`                               |          | Link UI theme (`ThemeMode.light`, `ThemeMode.dark`, or `ThemeMode.system`). Passed as `th` in the link URL.     |
| `isDomainWhitelistEnabled` | `bool`                                     |          | If domain should be checked against our whitelist. Defaults to `true`.                                          |
| `integrationAccessTokens`  | `List<IntegrationAccessToken>`             |          | List of cached `IntegrationAccessToken`s that you can pass, so users don't need to connect every time.          |
| `onError`                  | `ValueChanged<MeshErrorType>?`             |          | Error callback with a `MeshErrorType` that describes the error.                                                 |
| `onSuccess`                | `ValueChanged<SuccessPayload>?`            |          | Callback when the Mesh Link completes successfully. See [SuccessPayload] for details (transfer/integration info).  |
| `onEvent`                  | `ValueChanged<MeshEvent>?`                 |          | Callback for when an event is triggered.                                                                        |
| `onIntegrationConnected`   | `ValueChanged<IntegrationConnectedEvent>?` |          | Callback for when an integration is connected. Use this to store the access token.                              |
| `onTransferFinished`       | `ValueChanged<TransferFinishedEvent>?`     |          | Callback for when a crypto transfer is executed.                                                                |

### Whitelist

See the full list of whitelisted
origins [here](https://github.com/FrontFin/mesh-flutter-sdk/blob/main/lib/src/util/constants.dart#L37).

To disable the whitelist check, set `isDomainWhitelistEnabled: false` in the `MeshConfiguration`.

### System language, fiat currency, and theme

To adapt the Link UI to the user's device settings, use:

- **`language: 'system'`** — Uses the device/app locale for the Link UI (same behavior as the Web SDK).
- **`displayFiatCurrency`** — e.g. `'USD'` to show fiat equivalents in the Link UI (sent as `fiatCur` in the link URL).
- **`theme`** — e.g. `ThemeMode.system` to follow device light/dark mode (sent as `th` in the link URL).

These map to the same Link URL parameters (`lng`, `fiatCur`, `th`) as the [Web SDK](https://docs.meshconnect.com/guides/web-sdk).
