enum TransferExecutedStatus {
  pending('pending'),
  success('success');

  const TransferExecutedStatus(this.id);

  final String id;

  static TransferExecutedStatus fromString(String status) {
    return TransferExecutedStatus.values.firstWhere(
      (e) => e.id == status,
      orElse: () => throw ArgumentError('Invalid status: $status'),
    );
  }
}
