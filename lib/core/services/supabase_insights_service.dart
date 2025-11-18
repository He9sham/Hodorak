import 'package:hodorak/core/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/supabase_attendance.dart';
import '../supabase/supabase_service.dart';
import '../utils/logger.dart';
import 'supabase_attendance_service.dart';

class SupabaseInsightsService {
  final SupabaseClient _client = SupabaseService.client;
  final SupabaseAttendanceService _attendanceService =
      SupabaseAttendanceService();

  // Sync attendance with insights
  Future<void> syncAttendanceInsights({
    required String userId,
    required DateTime date,
  }) async {
    try {
      Logger.debug(
        'SupabaseInsightsService: Syncing attendance insights for user $userId on $date',
      );

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get attendance records for the day
      final List<SupabaseAttendance> attendanceRecords =
          await _attendanceService.getUserAttendance(
            userId: userId,
            startDate: startOfDay,
            endDate: endOfDay,
          );

      // Calculate total hours and determine status
      double totalHours = 0;
      String status = 'absent';
      String notes = '';

      if (attendanceRecords.isNotEmpty) {
        for (final record in attendanceRecords) {
          if (record.checkOut != null) {
            final duration = record.workingDuration ?? Duration.zero;
            totalHours += duration.inMinutes / 60;
          }
        }

        // Determine status based on first check-in time
        final firstCheckIn = attendanceRecords
            .map((record) => record.checkIn)
            .reduce((a, b) => a.isBefore(b) ? a : b);

        if (firstCheckIn.hour < 9) {
          status = 'present';
          notes = 'On time';
        } else {
          status = 'late';
          notes =
              'Late arrival at ${firstCheckIn.hour}:${firstCheckIn.minute.toString().padLeft(2, '0')}';
        }
      }

      // Check if insight already exists for this date
      final existingInsight = await _client
          .from(SupabaseConfig.dailyInsightsTable)
          .select()
          .eq('user_id', userId)
          .eq('date', startOfDay.toIso8601String())
          .maybeSingle();

      if (existingInsight != null) {
        // Update existing insight
        await _client
            .from(SupabaseConfig.dailyInsightsTable)
            .update({
              'total_hours': totalHours,
              'status': status,
              'notes': notes,
            })
            .eq('id', existingInsight['id']);
      } else {
        // Create new insight
        await _client.from(SupabaseConfig.dailyInsightsTable).insert({
          'user_id': userId,
          'date': startOfDay.toIso8601String(),
          'total_hours': totalHours,
          'status': status,
          'notes': notes,
        });
      }

      Logger.info(
        'SupabaseInsightsService: Successfully synced attendance insights for user $userId on $date',
      );
    } catch (e) {
      Logger.error(
        'SupabaseInsightsService: Error syncing attendance insights: $e',
      );
      rethrow;
    }
  }

  // Get insights for a date range
  Future<List<Map<String, dynamic>>> getInsights({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _client
          .from(SupabaseConfig.dailyInsightsTable)
          .select()
          .eq('user_id', userId)
          .gte('date', startDate?.toIso8601String() ?? '')
          .lte(
            'date',
            endDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
          )
          .order('date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      Logger.error('SupabaseInsightsService: Error fetching insights: $e');
      rethrow;
    }
  }

  // Get insights statistics
  Future<Map<String, dynamic>> getInsightsStats({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final insights = await getInsights(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      int totalDays = insights.length;
      int presentDays = insights.where((i) => i['status'] == 'present').length;
      int lateDays = insights.where((i) => i['status'] == 'late').length;
      int absentDays = insights.where((i) => i['status'] == 'absent').length;
      double totalHours = insights.fold(
        0,
        (sum, insight) => sum + (insight['total_hours'] as num),
      );

      return {
        'total_days': totalDays,
        'present_days': presentDays,
        'late_days': lateDays,
        'absent_days': absentDays,
        'total_hours': totalHours,
        'attendance_rate': totalDays > 0
            ? ((presentDays + lateDays) / totalDays) * 100
            : 0,
      };
    } catch (e) {
      Logger.error(
        'SupabaseInsightsService: Error calculating insights stats: $e',
      );
      rethrow;
    }
  }
}
