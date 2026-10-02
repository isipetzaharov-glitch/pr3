// lib/screens/service_type_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service_type.dart';
import '../repositories/persistent_service_type_repository.dart';
import '../utils/validators.dart';

class ServiceTypeFormScreen extends StatefulWidget {
  final int? id;
  const ServiceTypeFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<ServiceTypeFormScreen> createState() => _ServiceTypeFormScreenState();
}

class _ServiceTypeFormScreenState extends State<ServiceTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final repo = context.read<PersistentServiceTypeRepository>();
      final s = repo.all.firstWhere(
        (x) => x.id == widget.id,
        orElse: () => const ServiceType(id: 0, name: ''),
      );
      _nameCtrl.text = s.name;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = context.read<PersistentServiceTypeRepository>();
    setState(() => _saving = true);

    try {
      if (widget.isEditing) {
        await repo.update(
          ServiceType(id: widget.id!, name: _nameCtrl.text.trim()),
        );
      } else {
        await repo.create(ServiceType(id: 0, name: _nameCtrl.text.trim()));
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка сохранения: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Редактирование услуги' : 'Новая услуга',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Название услуги *',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final r = Validators.required(v, field: 'Название');
                if (r != null) return r;
                return Validators.maxLength(v, 60, field: 'Название');
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
    );
  }
}
