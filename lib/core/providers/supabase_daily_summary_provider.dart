import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/services/supabase_attendance_service.dart';
import 'package:hodorak/core/services/supabase_auth_service.dart';

class SupabaseDailySummaryState {
  final DailyAttendanceSummary? summary;
  final bool loading;
  final String? error;

  SupabaseDailySummaryState({this.summary, this.loading = false, this.error});

  SupabaseDailySummaryState copyWith({
    DailyAttendanceSummary? summary,
    bool? loading,
    String? error,
  }) {
    return SupabaseDailySummaryState(
      summary: summary ?? this.summary,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class SupabaseDailySummaryNotifier extends Notifier<SupabaseDailySummaryState> {
  final SupabaseAttendanceService _attendanceService;
  final SupabaseAuthService _authService;

  SupabaseDailySummaryNotifier(this._attendanceService, this._authService);

  @override
  SupabaseDailySummaryState build() {
    loadDailySummary();
    return SupabaseDailySummaryState();
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

    // Get current user
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // Get current user's attendance for today
    final myAttendance = await _attendanceService
        .getCurrentUserAttendanceForDate(today);

    // Calculate working hours for today
    Duration? totalWorkingHours;
    DateTime? checkIn;
    DateTime? checkOut;
    bool isPresent = false;

    if (myAttendance.isNotEmpty) {
      // Get the first check-in and last check-out of the day
      final sortedAttendance = myAttendance
        ..sort((a, b) => a.checkIn.compareTo(b.checkIn));

      checkIn = sortedAttendance.first.checkIn;
      final lastRecord = sortedAttendance.last;
      checkOut = lastRecord.checkOut;

      isPresent = true; // If we have attendance records, user is present

      if (checkOut != null) {
        totalWorkingHours = checkOut.difference(checkIn);
      } else {
        // Still at work, calculate hours until now
        totalWorkingHours = DateTime.now().difference(checkIn);
      }
    }

    // Create a simplified summary with just the current user
    final employeeAttendances = [
      EmployeeAttendance(
        employeeId: currentUser.id.hashCode,
        employeeName: currentUser.email ?? 'Current User',
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

  void refresh() {
    loadDailySummary();
  }
}

final supabaseCurrentDailySummaryProvider =
    NotifierProvider<SupabaseDailySummaryNotifier, SupabaseDailySummaryState>(
      () {
        return SupabaseDailySummaryNotifier(
          SupabaseAttendanceService(),
          SupabaseAuthService(),
        );
      },
    );
