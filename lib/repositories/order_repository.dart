import '../models/order_query.dart';
import '../models/page_result.dart';
import '../models/repair_order.dart';

abstract interface class OrderRepository {
  Future<PageResult<RepairOrder>> find(OrderQuery query);
  Future<RepairOrder?> findById(int id);
  Future<RepairOrder> create(RepairOrder order);
  Future<RepairOrder> update(RepairOrder order);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}
