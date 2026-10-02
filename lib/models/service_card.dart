class ServiceCard {
  final String number;
  final DateTime issuedAt;
  final String discountCategory; // обычный / серебро / золото

  const ServiceCard({
    required this.number,
    required this.issuedAt,
    required this.discountCategory,
  });

  ServiceCard copyWith({
    String? number,
    DateTime? issuedAt,
    String? discountCategory,
  }) {
    return ServiceCard(
      number: number ?? this.number,
      issuedAt: issuedAt ?? this.issuedAt,
      discountCategory: discountCategory ?? this.discountCategory,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'issuedAt': issuedAt.toIso8601String(),
    'discountCategory': discountCategory,
  };

  factory ServiceCard.fromJson(Map<String, dynamic> json) => ServiceCard(
    number: json['number'] as String? ?? '',
    issuedAt:
        DateTime.tryParse(json['issuedAt'] as String? ?? '') ?? DateTime.now(),
    discountCategory: json['discountCategory'] as String? ?? 'обычный',
  );
}
