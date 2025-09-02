import 'dart:convert';

import 'package:hodorak/models/daily_attendance_summary.dart';

class CalendarServiceFallback {
  static Map<String, dynamic> _memoryStorage = {};

  /// Save daily attendance summary to memory
  Future<void> saveDailySummary(DailyAttendanceSummary summary) async {
    // Get existing calendar data
    final calendarData = await getCalendarData();

    // Add or update the summary for the date
    final dateKey = _getDateKey(summary.date);
    calendarData[dateKey] = summary.toJson();

    // Save to memory
    _memoryStorage = calendarData;
  }

  /// Get all calendar data from memory
  Future<Map<String, dynamic>> getCalendarData() async {
    return Map<String, dynamic>.from(_memoryStorage);
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
    _memoryStorage.clear();
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
        _memoryStorage = data;
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
