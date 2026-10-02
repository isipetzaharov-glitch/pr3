// lib/screens/app_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final idx = loc.startsWith('/clients')
        ? 1
        : loc.startsWith('/masters')
        ? 2
        : loc.startsWith('/services')
        ? 3
        : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Автосервис')),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/orders');
              break;
            case 1:
              context.go('/clients');
              break;
            case 2:
              context.go('/masters');
              break;
            case 3:
              context.go('/services');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.build), label: 'Заказы'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Клиенты'),
          NavigationDestination(icon: Icon(Icons.handyman), label: 'Мастера'),
          NavigationDestination(
            icon: Icon(Icons.construction),
            label: 'Услуги',
          ),
        ],
      ),
    );
  }
}
