import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_orders.dart';
import '../models/order_query.dart';
import '../models/page_result.dart';
import '../models/repair_order.dart';
import 'order_repository.dart';

class PersistentRepairOrderRepository implements OrderRepository {
  static const _key = 'orders_v2'; // v2 — новая версия после ПР3
  final SharedPreferences _prefs;
  List<RepairOrder> _orders = [];

  PersistentRepairOrderRepository(this._prefs) {
    _restore();
  }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _orders = [...seedOrders];
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _orders = list
          .map((e) => RepairOrder.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _orders = [...seedOrders];
      _persist();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_orders.map((o) => o.toJson()).toList()),
    );
  }

  int get _nextId => _orders.isEmpty
      ? 1
      : _orders.map((o) => o.id).reduce((a, b) => a > b ? a : b) + 1;

  @override
  Future<PageResult<RepairOrder>> find(OrderQuery q) async {
    await Future.delayed(const Duration(milliseconds: 150));

    var rows = _orders.where((o) => q.includeDeleted || !o.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final n = q.search.trim().toLowerCase();
      rows = rows
          .where(
            (o) =>
                o.title.toLowerCase().contains(n) ||
                o.vin.toLowerCase().contains(n),
          )
          .toList();
    }
    if (q.serviceId != null) {
      rows = rows.where((o) => o.serviceIds.contains(q.serviceId)).toList();
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
      final r = switch (q.sortField) {
        'year' => a.year.compareTo(b.year),
        'cost' => a.cost.compareTo(b.cost),
        'status' => a.status.compareTo(b.status),
        _ => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      };
      return q.sortAscending ? r : -r;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <RepairOrder>[] : rows.sublist(from, to);
    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<RepairOrder?> findById(int id) async {
    final i = _orders.indexWhere((o) => o.id == id);
    return i == -1 ? null : _orders[i];
  }

  @override
  Future<RepairOrder> create(RepairOrder order) async {
    final created = RepairOrder(
      id: _nextId,
      title: order.title,
      vin: order.vin,
      year: order.year,
      clientId: order.clientId,
      masterId: order.masterId,
      serviceIds: order.serviceIds,
      cost: order.cost,
      status: order.status,
    );
    _orders.add(created);
    await _persist();
    return created;
  }

  @override
  Future<RepairOrder> update(RepairOrder order) async {
    final i = _orders.indexWhere((o) => o.id == order.id);
    if (i == -1) throw StateError('Заказ ${order.id} не найден');
    _orders[i] = order;
    await _persist();
    return order;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i == -1) throw StateError('Заказ $id не найден');
    _orders[i] = _orders[i].copyWith(deletedAt: DateTime.now());
    await _persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    _orders.removeWhere((o) => o.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i == -1) throw StateError('Заказ $id не найден');
    _orders[i] = _orders[i].copyWith(clearDeletedAt: true);
    await _persist();
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
    await _persist();
    return count;
  }
}
