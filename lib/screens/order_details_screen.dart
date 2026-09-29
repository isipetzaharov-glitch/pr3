import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../repositories/order_repository.dart';

class OrderDetailsScreen extends StatelessWidget {
  final int id;
  const OrderDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<OrderRepository>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Заказ #$id'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/orders'),
        ),
      ),
      body: FutureBuilder(
        future: repo.findById(id),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final o = snap.data;
          if (o == null) return const Center(child: Text('Заказ не найден'));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('VIN: ${o.vin}'),
                Text('Год выпуска: ${o.year}'),
                Text('Стоимость: ${o.cost.toStringAsFixed(0)} ₽'),
                Text('Статус: ${o.status}'),
                if (o.isDeleted)
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
