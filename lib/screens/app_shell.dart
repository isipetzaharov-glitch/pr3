import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final idx = loc.startsWith('/clients') ? 1 : 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Автосервис')),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) =>
            i == 0 ? context.go('/orders') : context.go('/clients'),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.build), label: 'Заказы'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Клиенты'),
        ],
      ),
    );
  }
}
