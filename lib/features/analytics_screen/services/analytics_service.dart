import 'package:flutter/material.dart';
import 'package:hodorak/core/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/attendance_stats.dart';

class AnalyticsService {
  final SupabaseClient _supabase;

  AnalyticsService(this._supabase);

  Future<AttendanceStats> getDailyStats(DateTime date) async {
    debugPrint('Fetching daily stats for date: ${date.toString()}');
    try {
      // First, get all users to account for absent employees
      final users = await _supabase
          .from(SupabaseConfig.usersTable)
          .select('id, is_admin')
          .eq('is_admin', false);

      final usersList = List<Map<String, dynamic>>.from(users);
      final totalUsers = usersList.length;
      debugPrint('Total users found: $totalUsers');

      if (totalUsers == 0) {
        return AttendanceStats(
          present: 0,
          late: 0,
          absent: 0,
          date: date,
          totalHours: 0,
        );
      }

      // Get attendance records for the day
      final response = await _supabase
          .from(SupabaseConfig.attendanceTable)
          .select('status, check_in, check_out')
          .gte('check_in', date.toIso8601String().split('T')[0])
          .lt(
            'check_in',
            date.add(Duration(days: 1)).toIso8601String().split('T')[0],
          );

      final records = List<Map<String, dynamic>>.from(response);
      debugPrint('Found ${records.length} attendance records for today');

      int present = 0;
      int late = 0;
      int absent = 0;
      double totalHours = 0;

      for (var record in records) {
        switch (record['status']) {
          case 'present':
            present++;
            break;
          case 'late':
            late++;
            break;
          case 'absent':
            absent++;
            break;
        }

        if (record['check_in'] != null && record['check_out'] != null) {
          final checkIn = DateTime.parse(record['check_in']);
          final checkOut = DateTime.parse(record['check_out']);
          totalHours += checkOut.difference(checkIn).inHours;
        }
      }

      // Calculate absent as total users minus present and late
      absent = totalUsers - (present + late);

      return AttendanceStats(
        present: present,
        late: late,
        absent: absent,
        date: date,
        totalHours: totalHours,
      );
    } catch (e) {
      debugPrint('Error fetching daily stats: $e');
      rethrow;
    }
  }

  Future<WeeklyStats> getWeeklyStats() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final dailyStats = <AttendanceStats>[];
      double totalHours = 0;
      int totalPresent = 0;
      int totalEmployees = 0;

      for (var i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final stats = await getDailyStats(date);
        dailyStats.add(stats);
        totalHours += stats.totalHours;
        totalPresent += stats.present;
        totalEmployees += stats.present + stats.late + stats.absent;
      }

      final averageAttendance = totalEmployees > 0
          ? (totalPresent / totalEmployees) * 100
          : 0;

      return WeeklyStats(
        dailyStats: dailyStats,
        averageAttendance: averageAttendance.toDouble(),
        totalHours: totalHours,
      );
    } catch (e) {
      rethrow;
    }
  }
}
