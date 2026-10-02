class Master {
  final int id;
  final String fullName;
  final String specialization;
  final DateTime? deletedAt;

  const Master({
    required this.id,
    required this.fullName,
    required this.specialization,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Master copyWith({
    String? fullName,
    String? specialization,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Master(
      id: id,
      fullName: fullName ?? this.fullName,
      specialization: specialization ?? this.specialization,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'specialization': specialization,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Master.fromJson(Map<String, dynamic> json) => Master(
    id: json['id'] as int? ?? 0,
    fullName: json['fullName'] as String? ?? '',
    specialization: json['specialization'] as String? ?? '',
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.tryParse(json['deletedAt'] as String),
  );
}
