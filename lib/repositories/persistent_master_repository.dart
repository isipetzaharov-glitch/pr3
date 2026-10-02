// lib/repositories/persistent_master_repository.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_masters.dart';
import '../models/master.dart';

class PersistentMasterRepository {
  static const _key = 'masters_v1';
  final SharedPreferences _prefs;
  List<Master> _items = [];

  PersistentMasterRepository(this._prefs) {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _items = [...seedMasters];
      _persist();
    } else {
      try {
        _items = (jsonDecode(raw) as List)
            .map((e) => Master.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _items = [...seedMasters];
        _persist();
      }
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_items.map((m) => m.toJson()).toList()),
    );
  }

  List<Master> get all => List.unmodifiable(_items);

  Future<List<Master>> getAll() async => List.of(_items);

  Future<Master> create(Master m) async {
    final id = _items.isEmpty
        ? 1
        : _items.map((x) => x.id).reduce((a, b) => a > b ? a : b) + 1;
    final created = Master(
      id: id,
      fullName: m.fullName,
      specialization: m.specialization,
    );
    _items.add(created);
    await _persist();
    return created;
  }

  Future<Master> update(Master m) async {
    final i = _items.indexWhere((x) => x.id == m.id);
    if (i == -1) throw StateError('Мастер ${m.id} не найден');
    _items[i] = m;
    await _persist();
    return m;
  }

  // ← ДОБАВЛЕНО: используется в masters_screen.dart для удаления
  Future<void> replaceAll(List<Master> items) async {
    _items = [...items];
    await _persist();
  }

  Future<void> delete(int id) async {
    _items.removeWhere((x) => x.id == id);
    await _persist();
  }
}
