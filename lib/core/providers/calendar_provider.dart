import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/odoo_service/odoo_http_service.dart';
import 'package:hodorak/core/services/calendar_service.dart';
import 'package:hodorak/core/services/http_attendance_service.dart';
import 'package:hodorak/core/utils/logger.dart';

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
class CalendarNotifier extends Notifier<CalendarState> {
  final CalendarService calendarService;

  CalendarNotifier(this.calendarService);

  @override
  CalendarState build() {
    // Don't call async methods in build() - this causes initialization issues
    // Data loading should be triggered when needed
    return CalendarState(selectedMonth: DateTime.now());
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
final calendarProvider = NotifierProvider<CalendarNotifier, CalendarState>(
  () => CalendarNotifier(CalendarService()),
);

// Enhanced calendar provider that can fetch live data
final enhancedCalendarProvider =
    NotifierProvider<EnhancedCalendarNotifier, CalendarState>(() {
      // For now, return a basic enhanced notifier without Odoo service
      // The auth state checking will need to be handled differently in the new Riverpod
      Logger.info(
        'CalendarProvider: Using fallback calendar without Odoo service',
      );
      return EnhancedCalendarNotifier.withoutOdoo(CalendarService());
    });

// Enhanced calendar notifier that can fetch live attendance data
class EnhancedCalendarNotifier extends Notifier<CalendarState> {
  final CalendarService calendarService;
  final OdooHttpService? httpService;
  HttpAttendanceService? httpAttendanceService;

  EnhancedCalendarNotifier(this.calendarService, this.httpService);

  // Constructor without Odoo service for fallback
  EnhancedCalendarNotifier.withoutOdoo(this.calendarService)
    : httpService = null;

  @override
  CalendarState build() {
    Logger.debug(
      'EnhancedCalendarNotifier: Constructor called with httpService: ${httpService != null}',
    );
    if (httpService != null) {
      httpAttendanceService = HttpAttendanceService(
        odooService: httpService!,
        calendarService: calendarService,
      );
      Logger.info('EnhancedCalendarNotifier: HttpAttendanceService created');
    } else {
      Logger.info('EnhancedCalendarNotifier: No HTTP service available');
    }
    // Don't call async methods in build() - this causes initialization issues
    // Data loading should be triggered when needed
    return CalendarState(selectedMonth: DateTime.now());
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
            Logger.info('No live summary found for today');
          }
        } else {
          Logger.debug('Today is not in selected month');
        }
      } else {
        Logger.info('No Odoo service available, using saved summaries only');
      }

      state = state.copyWith(summaries: savedSummaries, isLoading: false);
      Logger.info('Final state: ${savedSummaries.length} summaries loaded');
    } catch (e) {
      Logger.error('Error loading summaries: $e');
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
  /// Only returns summary if user actually attended on that date
  Future<DailyAttendanceSummary?> getAttendanceForDate(DateTime date) async {
    if (httpAttendanceService == null) {
      Logger.info('No attendance service available for date: $date');
      return null; // No service available
    }

    try {
      Logger.debug('Fetching current user data for date: $date');
      final summary = await httpAttendanceService!
          .createCurrentUserSummaryForDate(date);

      if (summary != null) {
        Logger.info(
          'Current user data found: ${summary.presentEmployees}/${summary.totalEmployees} present',
        );
        return summary;
      } else {
        Logger.info(
          'No attendance data found for date: $date (user did not attend)',
        );
        return null;
      }
    } catch (e) {
      Logger.error('Error fetching current user data for $date: $e');
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

// Calendar service provider
final calendarServiceProvider = Provider<CalendarService>((ref) {
  return CalendarService();
});
