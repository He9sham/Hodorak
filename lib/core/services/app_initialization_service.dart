import 'package:hodorak/core/services/service_locator.dart';
import 'package:hodorak/core/supabase/supabase_service.dart';

/// Service responsible for initializing the application
class AppInitializationService {
  /// Initialize all required services for the app
  static Future<void> initialize() async {
    // Initialize Supabase
    await SupabaseService.initialize();

    // Setup service locator
    await setupServiceLocator();

    // Initialize Firebase Messaging service
    await firebaseMessagingService.initialize();
  }
}
