import '../data/seed_orders.dart';
import '../models/order_query.dart';
import '../models/page_result.dart';
import '../models/repair_order.dart';
import 'order_repository.dart';

class InMemoryOrderRepository implements OrderRepository {
  final List<RepairOrder> _orders = [...seedOrders];
  int _nextId = seedOrders.length + 1;

  @override
  Future<PageResult<RepairOrder>> find(OrderQuery q) async {
    // Имитация сети — чтобы индикатор загрузки был виден
    await Future.delayed(const Duration(milliseconds: 250));

    var rows = _orders.where((o) => q.includeDeleted || !o.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where(
            (o) =>
                o.title.toLowerCase().contains(needle) ||
                o.vin.toLowerCase().contains(needle),
          )
          .toList();
    }

    if (q.serviceId != null) {
      rows = rows.where((o) => o.serviceId == q.serviceId).toList();
    }
    if (q.masterId != null) {
      rows = rows.where((o) => o.masterId == q.masterId).toList();
    }
    if (q.yearFrom != null) {
      rows = rows.where((o) => o.year >= q.yearFrom!).toList();
    }
    if (q.yearTo != null) {
      rows = rows.where((o) => o.year <= q.yearTo!).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'year' => a.year.compareTo(b.year),
        'cost' => a.cost.compareTo(b.cost),
        'status' => a.status.compareTo(b.status),
        _ => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <RepairOrder>[] : rows.sublist(from, to);

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<RepairOrder?> findById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final i = _orders.indexWhere((o) => o.id == id);
    return i == -1 ? null : _orders[i];
  }

  @override
  Future<RepairOrder> create(RepairOrder order) async {
    final created = RepairOrder(
      id: _nextId++,
      title: order.title,
      vin: order.vin,
      year: order.year,
      clientId: order.clientId,
      serviceId: order.serviceId,
      masterId: order.masterId,
      cost: order.cost,
      status: order.status,
    );
    _orders.add(created);
    return created;
  }

  @override
  Future<RepairOrder> update(RepairOrder order) async {
    final i = _orders.indexWhere((o) => o.id == order.id);
    if (i == -1) throw StateError('Заказ ${order.id} не найден');
    _orders[i] = order;
    return order;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i == -1) throw StateError('Заказ $id не найден');
    _orders[i] = _orders[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _orders.removeWhere((o) => o.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i == -1) throw StateError('Заказ $id не найден');
    _orders[i] = _orders[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _orders.indexWhere((o) => o.id == id && !o.isDeleted);
      if (i != -1) {
        _orders[i] = _orders[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}
