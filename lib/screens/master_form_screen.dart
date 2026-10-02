import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/master.dart';
import '../repositories/persistent_master_repository.dart';
import '../utils/validators.dart';

class MasterFormScreen extends StatefulWidget {
  final int? id;
  const MasterFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<MasterFormScreen> createState() => _MasterFormScreenState();
}

class _MasterFormScreenState extends State<MasterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _specCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final repo = context.read<PersistentMasterRepository>();
      final m = repo.all.firstWhere(
        (x) => x.id == widget.id,
        orElse: () => const Master(id: 0, fullName: '', specialization: ''),
      );
      _nameCtrl.text = m.fullName;
      _specCtrl.text = m.specialization;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _specCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = context.read<PersistentMasterRepository>();
    if (widget.isEditing) {
      await repo.update(
        Master(
          id: widget.id!,
          fullName: _nameCtrl.text.trim(),
          specialization: _specCtrl.text.trim(),
        ),
      );
    } else {
      await repo.create(
        Master(
          id: 0,
          fullName: _nameCtrl.text.trim(),
          specialization: _specCtrl.text.trim(),
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Редактирование мастера' : 'Новый мастер',
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
                labelText: 'ФИО *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => Validators.required(v, field: 'ФИО'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _specCtrl,
              decoration: const InputDecoration(
                labelText: 'Специализация *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => Validators.required(v, field: 'Специализация'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(widget.isEditing ? 'Сохранить' : 'Создать'),
            ),
          ],
        ),
      ),
    );
  }
}
