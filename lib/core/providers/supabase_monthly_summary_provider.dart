import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/models/monthly_attendance_summary.dart';
import 'package:hodorak/core/services/supabase_attendance_service.dart';
import 'package:hodorak/core/services/supabase_auth_service.dart';

class SupabaseMonthlySummaryState {
  final MonthlyAttendanceSummary? summary;
  final bool loading;
  final String? error;

  SupabaseMonthlySummaryState({this.summary, this.loading = false, this.error});

  SupabaseMonthlySummaryState copyWith({
    MonthlyAttendanceSummary? summary,
    bool? loading,
    String? error,
  }) {
    return SupabaseMonthlySummaryState(
      summary: summary ?? this.summary,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class SupabaseMonthlySummaryNotifier
    extends Notifier<SupabaseMonthlySummaryState> {
  final SupabaseAttendanceService _attendanceService;
  final SupabaseAuthService _authService;

  SupabaseMonthlySummaryNotifier(this._attendanceService, this._authService);

  @override
  SupabaseMonthlySummaryState build() {
    loadMonthlySummary();
    return SupabaseMonthlySummaryState();
  }

  Future<void> loadMonthlySummary() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final summary = await _createMonthlySummary();
      state = state.copyWith(summary: summary, loading: false);
    } catch (e) {
      state = state.copyWith(
        error: "Failed to load monthly summary: ${e.toString()}",
        loading: false,
      );
    }
  }

  Future<MonthlyAttendanceSummary> _createMonthlySummary() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);

    // Get current user
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // Get current user's attendance for the entire month
    final monthlyAttendance = await _attendanceService.getUserAttendance(
      userId: currentUser.id,
      startDate: startDate,
      endDate: endDate,
    );

    // Create daily summaries for the month
    final dailySummaries = <DailyAttendanceSummary>[];

    // Group attendance by date
    final attendanceByDate = <String, List<dynamic>>{};
    for (final record in monthlyAttendance) {
      final checkInDate = DateTime.parse(record.checkIn.toString());
      final dateKey =
          '${checkInDate.year}-${checkInDate.month}-${checkInDate.day}';
      attendanceByDate.putIfAbsent(dateKey, () => []).add(record);
    }

    // Create summaries for each day in the month
    for (int day = 1; day <= endDate.day; day++) {
      final date = DateTime(now.year, now.month, day);
      final dateKey = '${date.year}-${date.month}-${date.day}';
      final dayAttendance = attendanceByDate[dateKey] ?? [];

      if (dayAttendance.isNotEmpty) {
        Duration? totalWorkingHours;
        DateTime? checkIn;
        DateTime? checkOut;
        bool isPresent = false;

        // Sort attendance by check-in time
        final sortedAttendance = dayAttendance
          ..sort((a, b) => a.checkIn.compareTo(b.checkIn));

        checkIn = sortedAttendance.first.checkIn;
        final lastRecord = sortedAttendance.last;
        checkOut = lastRecord.checkOut;

        isPresent = true;

        if (checkOut != null && checkIn != null) {
          totalWorkingHours = checkOut.difference(checkIn);
        } else if (checkIn != null) {
          // Still at work, calculate hours until end of day or now
          final endOfDay = DateTime(
            date.year,
            date.month,
            date.day,
            23,
            59,
            59,
          );
          totalWorkingHours =
              (DateTime.now().isBefore(endOfDay) ? DateTime.now() : endOfDay)
                  .difference(checkIn);
        }

        final employeeAttendance = EmployeeAttendance(
          employeeId: currentUser.id.hashCode,
          employeeName: currentUser.email ?? 'Current User',
          checkIn: checkIn,
          checkOut: checkOut,
          isPresent: isPresent,
          workingHours: totalWorkingHours,
        );

        final dailySummary = DailyAttendanceSummary(
          date: date,
          employeeAttendances: [employeeAttendance],
          totalEmployees: 1,
          presentEmployees: 1,
          absentEmployees: 0,
          attendancePercentage: 100.0,
        );

        dailySummaries.add(dailySummary);
      }
    }

    return MonthlyAttendanceSummary.fromDailySummaries(
      dailySummaries,
      now.year,
      now.month,
    );
  }

  void refresh() {
    loadMonthlySummary();
  }

  Future<void> loadSummaryForMonth(int year, int month) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      // Get current user
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get user's attendance for the specified month
      final monthlyAttendance = await _attendanceService.getUserAttendance(
        userId: currentUser.id,
        startDate: startDate,
        endDate: endDate,
      );

      // Create daily summaries for the month
      final dailySummaries = <DailyAttendanceSummary>[];

      // Group attendance by date
      final attendanceByDate = <String, List<dynamic>>{};
      for (final record in monthlyAttendance) {
        final checkInDate = DateTime.parse(record.checkIn.toString());
        final dateKey =
            '${checkInDate.year}-${checkInDate.month}-${checkInDate.day}';
        attendanceByDate.putIfAbsent(dateKey, () => []).add(record);
      }

      // Create summaries for each day in the month
      for (int day = 1; day <= endDate.day; day++) {
        final date = DateTime(year, month, day);
        final dateKey = '${date.year}-${date.month}-${date.day}';
        final dayAttendance = attendanceByDate[dateKey] ?? [];

        if (dayAttendance.isNotEmpty) {
          Duration? totalWorkingHours;
          DateTime? checkIn;
          DateTime? checkOut;
          bool isPresent = false;

          // Sort attendance by check-in time
          final sortedAttendance = dayAttendance
            ..sort((a, b) => a.checkIn.compareTo(b.checkIn));

          checkIn = sortedAttendance.first.checkIn;
          final lastRecord = sortedAttendance.last;
          checkOut = lastRecord.checkOut;

          isPresent = true;

          if (checkOut != null && checkIn != null) {
            totalWorkingHours = checkOut.difference(checkIn);
          } else if (checkIn != null) {
            // Still at work, calculate hours until end of day
            final endOfDay = DateTime(
              date.year,
              date.month,
              date.day,
              23,
              59,
              59,
            );
            totalWorkingHours =
                (DateTime.now().isBefore(endOfDay) ? DateTime.now() : endOfDay)
                    .difference(checkIn);
          }

          final employeeAttendance = EmployeeAttendance(
            employeeId: currentUser.id.hashCode,
            employeeName: currentUser.email ?? 'Current User',
            checkIn: checkIn,
            checkOut: checkOut,
            isPresent: isPresent,
            workingHours: totalWorkingHours,
          );

          final dailySummary = DailyAttendanceSummary(
            date: date,
            employeeAttendances: [employeeAttendance],
            totalEmployees: 1,
            presentEmployees: 1,
            absentEmployees: 0,
            attendancePercentage: 100.0,
          );

          dailySummaries.add(dailySummary);
        }
      }

      final summary = MonthlyAttendanceSummary.fromDailySummaries(
        dailySummaries,
        year,
        month,
      );

      state = state.copyWith(summary: summary, loading: false);
    } catch (e) {
      state = state.copyWith(
        error: "Failed to load monthly summary: ${e.toString()}",
        loading: false,
      );
    }
  }
}

final supabaseCurrentMonthlySummaryProvider =
    NotifierProvider<
      SupabaseMonthlySummaryNotifier,
      SupabaseMonthlySummaryState
    >(() {
      return SupabaseMonthlySummaryNotifier(
        SupabaseAttendanceService(),
        SupabaseAuthService(),
      );
    });
