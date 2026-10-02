// lib/screens/masters_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/master.dart';
import '../models/order_query.dart';
import '../repositories/order_repository.dart';
import '../repositories/persistent_master_repository.dart';
import 'master_form_screen.dart';

class MastersScreen extends StatefulWidget {
  const MastersScreen({super.key});

  @override
  State<MastersScreen> createState() => _MastersScreenState();
}

class _MastersScreenState extends State<MastersScreen> {
  List<Master> _masters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final repo = context.read<PersistentMasterRepository>();
    final list = await repo.getAll();

    if (!mounted) return;
    setState(() {
      _masters = list;
      _loading = false;
    });
  }

  Future<void> _tryDelete(Master m) async {
    final ordersRepo = context.read<OrderRepository>();
    final masterRepo = context.read<PersistentMasterRepository>();

    final page = await ordersRepo.find(
      const OrderQuery(size: 1000, includeDeleted: true),
    );
    final linked = page.items.where((o) => o.masterId == m.id).length;

    if (!mounted) return;

    if (linked > 0) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Удаление невозможно'),
          content: Text(
            'На мастера «${m.fullName}» ссылаются $linked заказ(ов). '
            'Сначала удалите или переназначьте их.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
      return;
    }

    if (!mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить мастера?'),
        content: Text('Мастер «${m.fullName}» будет удалён.'),
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

    final rest = _masters.where((x) => x.id != m.id).toList();
    await masterRepo.replaceAll(rest);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Мастер удалён')));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мастера'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MasterFormScreen()),
              );
              if (!mounted) return;
              await _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _masters.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final m = _masters[i];
                return ListTile(
                  title: Text(m.fullName),
                  subtitle: Text(m.specialization),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MasterFormScreen(id: m.id),
                            ),
                          );
                          if (!mounted) return;
                          await _load();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _tryDelete(m),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
