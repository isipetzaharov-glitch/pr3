// test/widget_test.dart
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/repositories/client_repository.dart';
import 'package:flutter_application_1/repositories/order_repository.dart';
import 'package:flutter_application_1/repositories/persistent_client_repository.dart';
import 'package:flutter_application_1/repositories/persistent_master_repository.dart';
import 'package:flutter_application_1/repositories/persistent_repair_order_repository.dart';
import 'package:flutter_application_1/repositories/persistent_service_type_repository.dart';
import 'package:flutter_application_1/state/client_list_notifier.dart';
import 'package:flutter_application_1/state/dictionaries_notifier.dart';
import 'package:flutter_application_1/state/order_list_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Приложение Автосервис открывается без ошибок', (
    WidgetTester tester,
  ) async {
    // Заглушка SharedPreferences для тестовой среды
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
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

    // Даём асинхронным загрузкам завершиться
    await tester.pump(const Duration(milliseconds: 300));

    // На экране должен быть заголовок приложения
    expect(find.text('Автосервис'), findsOneWidget);
  });
}
