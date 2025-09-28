import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/odoo_service/odoo_http_service.dart';
import 'package:hodorak/core/providers/auth_state_manager.dart';
import 'package:hodorak/core/services/calendar_service.dart';
import 'package:hodorak/core/services/http_attendance_service.dart';

// Calendar state class
class CalendarState {
  final List<DailyAttendanceSummary> summaries;
  final DateTime selectedMonth;
  final bool isLoading;
  final String? errorMessage;

  CalendarState({
    this.summaries = const [],
    DateTime? selectedMonth,
    this.isLoading = false,
    this.errorMessage,
  }) : selectedMonth = selectedMonth ?? DateTime(2024, 1, 1);

  CalendarState copyWith({
    List<DailyAttendanceSummary>? summaries,
    DateTime? selectedMonth,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CalendarState(
      summaries: summaries ?? this.summaries,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Calendar provider
class CalendarNotifier extends StateNotifier<CalendarState> {
  final CalendarService calendarService;

  CalendarNotifier(this.calendarService)
    : super(CalendarState(selectedMonth: DateTime.now())) {
    loadSummaries();
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
      final summaries = await calendarService.getSummariesInRange(
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

  Future<void> selectMonth(DateTime month) async {
    state = state.copyWith(selectedMonth: month, isLoading: true);
    await loadSummaries();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider instance
final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>(
  (ref) {
    return CalendarNotifier(CalendarService());
  },
);

// Enhanced calendar provider that can fetch live data
final enhancedCalendarProvider =
    StateNotifierProvider<EnhancedCalendarNotifier, CalendarState>((ref) {
      try {
        final authState = ref.watch(authStateManagerProvider);
        print(
          'CalendarProvider: Auth state - authenticated: ${authState.isAuthenticated}, loading: ${authState.isLoading}, error: ${authState.error}',
        );

        if (authState.isAuthenticated) {
          final httpService = ref.read(odooHttpServiceProvider);
          print('CalendarProvider: Creating calendar with HTTP service');
          return EnhancedCalendarNotifier(CalendarService(), httpService);
        } else {
          print('CalendarProvider: User not authenticated, using fallback');
        }
      } catch (e) {
        print('CalendarProvider: Error in auth check: $e');
        // Fallback to basic calendar provider if auth fails
      }

      // Return a basic enhanced notifier without Odoo service
      print('CalendarProvider: Using fallback calendar without Odoo service');
      return EnhancedCalendarNotifier.withoutOdoo(CalendarService());
    });

// Enhanced calendar notifier that can fetch live attendance data
class EnhancedCalendarNotifier extends StateNotifier<CalendarState> {
  final CalendarService calendarService;
  final OdooHttpService? httpService;
  HttpAttendanceService? httpAttendanceService;

  EnhancedCalendarNotifier(this.calendarService, this.httpService)
    : super(CalendarState(selectedMonth: DateTime.now())) {
    print(
      'EnhancedCalendarNotifier: Constructor called with httpService: ${httpService != null}',
    );
    if (httpService != null) {
      httpAttendanceService = HttpAttendanceService(
        odooService: httpService!,
        calendarService: calendarService,
      );
      print('EnhancedCalendarNotifier: HttpAttendanceService created');
    } else {
      print('EnhancedCalendarNotifier: No HTTP service available');
    }
    loadSummaries();
  }

  // Constructor without Odoo service for fallback
  EnhancedCalendarNotifier.withoutOdoo(this.calendarService)
    : httpService = null,
      super(CalendarState(selectedMonth: DateTime.now())) {
    loadSummaries();
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

      // Get saved summaries from calendar service
      final savedSummaries = await calendarService.getSummariesInRange(
        startDate,
        endDate,
      );

      // Get live data for today if it's in the selected month and we have service
      if (httpAttendanceService != null) {
        final today = DateTime.now();
        if (today.year == state.selectedMonth.year &&
            today.month == state.selectedMonth.month) {
          final liveSummary = await getAttendanceForDate(today);
          if (liveSummary != null) {
            // Replace saved summary for today with live data
            final filteredSummaries = savedSummaries
                .where((s) => !_isSameDay(s.date, today))
                .toList();
            filteredSummaries.add(liveSummary);
            state = state.copyWith(
              summaries: filteredSummaries,
              isLoading: false,
            );

            return;
          } else {
            print('No live summary found for today');
          }
        } else {
          print('Today is not in selected month');
        }
      } else {
        print('No Odoo service available, using saved summaries only');
      }

      state = state.copyWith(summaries: savedSummaries, isLoading: false);
      print('Final state: ${savedSummaries.length} summaries loaded');
    } catch (e) {
      print('Error loading summaries: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load summaries: $e',
      );
    }
  }

  Future<void> selectMonth(DateTime month) async {
    state = state.copyWith(selectedMonth: month, isLoading: true);
    await loadSummaries();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Fetch live attendance data for current user on a specific date
  Future<DailyAttendanceSummary?> getAttendanceForDate(DateTime date) async {
    if (httpAttendanceService == null) {
      print('No attendance service available for date: $date');
      return null; // No service available
    }

    try {
      print('Fetching current user data for date: $date');
      final summary = await httpAttendanceService!
          .createCurrentUserSummaryForDate(date);

      print(
        'Current user data found: ${summary.presentEmployees}/${summary.totalEmployees} present',
      );
      return summary;
    } catch (e) {
      print('Error fetching current user data for $date: $e');
      state = state.copyWith(errorMessage: 'Failed to fetch attendance: $e');
      return null;
    }
  }

  /// Refresh attendance data for the selected month
  Future<void> refreshMonthData() async {
    await loadSummaries();
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
