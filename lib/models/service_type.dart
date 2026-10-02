class ServiceType {
  final int id;
  final String name;
  final DateTime? deletedAt;

  const ServiceType({required this.id, required this.name, this.deletedAt});

  bool get isDeleted => deletedAt != null;

  ServiceType copyWith({
    String? name,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return ServiceType(
      id: id,
      name: name ?? this.name,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory ServiceType.fromJson(Map<String, dynamic> json) => ServiceType(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.tryParse(json['deletedAt'] as String),
  );
}
