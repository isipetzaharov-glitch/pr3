class RepairOrder {
  final int id;
  final String title; // напр. "Замена масла Toyota Camry"
  final String vin; // аналог ISBN — уникальный идентификатор авто
  final int year; // год выпуска авто
  final int clientId;
  final int serviceId; // вид услуги (аналог жанра)
  final int masterId; // мастер (аналог издательства)
  final double cost;
  final String status; // new / in_progress / done
  final DateTime? deletedAt;

  const RepairOrder({
    required this.id,
    required this.title,
    required this.vin,
    required this.year,
    required this.clientId,
    required this.serviceId,
    required this.masterId,
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
    int? serviceId,
    int? masterId,
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
      serviceId: serviceId ?? this.serviceId,
      masterId: masterId ?? this.masterId,
      cost: cost ?? this.cost,
      status: status ?? this.status,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
