import 'package:mesh_sdk_flutter/src/model/success/integration.dart';
import 'package:mesh_sdk_flutter/src/model/success/transfer.dart';

sealed class SuccessPayload {
  const SuccessPayload({required this.page, required this.integration});

  final String page;
  final Integration integration;
}

class IntegrationSuccessPayload extends SuccessPayload {
  const IntegrationSuccessPayload({
    required super.page,
    required super.integration,
  });

  factory IntegrationSuccessPayload.fromJson(Map<String, dynamic> json) {
    return IntegrationSuccessPayload(
      page: json['page'] as String,
      integration: Integration.fromJson(
        json['selectedIntegration'] as Map<String, dynamic>,
      ),
    );
  }
}

class TransferSuccessPayload extends SuccessPayload {
  const TransferSuccessPayload({
    required super.page,
    required super.integration,
    required this.transfer,
  });

  factory TransferSuccessPayload.fromJson(Map<String, dynamic> json) {
    return TransferSuccessPayload(
      page: json['page'] as String,
      integration: Integration.fromJson(
        json['selectedIntegration'] as Map<String, dynamic>,
      ),
      transfer: Transfer.fromJson(json['transfer'] as Map<String, dynamic>),
    );
  }

  final Transfer transfer;
}
