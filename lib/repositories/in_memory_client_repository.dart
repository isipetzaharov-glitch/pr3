import '../data/seed_clients.dart';
import '../models/client.dart';
import '../models/page_result.dart';
import 'client_repository.dart';

class InMemoryClientRepository implements ClientRepository {
  final List<Client> _clients = [...seedClients];

  @override
  Future<PageResult<Client>> find({
    String search = '',
    String sortField = 'lastName',
    bool sortAscending = true,
    int page = 1,
    int size = 10,
    bool includeDeleted = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

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
  Future<void> softDelete(int id) async {
    final i = _clients.indexWhere((c) => c.id == id);
    if (i == -1) throw StateError('Клиент $id не найден');
    _clients[i] = _clients[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> restore(int id) async {
    final i = _clients.indexWhere((c) => c.id == id);
    if (i == -1) throw StateError('Клиент $id не найден');
    _clients[i] = _clients[i].copyWith(clearDeletedAt: true);
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
    return count;
  }
}
