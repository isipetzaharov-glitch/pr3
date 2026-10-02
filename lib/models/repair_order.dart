class RepairOrder {
  final int id;
  final String title;
  final String vin;
  final int year;
  final int clientId; // many-to-one
  final int masterId; // many-to-one (было serviceId/publisherId)
  final List<int> serviceIds; // many-to-many (услуги)
  final double cost;
  final String status;
  final DateTime? deletedAt;

  const RepairOrder({
    required this.id,
    required this.title,
    required this.vin,
    required this.year,
    required this.clientId,
    required this.masterId,
    required this.serviceIds,
    required this.cost,
    required this.status,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  RepairOrder copyWith({
    String? title,
    String? vin,
    int? year,
    int? clientId,
    int? masterId,
    List<int>? serviceIds,
    double? cost,
    String? status,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return RepairOrder(
      id: id,
      title: title ?? this.title,
      vin: vin ?? this.vin,
      year: year ?? this.year,
      clientId: clientId ?? this.clientId,
      masterId: masterId ?? this.masterId,
      serviceIds: serviceIds ?? this.serviceIds,
      cost: cost ?? this.cost,
      status: status ?? this.status,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'vin': vin,
    'year': year,
    'clientId': clientId,
    'masterId': masterId,
    'serviceIds': serviceIds,
    'cost': cost,
    'status': status,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory RepairOrder.fromJson(Map<String, dynamic> json) => RepairOrder(
    id: json['id'] as int? ?? 0,
    title: json['title'] as String? ?? '',
    vin: json['vin'] as String? ?? '',
    year: json['year'] as int? ?? 0,
    clientId: json['clientId'] as int? ?? 0,
    masterId: json['masterId'] as int? ?? 0,
    serviceIds: (json['serviceIds'] as List?)?.cast<int>() ?? const [],
    cost: (json['cost'] as num?)?.toDouble() ?? 0,
    status: json['status'] as String? ?? 'new',
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.tryParse(json['deletedAt'] as String),
  );
}
