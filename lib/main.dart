// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repositories/client_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/persistent_client_repository.dart';
import 'repositories/persistent_master_repository.dart';
import 'repositories/persistent_repair_order_repository.dart';
import 'repositories/persistent_service_type_repository.dart';
import 'screens/app_shell.dart';
import 'screens/client_details_screen.dart';
import 'screens/client_form_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/master_form_screen.dart';
import 'screens/masters_screen.dart';
import 'screens/order_details_screen.dart';
import 'screens/order_form_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/service_type_form_screen.dart';
import 'screens/service_types_screen.dart';
import 'state/client_list_notifier.dart';
import 'state/dictionaries_notifier.dart';
import 'state/order_list_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: prefs),

        Provider<OrderRepository>(
          create: (_) => PersistentRepairOrderRepository(prefs),
        ),
        Provider<ClientRepository>(
          create: (_) => PersistentClientRepository(prefs),
        ),
        Provider<PersistentMasterRepository>(
          create: (_) => PersistentMasterRepository(prefs),
        ),
        Provider<PersistentServiceTypeRepository>(
          create: (_) => PersistentServiceTypeRepository(prefs),
        ),

        ChangeNotifierProvider(
          create: (ctx) => OrderListNotifier(ctx.read<OrderRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ClientListNotifier(ctx.read<ClientRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DictionariesNotifier(
            ctx.read<ClientRepository>(),
            ctx.read<PersistentMasterRepository>(),
            ctx.read<PersistentServiceTypeRepository>(),
          ),
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
        // ------------------ Заказы ------------------
        GoRoute(
          path: '/orders',
          builder: (context, state) =>
              OrdersScreen(urlParams: state.uri.queryParameters),
          routes: [
            GoRoute(path: 'new', builder: (_, _) => const OrderFormScreen()),
            GoRoute(
              path: ':id/edit',
              builder: (_, s) => OrderFormScreen(
                id: int.tryParse(s.pathParameters['id'] ?? ''),
              ),
            ),
            GoRoute(
              path: ':id',
              builder: (_, s) =>
                  OrderDetailsScreen(id: int.parse(s.pathParameters['id']!)),
            ),
          ],
        ),

        // ------------------ Клиенты ------------------
        GoRoute(
          path: '/clients',
          builder: (context, state) => const ClientsScreen(),
          routes: [
            GoRoute(path: 'new', builder: (_, _) => const ClientFormScreen()),
            GoRoute(
              path: ':id/edit',
              builder: (_, s) => ClientFormScreen(
                id: int.tryParse(s.pathParameters['id'] ?? ''),
              ),
            ),
            GoRoute(
              path: ':id',
              builder: (_, s) =>
                  ClientDetailsScreen(id: int.parse(s.pathParameters['id']!)),
            ),
          ],
        ),

        // ------------------ Мастера ------------------
        GoRoute(
          path: '/masters',
          builder: (_, _) => const MastersScreen(),
          routes: [
            GoRoute(path: 'new', builder: (_, _) => const MasterFormScreen()),
            GoRoute(
              path: ':id/edit',
              builder: (_, s) => MasterFormScreen(
                id: int.tryParse(s.pathParameters['id'] ?? ''),
              ),
            ),
          ],
        ),

        // ------------------ Услуги ------------------
        GoRoute(
          path: '/services',
          builder: (_, _) => const ServiceTypesScreen(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (_, _) => const ServiceTypeFormScreen(),
            ),
            GoRoute(
              path: ':id/edit',
              builder: (_, s) => ServiceTypeFormScreen(
                id: int.tryParse(s.pathParameters['id'] ?? ''),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
