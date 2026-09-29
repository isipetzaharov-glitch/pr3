// lib/models/order_query.dart

class OrderQuery {
  final String search;
  final int? serviceId;
  final int? masterId;
  final int? yearFrom;
  final int? yearTo;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const OrderQuery({
    this.search = '',
    this.serviceId,
    this.masterId,
    this.yearFrom,
    this.yearTo,
    this.sortField = 'title',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  OrderQuery copyWith({
    String? search,
    Object? serviceId = _unset,
    Object? masterId = _unset,
    Object? yearFrom = _unset,
    Object? yearTo = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return OrderQuery(
      search: search ?? this.search,
      serviceId: serviceId == _unset ? this.serviceId : serviceId as int?,
      masterId: masterId == _unset ? this.masterId : masterId as int?,
      yearFrom: yearFrom == _unset ? this.yearFrom : yearFrom as int?,
      yearTo: yearTo == _unset ? this.yearTo : yearTo as int?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  static const _unset = Object();

  Map<String, String> toParams() {
    final p = <String, String>{};
    if (search.isNotEmpty) p['search'] = search;
    if (serviceId != null) p['serviceId'] = '$serviceId';
    if (masterId != null) p['masterId'] = '$masterId';
    if (yearFrom != null) p['yearFrom'] = '$yearFrom';
    if (yearTo != null) p['yearTo'] = '$yearTo';
    if (sortField != 'title') p['sort'] = sortField;
    if (!sortAscending) p['dir'] = 'desc';
    if (page != 1) p['page'] = '$page';
    if (size != 10) p['size'] = '$size';
    if (includeDeleted) p['deleted'] = '1';
    return p;
  }

  factory OrderQuery.fromParams(Map<String, String> p) {
    return OrderQuery(
      search: p['search'] ?? '',
      serviceId: p['serviceId'] != null ? int.tryParse(p['serviceId']!) : null,
      masterId: p['masterId'] != null ? int.tryParse(p['masterId']!) : null,
      yearFrom: p['yearFrom'] != null ? int.tryParse(p['yearFrom']!) : null,
      yearTo: p['yearTo'] != null ? int.tryParse(p['yearTo']!) : null,
      sortField: p['sort'] ?? 'title',
      sortAscending: p['dir'] != 'desc',
      page: p['page'] != null ? int.tryParse(p['page']!) ?? 1 : 1,
      size: p['size'] != null ? int.tryParse(p['size']!) ?? 10 : 10,
      includeDeleted: p['deleted'] == '1',
    );
  }
}
