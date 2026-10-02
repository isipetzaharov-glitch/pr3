// lib/screens/service_types_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service_type.dart';
import '../repositories/persistent_service_type_repository.dart';
import 'service_type_form_screen.dart';

class ServiceTypesScreen extends StatefulWidget {
  const ServiceTypesScreen({super.key});

  @override
  State<ServiceTypesScreen> createState() => _ServiceTypesScreenState();
}

class _ServiceTypesScreenState extends State<ServiceTypesScreen> {
  List<ServiceType> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final repo = context.read<PersistentServiceTypeRepository>();
    final list = await repo.getAll();

    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _openCreate() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ServiceTypeFormScreen()));
    if (!mounted) return;
    await _load();
  }

  Future<void> _openEdit(ServiceType s) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ServiceTypeFormScreen(id: s.id)));
    if (!mounted) return;
    await _load();
  }

  Future<void> _tryDelete(ServiceType s) async {
    final repo = context.read<PersistentServiceTypeRepository>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить услугу?'),
        content: Text('Услуга «${s.name}» будет удалена из справочника.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!mounted) return;

    await repo.delete(s.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Услуга удалена')));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Услуги'),
        actions: [
          IconButton(
            tooltip: 'Новая услуга',
            icon: const Icon(Icons.add),
            onPressed: _openCreate,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Список услуг пуст'),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final s = _items[i];
                return ListTile(
                  leading: const Icon(Icons.build_circle_outlined),
                  title: Text(s.name),
                  subtitle: Text('ID: ${s.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Редактировать',
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openEdit(s),
                      ),
                      IconButton(
                        tooltip: 'Удалить',
                        icon: const Icon(Icons.delete),
                        onPressed: () => _tryDelete(s),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Новая услуга',
        onPressed: _openCreate,
        child: const Icon(Icons.add),
      ),
    );
  }
}
