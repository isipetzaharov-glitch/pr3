import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../repositories/client_repository.dart';

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
      ),
      body: FutureBuilder(
        future: repo.findById(id),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final c = snap.data;
          if (c == null) return const Center(child: Text('Клиент не найден'));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.fullName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Телефон: ${c.phone}'),
                Text('Страна: ${c.country}'),
                if (c.isDeleted)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Удалён (в корзине)',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
