import 'package:get_it/get_it.dart';
import 'package:hodorak/core/odoo_service/odoo_http_service.dart';
import 'package:hodorak/core/services/firebase_leave_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register Odoo Service
  getIt.registerLazySingleton<OdooHttpService>(() => OdooHttpService());

  // Register Firebase Leave Service
  getIt.registerLazySingleton<FirebaseLeaveService>(
    () => FirebaseLeaveService(),
  );
}

// Helper functions for easy access
OdooHttpService get odooService => getIt<OdooHttpService>();
FirebaseLeaveService get firebaseLeaveService => getIt<FirebaseLeaveService>();
