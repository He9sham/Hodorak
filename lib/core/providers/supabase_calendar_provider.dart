import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/services/supabase_attendance_service.dart';

// Calendar state class
class SupabaseCalendarState {
  final List<DailyAttendanceSummary> summaries;
  final DateTime selectedMonth;
  final bool isLoading;
  final String? errorMessage;

  SupabaseCalendarState({
    this.summaries = const [],
    DateTime? selectedMonth,
    this.isLoading = false,
    this.errorMessage,
  }) : selectedMonth = selectedMonth ?? DateTime(2024, 1, 1);

  SupabaseCalendarState copyWith({
    List<DailyAttendanceSummary>? summaries,
    DateTime? selectedMonth,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SupabaseCalendarState(
      summaries: summaries ?? this.summaries,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Calendar provider
class SupabaseCalendarNotifier extends Notifier<SupabaseCalendarState> {
  final SupabaseAttendanceService _attendanceService;

  SupabaseCalendarNotifier(this._attendanceService);

  @override
  SupabaseCalendarState build() {
    // Don't call async methods in build() - this causes initialization issues
    // Data loading should be triggered when needed
    return SupabaseCalendarState(selectedMonth: DateTime.now());
  }

  Future<void> loadSummaries() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final startDate = DateTime(
        state.selectedMonth.year,
        state.selectedMonth.month,
        1,
      );
      final endDate = DateTime(
        state.selectedMonth.year,
        state.selectedMonth.month + 1,
        0,
      );

      // Get attendance data for the month
      final attendanceData = await _attendanceService.getAllAttendance(
        startDate: startDate,
        endDate: endDate,
      );

      // Convert attendance data to summaries
      final summaries = _convertAttendanceToSummaries(
        attendanceData,
        startDate,
        endDate,
      );

      state = state.copyWith(summaries: summaries, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load summaries: $e',
      );
    }
  }

  List<DailyAttendanceSummary> _convertAttendanceToSummaries(
    List<dynamic> attendanceData,
    DateTime startDate,
    DateTime endDate,
  ) {
    final summaries = <DailyAttendanceSummary>[];

    // Group attendance by date
    final attendanceByDate = <String, List<dynamic>>{};
    for (final record in attendanceData) {
      final checkInDate = DateTime.parse(record['check_in']);
      final dateKey =
          '${checkInDate.year}-${checkInDate.month}-${checkInDate.day}';
      attendanceByDate.putIfAbsent(dateKey, () => []).add(record);
    }

    // Create summaries for each day
    for (int day = 1; day <= endDate.day; day++) {
      final date = DateTime(startDate.year, startDate.month, day);
      final dateKey = '${date.year}-${date.month}-${date.day}';
      final dayAttendance = attendanceByDate[dateKey] ?? [];

      if (dayAttendance.isNotEmpty) {
        final employeeAttendances = dayAttendance.map((record) {
          return EmployeeAttendance(
            employeeId: record['user_id'],
            employeeName: record['users']?['name'] ?? 'Unknown',
            checkIn: DateTime.parse(record['check_in']),
            checkOut: record['check_out'] != null
                ? DateTime.parse(record['check_out'])
                : null,
            isPresent: true,
            workingHours: record['check_out'] != null
                ? DateTime.parse(
                    record['check_out'],
                  ).difference(DateTime.parse(record['check_in']))
                : null,
          );
        }).toList();

        final summary = DailyAttendanceSummary(
          date: date,
          employeeAttendances: employeeAttendances,
          totalEmployees: employeeAttendances.length,
          presentEmployees: employeeAttendances
              .where((emp) => emp.isPresent)
              .length,
          absentEmployees: 0, // We only show days with attendance
          attendancePercentage: 100.0,
        );

        summaries.add(summary);
      }
    }

    return summaries;
  }

  Future<void> selectMonth(DateTime month) async {
    state = state.copyWith(selectedMonth: month, isLoading: true);
    await loadSummaries();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider instance
final supabaseCalendarProvider =
    NotifierProvider<SupabaseCalendarNotifier, SupabaseCalendarState>(
      () => SupabaseCalendarNotifier(SupabaseAttendanceService()),
    );
