import 'package:mesh_sdk_flutter/src/model/success/integration.dart';
import 'package:mesh_sdk_flutter/src/model/success/transfer.dart';

class TransferSuccessPayload {
  const TransferSuccessPayload({
    required this.page,
    required this.selectedIntegration,
    required this.transfer,
  });

  factory TransferSuccessPayload.fromJson(Map<String, dynamic> json) {
    return TransferSuccessPayload(
      page: json['page'] as String,
      selectedIntegration: Integration.fromJson(
        json['selectedIntegration'] as Map<String, dynamic>,
      ),
      transfer: Transfer.fromJson(json['transfer'] as Map<String, dynamic>),
    );
  }

  final String page;
  final Integration selectedIntegration;
  final Transfer transfer;
}
