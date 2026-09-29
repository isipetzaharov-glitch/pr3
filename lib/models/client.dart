class Client {
  final int id;
  final String lastName;
  final String firstName;
  final String phone;
  final String country;
  final DateTime? deletedAt;

  const Client({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.phone,
    required this.country,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  String get fullName => '$lastName $firstName';

  Client copyWith({
    String? lastName,
    String? firstName,
    String? phone,
    String? country,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Client(
      id: id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      // Тот же приём, что в методичке: отличаем «не менять» от «сбросить в null»
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
