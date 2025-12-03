import 'package:mesh_sdk_flutter/src/model/success/integration.dart';
import 'package:mesh_sdk_flutter/src/model/success/transfer.dart';

sealed class SuccessPayload {
  const SuccessPayload({required this.page});

  factory SuccessPayload.fromJson(Map<String, dynamic> json) {
    final page = json['page'] as String;
    final integrationJson = json['selectedIntegration'];
    final transferJson = json['transfer'];

    if (integrationJson is Map<String, dynamic>) {
      if (transferJson is Map<String, dynamic>) {
        return TransferSuccessPayload(
          page: page,
          integration: Integration.fromJson(integrationJson),
          transfer: Transfer.fromJson(transferJson),
        );
      }
      return IntegrationSuccessPayload(
        page: page,
        integration: Integration.fromJson(integrationJson),
      );
    }

    return BaseSuccessPayload(page: page);
  }

  final String page;
}

class BaseSuccessPayload extends SuccessPayload {
  const BaseSuccessPayload({required super.page});
}

class IntegrationSuccessPayload extends SuccessPayload {
  const IntegrationSuccessPayload({
    required super.page,
    required this.integration,
  });

  final Integration integration;
}

class TransferSuccessPayload extends IntegrationSuccessPayload {
  const TransferSuccessPayload({
    required super.page,
    required super.integration,
    required this.transfer,
  });

  final Transfer transfer;
}
