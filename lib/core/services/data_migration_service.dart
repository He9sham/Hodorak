import 'package:hodorak/core/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import '../supabase/supabase_service.dart';
import '../utils/logger.dart';

class DataMigrationService {
  final SupabaseClient _client = SupabaseService.client;

  /// Migrate all users from Odoo to Supabase
  Future<void> migrateUsers() async {
    try {
      Logger.info('DataMigrationService: Starting user migration...');

      // This would typically fetch from your Odoo API
      // For now, we'll create a sample admin user
      await _createSampleAdminUser();

      Logger.info('DataMigrationService: User migration completed');
    } catch (e) {
      Logger.error('DataMigrationService: User migration failed: $e');
      rethrow;
    }
  }

  /// Create a sample admin user for testing
  Future<void> _createSampleAdminUser() async {
    try {
      Logger.info('DataMigrationService: Creating sample admin user...');

      // Note: In a real migration, you would create users through Supabase Auth
      // For now, we'll just create a user profile that can be linked to an auth user later

      // Generate a UUID for the user
      final userId = '00000000-0000-0000-0000-000000000001';

      // Create the user profile
      final userData = {
        'id': userId,
        'email': 'admin@hodorak.com',
        'name': 'Admin User',
        'job_title': 'System Administrator',
        'department': 'IT',
        'phone': '+1234567890',
        'national_id': 'ADMIN001',
        'gender': 'Other',
        'is_admin': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from(SupabaseConfig.usersTable)
          .upsert(userData); // Use upsert to avoid conflicts

      if (response.isEmpty) {
        Logger.error('DataMigrationService: Failed to create user profile');
        return;
      }

      Logger.info(
        'DataMigrationService: Sample admin user profile created successfully',
      );
      Logger.info(
        'DataMigrationService: To complete setup, create auth user with email: admin@hodorak.com',
      );
    } catch (e) {
      Logger.error(
        'DataMigrationService: Failed to create sample admin user: $e',
      );
    }
  }

  /// Migrate attendance records from Odoo to Supabase
  Future<void> migrateAttendance() async {
    try {
      Logger.info('DataMigrationService: Starting attendance migration...');

      // Get all users first
      final users = await _client
          .from(SupabaseConfig.usersTable)
          .select('id, name');

      if (users.isEmpty) {
        Logger.warning(
          'DataMigrationService: No users found for attendance migration',
        );
        return;
      }

      // Create sample attendance records for each user
      for (final user in users) {
        await _createSampleAttendanceForUser(
          user['id'] as String,
          user['name'] as String,
        );
      }

      Logger.info('DataMigrationService: Attendance migration completed');
    } catch (e) {
      Logger.error('DataMigrationService: Attendance migration failed: $e');
      rethrow;
    }
  }

  /// Create sample attendance records for a user
  Future<void> _createSampleAttendanceForUser(
    String userId,
    String userName,
  ) async {
    try {
      final now = DateTime.now();
      final attendanceRecords = <Map<String, dynamic>>[];

      // Create attendance records for the last 30 days
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        final weekday = date.weekday;

        // Skip weekends
        if (weekday == 6 || weekday == 7) continue;

        // Randomly skip some days (simulate absences)
        if (DateTime.now().millisecondsSinceEpoch % 10 == 0) continue;

        final checkIn = DateTime(date.year, date.month, date.day, 9, 0).add(
          Duration(minutes: (i % 3) * 15),
        ); // Some variation in check-in time
        final checkOut = DateTime(date.year, date.month, date.day, 17, 0).add(
          Duration(minutes: (i % 2) * 30),
        ); // Some variation in check-out time

        attendanceRecords.add({
          'user_id': userId,
          'check_in': checkIn.toIso8601String(),
          'check_out': checkOut.toIso8601String(),
          'location': 'Office Building A',
          'latitude': 37.7749 + (i % 10) * 0.001,
          'longitude': -122.4194 + (i % 10) * 0.001,
          'created_at': checkIn.toIso8601String(),
          'updated_at': checkOut.toIso8601String(),
        });
      }

      if (attendanceRecords.isNotEmpty) {
        final response = await _client
            .from(SupabaseConfig.attendanceTable)
            .insert(attendanceRecords);

        if (response.isEmpty) {
          Logger.error(
            'DataMigrationService: Failed to create attendance for $userName',
          );
        } else {
          Logger.info(
            'DataMigrationService: Created ${attendanceRecords.length} attendance records for $userName',
          );
        }
      }
    } catch (e) {
      Logger.error(
        'DataMigrationService: Failed to create sample attendance for user: $e',
      );
    }
  }

