import 'package:flutter/material.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/services/calendar_service.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:hodorak/features/calender_screen/utils/date_utils.dart';

/// Helper functions for calendar screen operations

class CalendarHelpers {
  /// Show error message using SnackBar
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Show success message using SnackBar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  /// Create a test summary for a given date
  static Future<DailyAttendanceSummary> createTestSummaryForDate(
    DateTime date,
  ) async {
    final testSummary = DailyAttendanceSummary(
      date: date,
      employeeAttendances: [
        EmployeeAttendance(
          employeeId: 1,
          employeeName: 'Test Employee',
          checkIn: DateTime(date.year, date.month, date.day, 9, 0),
          checkOut: DateTime(date.year, date.month, date.day, 17, 0),
          isPresent: true,
          workingHours: const Duration(hours: 8),
        ),
      ],
      totalEmployees: 1,
      presentEmployees: 1,
      absentEmployees: 0,
      attendancePercentage: 100.0,
    );

    // Save to calendar service for persistence
    try {
      final calendarService = CalendarService();
      await calendarService.saveDailySummary(testSummary);
      Logger.info('Saved test summary to calendar service for $date');
    } catch (e) {
      Logger.error('Error saving test summary: $e');
    }

    return testSummary;
  }

  /// Validate if a date has attendance data
  static bool hasAttendanceData(
    Map<DateTime, List<DailyAttendanceSummary>> events,
    DateTime date,
  ) {
    final day = CalendarDateUtils.createDateKey(date);
    return events[day] != null && events[day]!.isNotEmpty;
  }

  /// Get attendance data for a specific date
  static List<DailyAttendanceSummary> getAttendanceDataForDate(
    Map<DateTime, List<DailyAttendanceSummary>> events,
    DateTime date,
  ) {
    final day = CalendarDateUtils.createDateKey(date);
    return events[day] ?? [];
  }

  /// Add attendance summary to events map
  static void addAttendanceToEvents(
    Map<DateTime, List<DailyAttendanceSummary>> events,
    DailyAttendanceSummary summary,
  ) {
    final day = CalendarDateUtils.createDateKey(summary.date);
    if (events[day] != null) {
      events[day]!.add(summary);
    } else {
      events[day] = [summary];
    }
  }

  /// Clear all events from the events map
  static void clearEvents(Map<DateTime, List<DailyAttendanceSummary>> events) {
    events.clear();
  }

  /// Get total record count for a date
  static int getRecordCountForDate(
    Map<DateTime, List<DailyAttendanceSummary>> events,
    DateTime date,
  ) {
    final day = CalendarDateUtils.createDateKey(date);
    return events[day]?.length ?? 0;
  }
}
