import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/client.dart';
import '../state/client_list_notifier.dart';
import '../state/order_list_notifier.dart' show LoadStatus;
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientListNotifier>().load();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      context.read<ClientListNotifier>().setSearch(v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<ClientListNotifier>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Поиск: фамилия или страна',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                FilterChip(
                  label: const Text('Показать удалённых'),
                  selected: n.includeDeleted,
                  onSelected: n.setIncludeDeleted,
                ),
                if (n.hasSelection)
                  Chip(
                    label: Text('Выбрано: ${n.selected.length}'),
                    onDeleted: () =>
                        n.toggleSelection(-1), // сброс через клик по крестику
                  ),
                if (n.hasSelection)
                  FilledButton(
                    onPressed: () async {
                      final ok = await _confirm(
                        context,
                        'Удалить выбранных клиентов?',
                      );
                      if (ok == true) await n.deleteSelected();
                    },
                    child: const Text('Удалить'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(child: _body(context, n)),
            if (n.status == LoadStatus.success && n.result.items.isNotEmpty)
              PaginationBar(
                page: n.result.page,
                totalPages: n.result.totalPages,
                total: n.result.total,
                size: n.result.size,
                onPageChanged: n.setPage,
                onSizeChanged: n.setSize,
              ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ClientListNotifier n) {
    if (n.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (n.status == LoadStatus.error) {
      return Center(child: Text(n.error ?? 'Ошибка'));
    }
    if (n.result.items.isEmpty) {
      return const Center(child: Text('Клиенты не найдены'));
    }

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 600) {
          return ListView.builder(
            itemCount: n.result.items.length,
            itemBuilder: (_, i) {
              final cl = n.result.items[i];
              return Card(
                child: ListTile(
                  title: Text(cl.fullName),
                  subtitle: Text('${cl.phone}\n${cl.country}'),
                  isThreeLine: true,
                  onTap: () => context.go('/clients/${cl.id}'),
                  trailing: Checkbox(
                    value: n.selected.contains(cl.id),
                    onChanged: (_) => n.toggleSelection(cl.id),
                  ),
                ),
              );
            },
          );
        }
        return EntityTable<Client>(
          items: n.result.items,
          idOf: (c) => c.id,
          selected: n.selected,
          onToggleSelect: n.toggleSelection,
          sortField: n.sortField,
          sortAscending: n.sortAscending,
          onSort: n.setSort,
          columns: [
            TableColumnSpec(
              label: 'Фамилия',
              sortField: 'lastName',
              build: (c) => Text(c.lastName),
            ),
            TableColumnSpec(label: 'Имя', build: (c) => Text(c.firstName)),
            TableColumnSpec(label: 'Телефон', build: (c) => Text(c.phone)),
            TableColumnSpec(
              label: 'Страна',
              sortField: 'country',
              build: (c) => Text(c.country),
            ),
          ],
          actions: (c) => [
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () => context.go('/clients/${c.id}'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _confirm(BuildContext context, String text) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Да'),
          ),
        ],
      ),
    );
  }
}
