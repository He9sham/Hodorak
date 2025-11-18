import 'package:hodorak/core/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/supabase_attendance.dart';
import '../supabase/supabase_service.dart';
import '../utils/logger.dart';
import 'supabase_insights_service.dart';

class SupabaseAttendanceService {
  final SupabaseClient _client = SupabaseService.client;

  // Check in user
  Future<SupabaseAttendance> checkIn({
    required String userId,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      Logger.debug('SupabaseAttendanceService: Checking in user $userId');

      // Check if user already checked in today and hasn't checked out
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final existingAttendance = await _client
          .from(SupabaseConfig.attendanceTable)
          .select()
          .eq('user_id', userId)
          .gte('check_in', startOfDay.toIso8601String())
          .lt('check_in', endOfDay.toIso8601String())
          .isFilter('check_out', null)
          .maybeSingle();

      if (existingAttendance != null) {
        throw Exception('You are already checked in. Please check out first.');
      }

      // Create new attendance record
      final attendanceData = {
        'user_id': userId,
        'check_in': DateTime.now().toIso8601String(),
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from(SupabaseConfig.attendanceTable)
          .insert(attendanceData)
          .select()
          .single();

      // Sync with insights
      final insightsService = SupabaseInsightsService();
      await insightsService.syncAttendanceInsights(
        userId: userId,
        date: DateTime.now(),
      );

      Logger.info(
        'SupabaseAttendanceService: User $userId checked in successfully',
      );
      return SupabaseAttendance.fromJson(response);
    } catch (e) {
      Logger.error('SupabaseAttendanceService: Check in failed: $e');
      rethrow;
    }
  }

  // Check out user
  Future<SupabaseAttendance> checkOut({
    required String userId,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      Logger.debug('SupabaseAttendanceService: Checking out user $userId');

      // Find today's check-in record that hasn't been checked out
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final attendanceRecord = await _client
          .from(SupabaseConfig.attendanceTable)
          .select()
          .eq('user_id', userId)
          .gte('check_in', startOfDay.toIso8601String())
          .lt('check_in', endOfDay.toIso8601String())
          .isFilter('check_out', null)
          .single();

      // Update the record with check-out time
      final response = await _client
          .from(SupabaseConfig.attendanceTable)
          .update({
            'check_out': DateTime.now().toIso8601String(),
            'location': location ?? attendanceRecord['location'],
            'latitude': latitude ?? attendanceRecord['latitude'],
            'longitude': longitude ?? attendanceRecord['longitude'],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', attendanceRecord['id'])
          .select()
          .single();

      // Sync with insights
      final insightsService = SupabaseInsightsService();
      await insightsService.syncAttendanceInsights(
        userId: userId,
        date: DateTime.now(),
      );

      Logger.info(
        'SupabaseAttendanceService: User $userId checked out successfully',
      );
      return SupabaseAttendance.fromJson(response);
    } catch (e) {
      Logger.error('SupabaseAttendanceService: Check out failed: $e');
      rethrow;
    }
  }

  // Get current user's attendance for a specific date
  Future<List<SupabaseAttendance>> getCurrentUserAttendanceForDate(
    DateTime date,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      Logger.debug(
        'SupabaseAttendanceService: Fetching attendance for user $userId on $date',
      );

      final data = await _client
          .from(SupabaseConfig.attendanceTable)
          .select()
          .eq('user_id', userId)
          .gte('check_in', startOfDay.toIso8601String())
          .lt('check_in', endOfDay.toIso8601String())
          .order('check_in', ascending: false);

      final attendance = (data as List)
          .map((record) => SupabaseAttendance.fromJson(record))
          .toList();

      Logger.info(
        'SupabaseAttendanceService: Found ${attendance.length} attendance records for user $userId on $date',
      );

      return attendance;
    } catch (e) {
      Logger.error(
        'SupabaseAttendanceService: Error fetching attendance for date $date: $e',
      );
      rethrow;
    }
  }

  // Get all attendance records for a user
  Future<List<SupabaseAttendance>> getUserAttendance({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      dynamic query = _client
          .from(SupabaseConfig.attendanceTable)
          .select()
          .eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('check_in', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('check_in', endDate.toIso8601String());
      }

      query = query.order('check_in', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final data = await query;

      return (data as List)
          .map((record) => SupabaseAttendance.fromJson(record))
          .toList();
    } catch (e) {
      Logger.error(
        'SupabaseAttendanceService: Error fetching user attendance: $e',
      );
      rethrow;
    }
  }

  // Get all attendance records (admin only)
  Future<List<SupabaseAttendance>> getAllAttendance({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      dynamic query = _client
          .from(SupabaseConfig.attendanceTable)
          .select('*, users(name, email)');

      if (startDate != null) {
        query = query.gte('check_in', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('check_in', endDate.toIso8601String());
      }

      query = query.order('check_in', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final data = await query;

      return (data as List)
          .map((record) => SupabaseAttendance.fromJson(record))
          .toList();
    } catch (e) {
      Logger.error(
        'SupabaseAttendanceService: Error fetching all attendance: $e',
      );
      rethrow;
    }
  }

  // Get all attendance records with user information (admin only)
  Future<List<dynamic>> getAllAttendanceWithUsers({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      dynamic query = _client
          .from(SupabaseConfig.attendanceTable)
          .select('*, users(name, email)');

      if (startDate != null) {
        query = query.gte('check_in', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('check_in', endDate.toIso8601String());
      }

      query = query.order('check_in', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final data = await query;

      return data as List<dynamic>;
    } catch (e) {
      Logger.error(
        'SupabaseAttendanceService: Error fetching all attendance with users: $e',
      );
      rethrow;
    }
  }

  // Get attendance statistics for a user
  Future<Map<String, dynamic>> getAttendanceStats({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final attendance = await getUserAttendance(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      int totalDays = 0;
      int presentDays = 0;
      Duration totalWorkingHours = Duration.zero;
      int lateDays = 0;

      final groupedAttendance = <String, List<SupabaseAttendance>>{};

      for (final record in attendance) {
        final dateKey =
            '${record.checkIn.year}-${record.checkIn.month.toString().padLeft(2, '0')}-${record.checkIn.day.toString().padLeft(2, '0')}';
        groupedAttendance.putIfAbsent(dateKey, () => []).add(record);
      }

      for (final dayAttendance in groupedAttendance.values) {
        totalDays++;
        final hasCheckIn = dayAttendance.isNotEmpty;

        if (hasCheckIn) {
          presentDays++;

          // Calculate working hours
          for (final record in dayAttendance) {
            if (record.checkOut != null) {
              totalWorkingHours += record.workingDuration ?? Duration.zero;
            }
          }

          // Check for late arrival (assuming 9 AM is standard start time)
          final earliestCheckIn = dayAttendance
              .map((record) => record.checkIn)
              .reduce((a, b) => a.isBefore(b) ? a : b);

          if (earliestCheckIn.hour > 9 ||
              (earliestCheckIn.hour == 9 && earliestCheckIn.minute > 0)) {
            lateDays++;
          }
        }
      }

      return {
        'total_days': totalDays,
        'present_days': presentDays,
        'absent_days': totalDays - presentDays,
        'total_working_hours': totalWorkingHours.inMinutes / 60,
        'late_days': lateDays,
        'attendance_rate': totalDays > 0 ? (presentDays / totalDays) * 100 : 0,
      };
    } catch (e) {
      Logger.error('SupabaseAttendanceService: Error calculating stats: $e');
      rethrow;
    }
  }

  // Delete attendance record (admin only)
  Future<void> deleteAttendanceRecord(String attendanceId) async {
    try {
      await _client
          .from(SupabaseConfig.attendanceTable)
          .delete()
          .eq('id', attendanceId);

      Logger.info(
        'SupabaseAttendanceService: Attendance record $attendanceId deleted',
      );
    } catch (e) {
      Logger.error(
        'SupabaseAttendanceService: Error deleting attendance record: $e',
      );
      rethrow;
    }
  }
}
