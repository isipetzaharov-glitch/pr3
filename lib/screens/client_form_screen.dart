import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/client.dart';
import '../models/service_card.dart';
import '../repositories/client_repository.dart';
import '../utils/validators.dart';

class ClientFormScreen extends StatefulWidget {
  final int? id;
  const ClientFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  // Поля билета (1-к-1)
  bool _hasCard = false;
  final _cardNumberCtrl = TextEditingController();
  String _discountCategory = 'обычный';

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.isEditing) {
      final repo = context.read<ClientRepository>();
      final c = await repo.findById(widget.id!);
      if (c != null) {
        _lastNameCtrl.text = c.lastName;
        _firstNameCtrl.text = c.firstName;
        _emailCtrl.text = c.email;
        _phoneCtrl.text = c.phone;
        _countryCtrl.text = c.country;
        if (c.card != null) {
          _hasCard = true;
          _cardNumberCtrl.text = c.card!.number;
          _discountCategory = c.card!.discountCategory;
        }
      }
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _countryCtrl.dispose();
    _cardNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Ошибка уникальности email (п.12)
    final repo = context.read<ClientRepository>();
    final email = _emailCtrl.text.trim();
    final exists = await repo.emailExists(email, exceptId: widget.id);
    if (exists) {
      _formKey.currentState!.validate(); // обычная валидация
      // Показать конкретную ошибку под полем email:
      setState(() => _uniqueEmailError = 'Такой email уже используется');
      return;
    }
    setState(() => _uniqueEmailError = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final client = Client(
        id: widget.id ?? 0,
        lastName: _lastNameCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        email: email,
        phone: _phoneCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        card: _hasCard
            ? ServiceCard(
                number: _cardNumberCtrl.text.trim(),
                issuedAt: DateTime.now(),
                discountCategory: _discountCategory,
              )
            : null,
      );
      if (widget.isEditing) {
        await repo.update(client);
      } else {
        await repo.create(client);
      }
      if (mounted) context.go('/clients');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _uniqueEmailError;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Редактирование клиента' : 'Новый клиент',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _lastNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Фамилия *',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final r = Validators.required(v, field: 'Фамилия');
                if (r != null) return r;
                return Validators.maxLength(v, 50, field: 'Фамилия');
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _firstNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Имя *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => Validators.required(v, field: 'Имя'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email *',
                border: const OutlineInputBorder(),
                errorText: _uniqueEmailError,
              ),
              validator: Validators.email,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Телефон *',
                border: OutlineInputBorder(),
              ),
              validator: Validators.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _countryCtrl,
              decoration: const InputDecoration(
                labelText: 'Страна *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => Validators.required(v, field: 'Страна'),
            ),

            const SizedBox(height: 16),
            const Divider(),
            SwitchListTile(
              title: const Text('Есть сервисная карта'),
              subtitle: const Text('Связь 1-к-1'),
              value: _hasCard,
              onChanged: (v) => setState(() => _hasCard = v),
            ),

            if (_hasCard) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _cardNumberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Номер карты *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _hasCard
                    ? Validators.required(v, field: 'Номер карты')
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _discountCategory,
                decoration: const InputDecoration(
                  labelText: 'Категория скидки',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'обычный', child: Text('Обычный')),
                  DropdownMenuItem(value: 'серебро', child: Text('Серебро')),
                  DropdownMenuItem(value: 'золото', child: Text('Золото')),
                ],
                onChanged: (v) =>
                    setState(() => _discountCategory = v ?? 'обычный'),
              ),
            ],

            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(widget.isEditing ? 'Сохранить' : 'Создать'),
            ),
          ],
        ),
      ),
    );
  }
}
