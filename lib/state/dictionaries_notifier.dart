import 'package:flutter/foundation.dart';

import '../models/client.dart';
import '../models/master.dart';
import '../models/service_type.dart';
import '../repositories/client_repository.dart';
import '../repositories/persistent_master_repository.dart';
import '../repositories/persistent_service_type_repository.dart';

class DictionariesNotifier extends ChangeNotifier {
  final ClientRepository _clientRepo;
  final PersistentMasterRepository _masterRepo;
  final PersistentServiceTypeRepository _serviceRepo;

  DictionariesNotifier(this._clientRepo, this._masterRepo, this._serviceRepo);

  List<Client> clients = [];
  List<Master> masters = [];
  List<ServiceType> serviceTypes = [];

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final page = await _clientRepo.find(size: 1000);
    clients = page.items;
    masters = await _masterRepo.getAll();
    serviceTypes = await _serviceRepo.getAll();
    _loaded = true;
    notifyListeners();
  }
}
