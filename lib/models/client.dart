import 'service_card.dart';

class Client {
  final int id;
  final String lastName;
  final String firstName;
  final String email;
  final String phone;
  final String country;
  final ServiceCard? card; // ← связь 1-к-1
  final DateTime? deletedAt;

  const Client({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.email,
    required this.phone,
    required this.country,
    this.card,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
  String get fullName => '$lastName $firstName';

  Client copyWith({
    String? lastName,
    String? firstName,
    String? email,
    String? phone,
    String? country,
    ServiceCard? card,
    bool clearCard = false,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Client(
      id: id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      card: clearCard ? null : (card ?? this.card),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lastName': lastName,
    'firstName': firstName,
    'email': email,
    'phone': phone,
    'country': country,
    'card': card?.toJson(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    id: json['id'] as int? ?? 0,
    lastName: json['lastName'] as String? ?? '',
    firstName: json['firstName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    country: json['country'] as String? ?? '',
    card: json['card'] == null
        ? null
        : ServiceCard.fromJson(json['card'] as Map<String, dynamic>),
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.tryParse(json['deletedAt'] as String),
  );
}
