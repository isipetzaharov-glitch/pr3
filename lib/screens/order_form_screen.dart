// lib/screens/order_form_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/repair_order.dart';
import '../repositories/order_repository.dart';
import '../state/dictionaries_notifier.dart';
import '../utils/validators.dart';

class OrderFormScreen extends StatefulWidget {
  final int? id;
  const OrderFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _vinCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _costCtrl = TextEditingController();

  int? _clientId;
  int? _masterId;
  List<int> _serviceIds = [];
  String _status = 'new';

  bool _loading = true;
  bool _saving = false;
  String? _loadError;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Все context.read — ДО первого await
    final dict = context.read<DictionariesNotifier>();
    final repo = context.read<OrderRepository>();

    await dict.ensureLoaded();

    if (widget.isEditing) {
      final order = await repo.findById(widget.id!);
      if (!mounted) return;
      if (order != null) {
        _titleCtrl.text = order.title;
        _vinCtrl.text = order.vin;
        _yearCtrl.text = order.year.toString();
        _costCtrl.text = order.cost.toStringAsFixed(0);
        _clientId = order.clientId;
        _masterId = order.masterId;
        _serviceIds = [...order.serviceIds];
        _status = order.status;
      } else {
        _loadError = 'Заказ не найден';
      }
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _vinCtrl.dispose();
    _yearCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  /// Единая точка возврата в список — работает через State.context,
  /// поэтому линтер не ругается на use_build_context_synchronously.
  void _goBack() {
    if (!mounted) return;
    GoRouter.of(context).go('/orders');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clientId == null) {
      _snack('Выберите клиента');
      return;
    }
    if (_masterId == null) {
      _snack('Выберите мастера');
      return;
    }
    if (_serviceIds.isEmpty) {
      _snack('Выберите хотя бы одну услугу');
      return;
    }

    final repo = context.read<OrderRepository>();
    setState(() => _saving = true);

    try {
      final order = RepairOrder(
        id: widget.id ?? 0,
        title: _titleCtrl.text.trim(),
        vin: _vinCtrl.text.trim(),
        year: int.parse(_yearCtrl.text),
        clientId: _clientId!,
        masterId: _masterId!,
        serviceIds: _serviceIds,
        cost: double.parse(_costCtrl.text.replaceAll(',', '.')),
        status: _status,
      );
      if (widget.isEditing) {
        await repo.update(order);
      } else {
        await repo.create(order);
      }
      _dirty = false;
      if (!mounted) return;
      _snack(widget.isEditing ? 'Изменения сохранены' : 'Заказ создан');
      _goBack();
    } catch (e) {
      if (!mounted) return;
      _snack('Ошибка сохранения: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<bool> _confirmExit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Есть несохранённые изменения'),
        content: const Text('Уйти без сохранения?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Остаться'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Уйти'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _handleBack() async {
    if (!_dirty) {
      _goBack();
      return;
    }
    final ok = await _confirmExit();
    if (!ok) return;
    _goBack();
  }

  @override
  Widget build(BuildContext context) {
    final dict = context.watch<DictionariesNotifier>();

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_loadError!)),
      );
    }

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _confirmExit();
        if (!ok) return;
        // Навигация через метод _goBack — использует State.context,
        // поэтому use_build_context_synchronously не срабатывает.
        _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Редактирование заказа' : 'Новый заказ',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
        ),
        body: Form(
          key: _formKey,
          onChanged: _markDirty,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Название работ *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final r = Validators.required(v, field: 'Название');
                  if (r != null) return r;
                  return Validators.maxLength(v, 100, field: 'Название');
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vinCtrl,
                decoration: const InputDecoration(
                  labelText: 'VIN *',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.vin,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Год выпуска *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    Validators.intRange(v, 1970, 2100, field: 'Год'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Стоимость, ₽ *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    Validators.positiveDouble(v, field: 'Стоимость'),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'Связи',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                initialValue: _clientId,
                decoration: const InputDecoration(
                  labelText: 'Клиент *',
                  border: OutlineInputBorder(),
                ),
                items: dict.clients
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.fullName),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() => _clientId = v);
                  _markDirty();
                },
                validator: (v) => v == null ? 'Выберите клиента' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                initialValue: _masterId,
                decoration: const InputDecoration(
                  labelText: 'Мастер *',
                  border: OutlineInputBorder(),
                ),
                items: dict.masters
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(m.fullName),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() => _masterId = v);
                  _markDirty();
                },
                validator: (v) => v == null ? 'Выберите мастера' : null,
              ),
              const SizedBox(height: 12),

              FormField<List<int>>(
                initialValue: _serviceIds,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Выберите хотя бы одну услугу'
                    : null,
                builder: (field) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Услуги *',
                      border: const OutlineInputBorder(),
                      errorText: field.errorText,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dict.serviceTypes.map((s) {
                        final selected = field.value!.contains(s.id);
                        return FilterChip(
                          label: Text(s.name),
                          selected: selected,
                          onSelected: (_) {
                            final next = [...field.value!];
                            selected ? next.remove(s.id) : next.add(s.id);
                            field.didChange(next);
                            setState(() => _serviceIds = next);
                            _markDirty();
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Статус *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'new', child: Text('Новый')),
                  DropdownMenuItem(
                    value: 'in_progress',
                    child: Text('В работе'),
                  ),
                  DropdownMenuItem(value: 'done', child: Text('Завершён')),
                ],
                onChanged: (v) {
                  setState(() => _status = v ?? 'new');
                  _markDirty();
                },
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(widget.isEditing ? 'Сохранить' : 'Создать'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
