import 'package:hodorak/core/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_service.dart';
import '../utils/logger.dart';

class SupabaseSetupService {
  final SupabaseClient _client = SupabaseService.client;

  /// Check if the database is properly set up
  Future<bool> isDatabaseSetup() async {
    try {
      // Try to query the users table to see if it exists and has data
      final response = await _client
          .from(SupabaseConfig.usersTable)
          .select('count')
          .limit(1);

      if (response.isEmpty) {
        Logger.error('SupabaseSetupService: Database not set up: No data returned');
        return false;
      }

      return true;
    } catch (e) {
      Logger.error('SupabaseSetupService: Database check failed: $e');
      return false;
    }
  }

  /// Create the first admin user manually
  Future<bool> createAdminUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      Logger.info('SupabaseSetupService: Creating admin user...');

      // Sign up the user
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );

      if (authResponse.user == null && authResponse.session == null) {
        Logger.error('SupabaseSetupService: Failed to create auth user');
        return false;
      }

      if (authResponse.user == null) {
        Logger.error('SupabaseSetupService: No user returned from signup');
        return false;
      }

      // Create user profile with admin privileges
      final userData = {
        'id': authResponse.user!.id,
        'email': email,
        'name': name,
        'job_title': 'System Administrator',
        'department': 'IT',
        'is_admin': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final profileResponse = await _client
          .from(SupabaseConfig.usersTable)
          .insert(userData);

      if (profileResponse.isEmpty) {
        Logger.error('SupabaseSetupService: Failed to create user profile');
        return false;
      }

      Logger.info('SupabaseSetupService: Admin user created successfully');
      return true;
    } catch (e) {
      Logger.error('SupabaseSetupService: Failed to create admin user: $e');
      return false;
    }
  }

  /// Get setup status information
  Future<Map<String, dynamic>> getSetupStatus() async {
    try {
      final isSetup = await isDatabaseSetup();
      
      // Get user count
      final userCountResponse = await _client
          .from(SupabaseConfig.usersTable)
          .select('id');

      final totalUsers = userCountResponse.length;

      // Check for admin users
      final adminUsersResponse = await _client
          .from(SupabaseConfig.usersTable)
          .select('id')
          .eq('is_admin', true);

      final adminCount = adminUsersResponse.length;

      return {
        'is_setup': isSetup,
        'total_users': totalUsers,
        'admin_users': adminCount,
        'needs_admin': adminCount == 0,
        'database_ready': isSetup,
      };
    } catch (e) {
      Logger.error('SupabaseSetupService: Failed to get setup status: $e');
      return {
        'is_setup': false,
        'total_users': 0,
        'admin_users': 0,
        'needs_admin': true,
        'database_ready': false,
        'error': e.toString(),
      };
    }
  }

  /// Create sample data for testing
  Future<void> createSampleData() async {
    try {
      Logger.info('SupabaseSetupService: Creating sample data...');

      // Get all users
      final usersResponse = await _client
          .from(SupabaseConfig.usersTable)
          .select('id, name');

      if (usersResponse.isEmpty) {
        Logger.warning('SupabaseSetupService: No users found for sample data creation');
        return;
      }

      // Create sample attendance records
      await _createSampleAttendance(usersResponse);
      
      // Create sample calendar events
      await _createSampleCalendarEvents(usersResponse);

      Logger.info('SupabaseSetupService: Sample data created successfully');
    } catch (e) {
      Logger.error('SupabaseSetupService: Failed to create sample data: $e');
      rethrow;
    }
  }

  Future<void> _createSampleAttendance(List<dynamic> users) async {
    try {
      final now = DateTime.now();
      final attendanceRecords = <Map<String, dynamic>>[];

      for (final user in users) {
        final userId = user['id'] as String;
        // final userName = user['name'] as String; // Unused for now

        // Create attendance records for the last 7 days
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: i));
          final weekday = date.weekday;

          // Skip weekends
          if (weekday == 6 || weekday == 7) continue;

          final checkIn = DateTime(date.year, date.month, date.day, 9, 0)
              .add(Duration(minutes: (i % 3) * 15));
          final checkOut = DateTime(date.year, date.month, date.day, 17, 0)
              .add(Duration(minutes: (i % 2) * 30));

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
      }

      if (attendanceRecords.isNotEmpty) {
        final response = await _client
            .from(SupabaseConfig.attendanceTable)
            .insert(attendanceRecords);

        if (response.isEmpty) {
          Logger.error('SupabaseSetupService: Failed to create attendance records');
        } else {
          Logger.info('SupabaseSetupService: Created ${attendanceRecords.length} attendance records');
        }
      }
    } catch (e) {
      Logger.error('SupabaseSetupService: Failed to create sample attendance: $e');
    }
  }

  Future<void> _createSampleCalendarEvents(List<dynamic> users) async {
    try {
      final now = DateTime.now();
      final events = <Map<String, dynamic>>[];

      for (final user in users) {
        final userId = user['id'] as String;
        // final userName = user['name'] as String; // Unused for now

        // Create events for the next 7 days
        for (int i = 0; i < 7; i++) {
          final date = now.add(Duration(days: i));
          final weekday = date.weekday;

          // Skip weekends
          if (weekday == 6 || weekday == 7) continue;

          final eventTypes = ['meeting', 'task', 'training', 'break'];
          final eventType = eventTypes[i % eventTypes.length];

          final startTime = DateTime(date.year, date.month, date.day, 10, 0)
              .add(Duration(hours: i % 6));
          final endTime = startTime.add(Duration(hours: 1));

          events.add({
            'title': '$eventType for ${user['name']}',
            'description': 'Sample $eventType event on ${date.toString().split(' ')[0]}',
            'start_time': startTime.toIso8601String(),
            'end_time': endTime.toIso8601String(),
            'user_id': userId,
            'location': 'Office Building A',
            'event_type': eventType,
            'metadata': {
              'priority': i % 3,
              'category': eventType,
            },
            'created_at': startTime.toIso8601String(),
            'updated_at': startTime.toIso8601String(),
          });
        }
      }

      if (events.isNotEmpty) {
        final response = await _client
            .from(SupabaseConfig.calendarEventsTable)
            .insert(events);

        if (response.isEmpty) {
          Logger.error('SupabaseSetupService: Failed to create calendar events');
        } else {
          Logger.info('SupabaseSetupService: Created ${events.length} calendar events');
        }
      }
    } catch (e) {
      Logger.error('SupabaseSetupService: Failed to create sample calendar events: $e');
    }
  }
}
