// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'repositories/client_repository.dart';
import 'repositories/in_memory_client_repository.dart';
import 'repositories/in_memory_order_repository.dart';
import 'repositories/order_repository.dart';
import 'screens/app_shell.dart';
import 'screens/client_details_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/order_details_screen.dart';
import 'screens/orders_screen.dart';
import 'state/client_list_notifier.dart';
import 'state/order_list_notifier.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<OrderRepository>(create: (_) => InMemoryOrderRepository()),
        Provider<ClientRepository>(create: (_) => InMemoryClientRepository()),
        ChangeNotifierProvider(
          create: (ctx) => OrderListNotifier(ctx.read<OrderRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ClientListNotifier(ctx.read<ClientRepository>()),
        ),
      ],
      child: const AutoServiceApp(),
    ),
  );
}

class AutoServiceApp extends StatelessWidget {
  const AutoServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Автосервис',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/orders',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/orders',
          builder: (context, state) =>
              OrdersScreen(urlParams: state.uri.queryParameters),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => OrderDetailsScreen(
                id: int.parse(state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/clients',
          builder: (context, state) => const ClientsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => ClientDetailsScreen(
                id: int.parse(state.pathParameters['id']!),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
