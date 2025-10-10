import 'package:get_it/get_it.dart';
import 'package:hodorak/core/services/notification_service.dart';
import 'package:hodorak/core/services/notification_storage_service.dart';
import 'package:hodorak/core/services/onboarding_service.dart';
import 'package:hodorak/core/services/supabase_attendance_service.dart';
import 'package:hodorak/core/services/supabase_auth_service.dart';
import 'package:hodorak/core/services/supabase_calendar_service.dart';
import 'package:hodorak/core/services/supabase_company_service.dart';
import 'package:hodorak/core/services/supabase_leave_service.dart';
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
  getIt.registerLazySingleton<SupabaseSetupService>(
    () => SupabaseSetupService(),
  );

  // Register Notification Service
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // Register Notification Storage Service
  getIt.registerLazySingleton<NotificationStorageService>(
    () => NotificationStorageService(),
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
SupabaseLeaveService get supabaseLeaveService => getIt<SupabaseLeaveService>();
SupabaseSetupService get supabaseSetupService => getIt<SupabaseSetupService>();
NotificationService get notificationService => getIt<NotificationService>();
NotificationStorageService get notificationStorageService =>
    getIt<NotificationStorageService>();
OnboardingService get onboardingService => getIt<OnboardingService>();
