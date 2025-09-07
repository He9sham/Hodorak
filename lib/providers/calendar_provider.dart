import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/models/daily_attendance_summary.dart';
import 'package:hodorak/services/calendar_service.dart';

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
