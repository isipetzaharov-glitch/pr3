// lib/screens/client_details_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../repositories/client_repository.dart';
import '../state/client_list_notifier.dart';

class ClientDetailsScreen extends StatelessWidget {
  final int id;
  const ClientDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ClientRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Клиент #$id'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/clients'),
        ),
        actions: [
          IconButton(
            tooltip: 'Редактировать',
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/clients/$id/edit'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: repo.findById(id),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final c = snap.data;
          if (c == null) {
            return const Center(child: Text('Клиент не найден'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.fullName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  _row('Фамилия', c.lastName),
                  _row('Имя', c.firstName),
                  _row('Email', c.email),
                  _row('Телефон', c.phone),
                  _row('Страна', c.country),

                  const SizedBox(height: 16),
                  const Divider(),
                  const Text(
                    'Сервисная карта',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (c.card != null) ...[
                    _row('Номер', c.card!.number),
                    _row('Категория скидки', c.card!.discountCategory),
                    _row(
                      'Выдана',
                      '${c.card!.issuedAt.day}.'
                          '${c.card!.issuedAt.month}.'
                          '${c.card!.issuedAt.year}',
                    ),
                  ] else
                    const Text('Карты нет'),

                  if (c.isDeleted) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.red.shade50,
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber, color: Colors.red),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Клиент удалён (в корзине)',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          FilledButton(
                            onPressed: () async {
                              final n = context.read<ClientListNotifier>();
                              await n.restoreOne(c.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Клиент восстановлен'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Восстановить'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
