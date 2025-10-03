import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/odoo_service/odoo_http_service.dart';
import 'package:hodorak/core/services/service_locator.dart';

class DailySummaryState {
  final DailyAttendanceSummary? summary;
  final bool loading;
  final String? error;

  DailySummaryState({this.summary, this.loading = false, this.error});

  DailySummaryState copyWith({
    DailyAttendanceSummary? summary,
    bool? loading,
    String? error,
  }) {
    return DailySummaryState(
      summary: summary ?? this.summary,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class DailySummaryNotifier extends Notifier<DailySummaryState> {
  final OdooHttpService odooHttpService;

  DailySummaryNotifier(this.odooHttpService);

  @override
  DailySummaryState build() {
    loadDailySummary();
    return DailySummaryState();
  }

  Future<void> loadDailySummary() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final summary = await _createDailySummary();
      state = state.copyWith(summary: summary, loading: false);
    } catch (e) {
      state = state.copyWith(
        error: "Failed to load daily summary: ${e.toString()}",
        loading: false,
      );
    }
  }

  Future<DailyAttendanceSummary> _createDailySummary() async {
    final today = DateTime.now();

    // Get current user's employee ID
    final currentUserId = odooHttpService.uid;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final employeeId = await odooHttpService.getEmployeeIdFromUserId(
      currentUserId,
    );
    if (employeeId == null) {
      throw Exception('Employee record not found for user');
    }

    // Get current user's attendance for today
    final myAttendance = await odooHttpService.getMyAttendance(employeeId);

    // Filter for today's records
    final todayAttendance = myAttendance.where((record) {
      final checkIn = _parseDateTime(record['check_in']);
      return checkIn != null && _isSameDay(checkIn, today);
    }).toList();

    // Calculate working hours for today
    Duration? totalWorkingHours;
    DateTime? checkIn;
    DateTime? checkOut;
    bool isPresent = false;

    if (todayAttendance.isNotEmpty) {
      // Get the first check-in and last check-out of the day
      final sortedAttendance = todayAttendance
        ..sort((a, b) {
          final aTime = _parseDateTime(a['check_in']) ?? DateTime(1970);
          final bTime = _parseDateTime(b['check_in']) ?? DateTime(1970);
          return aTime.compareTo(bTime);
        });

      checkIn = _parseDateTime(sortedAttendance.first['check_in']);
      final lastRecord = sortedAttendance.last;
      checkOut = _parseDateTime(lastRecord['check_out']);

      isPresent = checkIn != null;

      if (checkIn != null && checkOut != null) {
        totalWorkingHours = checkOut.difference(checkIn);
      } else if (checkIn != null) {
        // Still at work, calculate hours until now
        totalWorkingHours = DateTime.now().difference(checkIn);
      }
    }

    // Create a simplified summary with just the current user
    final employeeAttendances = [
      EmployeeAttendance(
        employeeId: employeeId,
        employeeName: 'Current User',
        checkIn: checkIn,
        checkOut: checkOut,
        isPresent: isPresent,
        workingHours: totalWorkingHours,
      ),
    ];

    // For non-admin users, we'll show simplified stats
    // In a real app, you might want to show team stats if user has permissions
    return DailyAttendanceSummary(
      date: today,
      employeeAttendances: employeeAttendances,
      totalEmployees: 1, // Just current user
      presentEmployees: isPresent ? 1 : 0,
      absentEmployees: isPresent ? 0 : 1,
      attendancePercentage: isPresent ? 100.0 : 0.0,
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  DateTime? _parseDateTime(dynamic dateTimeStr) {
    if (dateTimeStr == null) return null;
    try {
      return DateTime.parse(dateTimeStr.toString());
    } catch (e) {
      return null;
    }
  }

  void refresh() {
    loadDailySummary();
  }
}

final currentDailySummaryProvider =
    NotifierProvider<DailySummaryNotifier, DailySummaryState>(() {
      return DailySummaryNotifier(odooService);
    });
