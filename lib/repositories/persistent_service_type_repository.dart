// lib/repositories/persistent_service_type_repository.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_service_types.dart';
import '../models/service_type.dart';

class PersistentServiceTypeRepository {
  static const _key = 'service_types_v1';
  final SharedPreferences _prefs;
  List<ServiceType> _items = [];

  PersistentServiceTypeRepository(this._prefs) {
    _restore();
  }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _items = [...seedServiceTypes];
      _persist();
      return;
    }
    try {
      _items = (jsonDecode(raw) as List)
          .map((e) => ServiceType.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Испорченные данные в localStorage — сбрасываем к seed-набору
      _items = [...seedServiceTypes];
      _persist();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_items.map((s) => s.toJson()).toList()),
    );
  }

  int get _nextId => _items.isEmpty
      ? 1
      : _items.map((x) => x.id).reduce((a, b) => a > b ? a : b) + 1;

  /// Синхронный доступ ко всем элементам — для выпадающих списков.
  List<ServiceType> get all => List.unmodifiable(_items);

  /// Асинхронный доступ — для форм, где нужен await.
  Future<List<ServiceType>> getAll() async => List.of(_items);

  Future<ServiceType?> findById(int id) async {
    final i = _items.indexWhere((s) => s.id == id);
    return i == -1 ? null : _items[i];
  }

  Future<ServiceType> create(ServiceType s) async {
    final created = ServiceType(id: _nextId, name: s.name);
    _items.add(created);
    await _persist();
    return created;
  }

  Future<ServiceType> update(ServiceType s) async {
    final i = _items.indexWhere((x) => x.id == s.id);
    if (i == -1) throw StateError('Услуга ${s.id} не найдена');
    _items[i] = s;
    await _persist();
    return s;
  }

  Future<void> delete(int id) async {
    _items.removeWhere((x) => x.id == id);
    await _persist();
  }

  Future<void> replaceAll(List<ServiceType> items) async {
    _items = [...items];
    await _persist();
  }
}
