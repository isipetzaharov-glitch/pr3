// test/widget_test.dart
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/repositories/client_repository.dart';
import 'package:flutter_application_1/repositories/in_memory_client_repository.dart';
import 'package:flutter_application_1/repositories/in_memory_order_repository.dart';
import 'package:flutter_application_1/repositories/order_repository.dart';
import 'package:flutter_application_1/state/client_list_notifier.dart';
import 'package:flutter_application_1/state/order_list_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Приложение Автосервис открывается без ошибок', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
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

    // Первый кадр отрисовался
    expect(find.text('Автосервис'), findsOneWidget);
  });
}
