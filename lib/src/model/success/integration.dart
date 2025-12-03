class Integration {
  const Integration({required this.id, required this.name});

  factory Integration.fromJson(Map<String, dynamic> json) {
    return Integration(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }

  final String? id;
  final String? name;
}
