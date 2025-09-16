import 'dart:convert';

import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/services/file_storage_service.dart';

class CalendarServiceFallback {
  final FileStorageService _storage = FileStorageService();

  /// Save daily attendance summary to persistent storage
  Future<void> saveDailySummary(DailyAttendanceSummary summary) async {
    final calendarData = await getCalendarData();
    final dateKey = _getDateKey(summary.date);
    calendarData[dateKey] = summary.toJson();
    await _storage.saveData(calendarData);
  }

  /// Get all calendar data from persistent storage
  Future<Map<String, dynamic>> getCalendarData() async {
    final data = await _storage.loadData();
    return Map<String, dynamic>.from(data);
  }

  /// Get daily summary for a specific date
  Future<DailyAttendanceSummary?> getDailySummary(DateTime date) async {
    final calendarData = await getCalendarData();
    final dateKey = _getDateKey(date);
    final summaryData = calendarData[dateKey];

    if (summaryData == null) {
      return null;
    }

    try {
      return DailyAttendanceSummary.fromJson(summaryData);
    } catch (e) {
      return null;
    }
  }

  /// Get summaries for a date range
  Future<List<DailyAttendanceSummary>> getSummariesInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final calendarData = await getCalendarData();
    final summaries = <DailyAttendanceSummary>[];

    for (final entry in calendarData.entries) {
      try {
        final summary = DailyAttendanceSummary.fromJson(entry.value);
        if (summary.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            summary.date.isBefore(endDate.add(const Duration(days: 1)))) {
          summaries.add(summary);
        }
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }

    summaries.sort((a, b) => b.date.compareTo(a.date));
    return summaries;
  }

  /// Get monthly summary
  Future<Map<String, dynamic>> getMonthlySummary(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    final summaries = await getSummariesInRange(startDate, endDate);

    int totalDays = 0;
    int totalPresent = 0;
    int totalAbsent = 0;
    double totalPercentage = 0.0;

    for (final summary in summaries) {
      totalDays++;
      totalPresent += summary.presentEmployees;
      totalAbsent += summary.absentEmployees;
      totalPercentage += summary.attendancePercentage;
    }

    return {
      'year': year,
      'month': month,
      'total_days': totalDays,
      'total_present': totalPresent,
      'total_absent': totalAbsent,
      'average_percentage': totalDays > 0 ? totalPercentage / totalDays : 0.0,
      'summaries': summaries.map((s) => s.toJson()).toList(),
    };
  }

  /// Clear all calendar data
  Future<void> clearAllData() async {
    await _storage.clearData();
  }

  /// Export calendar data as JSON
  Future<String> exportData() async {
    final calendarData = await getCalendarData();
    return jsonEncode(calendarData);
  }

  /// Import calendar data from JSON
  Future<void> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData);
      if (data is Map<String, dynamic>) {
        await _storage.saveData(Map<String, dynamic>.from(data));
      } else {
        throw Exception('Invalid data format');
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  /// Get date key for storage
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
