import 'package:get_it/get_it.dart';
import 'package:hodorak/core/services/firebase_messaging_service.dart';
import 'package:hodorak/core/services/notification_memory_service.dart';
import 'package:hodorak/core/services/onboarding_service.dart';
import 'package:hodorak/core/services/supabase_attendance_service.dart';
import 'package:hodorak/core/services/supabase_auth_service.dart';
import 'package:hodorak/core/services/supabase_calendar_service.dart';
import 'package:hodorak/core/services/supabase_company_service.dart';
import 'package:hodorak/core/services/supabase_leave_service.dart';
import 'package:hodorak/core/services/supabase_notification_service.dart';
import 'package:hodorak/core/services/supabase_setup_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register Supabase Services
  getIt.registerLazySingleton<SupabaseAuthService>(() => SupabaseAuthService());
  getIt.registerLazySingleton<SupabaseAttendanceService>(
    () => SupabaseAttendanceService(),
  );
  getIt.registerLazySingleton<SupabaseCalendarService>(
    () => SupabaseCalendarService(),
  );
  getIt.registerLazySingleton<SupabaseCompanyService>(
    () => SupabaseCompanyService(),
  );
  getIt.registerLazySingleton<SupabaseLeaveService>(
    () => SupabaseLeaveService(),
  );
  getIt.registerLazySingleton<SupabaseNotificationService>(
    () => SupabaseNotificationService(),
  );

  // Register Firebase Messaging Service
  getIt.registerLazySingleton<FirebaseMessagingService>(
    () => FirebaseMessagingService(),
  );

  // Register Notification Memory Service
  getIt.registerLazySingleton<NotificationMemoryService>(
    () => NotificationMemoryService(),
  );

  // Register Onboarding Service
  getIt.registerLazySingleton<OnboardingService>(() => OnboardingService());
}

// Helper functions for easy access
SupabaseAuthService get supabaseAuthService => getIt<SupabaseAuthService>();
SupabaseAttendanceService get supabaseAttendanceService =>
    getIt<SupabaseAttendanceService>();
SupabaseCalendarService get supabaseCalendarService =>
    getIt<SupabaseCalendarService>();
SupabaseCompanyService get supabaseCompanyService =>
    getIt<SupabaseCompanyService>();
SupabaseNotificationService get supabaseNotificationService =>
    getIt<SupabaseNotificationService>();
SupabaseSetupService get supabaseSetupService => getIt<SupabaseSetupService>();
FirebaseMessagingService get firebaseMessagingService =>
    getIt<FirebaseMessagingService>();
NotificationMemoryService get notificationMemoryService =>
    getIt<NotificationMemoryService>();
OnboardingService get onboardingService => getIt<OnboardingService>();