  /// Migrate calendar events from Odoo to Supabase
  Future<void> migrateCalendarEvents() async {
    try {
      Logger.info(
        'DataMigrationService: Starting calendar events migration...',
      );

      // Get all users first
      final users = await _client
          .from(SupabaseConfig.usersTable)
          .select('id, name');

      if (users.isEmpty) {
        Logger.warning(
          'DataMigrationService: No users found for calendar migration',
        );
        return;
      }

      // Create sample calendar events for each user
      for (final user in users) {
        await _createSampleCalendarEventsForUser(
          user['id'] as String,
          user['name'] as String,
        );
      }

      Logger.info('DataMigrationService: Calendar events migration completed');
    } catch (e) {
      Logger.error(
        'DataMigrationService: Calendar events migration failed: $e',
      );
      rethrow;
    }
  }

  /// Create sample calendar events for a user
  Future<void> _createSampleCalendarEventsForUser(
    String userId,
    String userName,
  ) async {
    try {
      final now = DateTime.now();
      final events = <Map<String, dynamic>>[];

      // Create various types of events for the last 30 days
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        final weekday = date.weekday;

        // Skip weekends
        if (weekday == 6 || weekday == 7) continue;

        final eventTypes = ['meeting', 'task', 'training', 'break'];
        final eventType = eventTypes[i % eventTypes.length];

        final startTime = DateTime(
          date.year,
          date.month,
          date.day,
          10,
          0,
        ).add(Duration(hours: i % 6));
        final endTime = startTime.add(Duration(hours: 1));

        events.add({
          'title': '$eventType for $userName',
          'description':
              'Sample $eventType event on ${date.toString().split(' ')[0]}',
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'user_id': userId,
          'location': 'Office Building A',
          'event_type': eventType,
          'metadata': {'priority': i % 3, 'category': eventType},
          'created_at': startTime.toIso8601String(),
          'updated_at': startTime.toIso8601String(),
        });
      }

      if (events.isNotEmpty) {
        final response = await _client
            .from(SupabaseConfig.calendarEventsTable)
            .insert(events);

        if (response.isEmpty) {
          Logger.error(
            'DataMigrationService: Failed to create calendar events for $userName',
          );
        } else {
          Logger.info(
            'DataMigrationService: Created ${events.length} calendar events for $userName',
          );
        }
      }
    } catch (e) {
      Logger.error(
        'DataMigrationService: Failed to create sample calendar events for user: $e',
      );
    }
  }

  /// Run complete migration
  Future<void> runCompleteMigration() async {
    try {
      Logger.info('DataMigrationService: Starting complete migration...');

      await migrateUsers();
      await Future.delayed(const Duration(seconds: 1)); // Small delay

      await migrateAttendance();
      await Future.delayed(const Duration(seconds: 1));

      await migrateCalendarEvents();

      Logger.info(
        'DataMigrationService: Complete migration finished successfully!',
      );
    } catch (e) {
      Logger.error('DataMigrationService: Complete migration failed: $e');
      rethrow;
    }
  }

  /// Clear all data (for testing purposes)
  Future<void> clearAllData() async {
    try {
      Logger.warning('DataMigrationService: Clearing all data...');

      // Delete in reverse order of dependencies
      await _client
          .from(SupabaseConfig.dailySummariesTable)
          .delete()
          .neq('id', '');
      await _client
          .from(SupabaseConfig.calendarEventsTable)
          .delete()
          .neq('id', '');
      await _client.from(SupabaseConfig.attendanceTable).delete().neq('id', '');
      await _client.from(SupabaseConfig.employeesTable).delete().neq('id', '');
      await _client.from(SupabaseConfig.usersTable).delete().neq('id', '');

      Logger.info('DataMigrationService: All data cleared');
    } catch (e) {
      Logger.error('DataMigrationService: Failed to clear data: $e');
      rethrow;
    }
  }
}
