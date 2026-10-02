import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_clients.dart';
import '../models/client.dart';
import '../models/page_result.dart';
import 'client_repository.dart';

class PersistentClientRepository implements ClientRepository {
  static const _key = 'clients_v2';
  final SharedPreferences _prefs;
  List<Client> _clients = [];

  PersistentClientRepository(this._prefs) {
    _restore();
  }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _clients = [...seedClients];
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _clients = list
          .map((e) => Client.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _clients = [...seedClients];
      _persist();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_clients.map((c) => c.toJson()).toList()),
    );
  }

  int get _nextId => _clients.isEmpty
      ? 1
      : _clients.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;

  @override
  Future<PageResult<Client>> find({
    String search = '',
    String sortField = 'lastName',
    bool sortAscending = true,
    int page = 1,
    int size = 10,
    bool includeDeleted = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var rows = _clients.where((c) => includeDeleted || !c.isDeleted).toList();
    if (search.trim().isNotEmpty) {
      final n = search.trim().toLowerCase();
      rows = rows
          .where(
            (c) =>
                c.lastName.toLowerCase().contains(n) ||
                c.country.toLowerCase().contains(n),
          )
          .toList();
    }
    rows.sort((a, b) {
      final r = switch (sortField) {
        'country' => a.country.toLowerCase().compareTo(b.country.toLowerCase()),
        'email' => a.email.toLowerCase().compareTo(b.email.toLowerCase()),
        _ => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()),
      };
      return sortAscending ? r : -r;
    });
    final total = rows.length;
    final from = (page - 1) * size;
    final to = (from + size) > total ? total : (from + size);
    final items = from >= total ? <Client>[] : rows.sublist(from, to);
    return PageResult(items: items, page: page, size: size, total: total);
  }

  @override
  Future<Client?> findById(int id) async {
    final i = _clients.indexWhere((c) => c.id == id);
    return i == -1 ? null : _clients[i];
  }

  @override
  Future<Client> create(Client c) async {
    final created = Client(
      id: _nextId,
      lastName: c.lastName,
      firstName: c.firstName,
      email: c.email,
      phone: c.phone,
      country: c.country,
      card: c.card,
    );
    _clients.add(created);
    await _persist();
    return created;
  }

  @override
  Future<Client> update(Client c) async {
    final i = _clients.indexWhere((x) => x.id == c.id);
    if (i == -1) throw StateError('Клиент ${c.id} не найден');
    _clients[i] = c;
    await _persist();
    return c;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _clients.indexWhere((c) => c.id == id);
    if (i == -1) throw StateError('Клиент $id не найден');
    _clients[i] = _clients[i].copyWith(deletedAt: DateTime.now());
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _clients.indexWhere((c) => c.id == id);
    if (i == -1) throw StateError('Клиент $id не найден');
    _clients[i] = _clients[i].copyWith(clearDeletedAt: true);
    await _persist();
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _clients.indexWhere((c) => c.id == id && !c.isDeleted);
      if (i != -1) {
        _clients[i] = _clients[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    await _persist();
    return count;
  }

  @override
  Future<bool> emailExists(String email, {int? exceptId}) async {
    return _clients.any(
      (c) =>
          c.email.toLowerCase() == email.toLowerCase() &&
          c.id != exceptId &&
          !c.isDeleted,
    );
  }
}
