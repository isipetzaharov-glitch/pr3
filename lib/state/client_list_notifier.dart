import 'package:flutter/foundation.dart';

import '../models/client.dart';
import '../models/page_result.dart';
import '../repositories/client_repository.dart';
import 'order_list_notifier.dart' show LoadStatus;

class ClientListNotifier extends ChangeNotifier {
  final ClientRepository _repository;

  ClientListNotifier(this._repository);

  String _search = '';
  String _sortField = 'lastName';
  bool _sortAscending = true;
  int _page = 1;
  int _size = 10;
  bool _includeDeleted = false;

  PageResult<Client> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};

  String get search => _search;
  String get sortField => _sortField;
  bool get sortAscending => _sortAscending;
  int get page => _page;
  int get size => _size;
  bool get includeDeleted => _includeDeleted;
  PageResult<Client> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _result = await _repository.find(
        search: _search,
        sortField: _sortField,
        sortAscending: _sortAscending,
        page: _page,
        size: _size,
        includeDeleted: _includeDeleted,
      );
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить клиентов: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> setSearch(String v) async {
    _search = v;
    _page = 1;
    _selected.clear();
    await load();
  }

  Future<void> setSort(String field) async {
    if (_sortField == field) {
      _sortAscending = !_sortAscending;
    } else {
      _sortField = field;
      _sortAscending = true;
    }
    await load();
  }

  Future<void> setPage(int p) async {
    _page = p;
    await load();
  }

  Future<void> setSize(int s) async {
    _size = s;
    _page = 1;
    await load();
  }

  Future<void> setIncludeDeleted(bool v) async {
    _includeDeleted = v;
    _page = 1;
    await load();
  }

  void toggleSelection(int id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    await _repository.deleteMany(_selected.toList());
    _selected.clear();
    await load();
  }

  Future<void> softDeleteOne(int id) async {
    await _repository.softDelete(id);
    await load();
  }

  Future<void> restoreOne(int id) async {
    await _repository.restore(id);
    await load();
  }
}
