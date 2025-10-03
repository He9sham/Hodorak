import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/odoo_service/odoo_http_service.dart';
import 'package:hodorak/core/services/calendar_service.dart';
import 'package:hodorak/core/services/http_attendance_service.dart';
import 'package:hodorak/core/services/service_locator.dart';
import 'package:hodorak/core/utils/logger.dart';

class AdminCalendarState {
  final List<Map<String, dynamic>> employees;
  final List<DailyAttendanceSummary> attendanceSummaries;
  final Map<DateTime, List<DailyAttendanceSummary>> events;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final DateTime? filterDate;
  final String? filterUserId;
  final bool isLoading;
  final String? errorMessage;

  AdminCalendarState({
    this.employees = const [],
    this.attendanceSummaries = const [],
    this.events = const {},
    DateTime? focusedDay,
    this.selectedDay,
    this.filterDate,
    this.filterUserId,
    this.isLoading = false,
    this.errorMessage,
  }) : focusedDay = focusedDay ?? DateTime.now();

  AdminCalendarState copyWith({
    List<Map<String, dynamic>>? employees,
    List<DailyAttendanceSummary>? attendanceSummaries,
    Map<DateTime, List<DailyAttendanceSummary>>? events,
    DateTime? focusedDay,
    DateTime? selectedDay,
    DateTime? filterDate,
    String? filterUserId,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminCalendarState(
      employees: employees ?? this.employees,
      attendanceSummaries: attendanceSummaries ?? this.attendanceSummaries,
      events: events ?? this.events,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      filterDate: filterDate ?? this.filterDate,
      filterUserId: filterUserId ?? this.filterUserId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AdminCalendarNotifier extends Notifier<AdminCalendarState> {
  final OdooHttpService odooService;
  final CalendarService calendarService;

  AdminCalendarNotifier(this.odooService, this.calendarService);

  @override
  AdminCalendarState build() {
    // Don't call async methods in build() - this causes initialization issues
    // Data loading should be triggered when needed
    return AdminCalendarState();
  }

  /// Initialize admin calendar data - call this when the admin calendar screen loads
  Future<void> initializeAdminCalendar() async {
    await loadEmployees();
    await loadAttendanceData();
    // Set today as selected day after data is loaded
    selectDay(DateTime.now());
  }

  Future<void> loadEmployees() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final employees = await odooService.getAllEmployees();

      state = state.copyWith(employees: employees, isLoading: false);

      Logger.info(
        'AdminCalendarNotifier: Loaded ${employees.length} employees',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load employees: $e',
      );
      Logger.error('AdminCalendarNotifier: Error loading employees: $e');
    }
  }

  Future<void> loadAttendanceData() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final httpService = HttpAttendanceService(
        odooService: odooService,
        calendarService: calendarService,
      );

      // Load attendance data for the current month
      final endDate = DateTime(
        state.focusedDay.year,
        state.focusedDay.month + 1,
        0,
      );

      final summaries = <DailyAttendanceSummary>[];

      // Load data for each day in the month
      for (int day = 1; day <= endDate.day; day++) {
        final date = DateTime(
          state.focusedDay.year,
          state.focusedDay.month,
          day,
        );
        try {
          final summary = await httpService.createDailySummaryForDate(date);
          summaries.add(summary);
        } catch (e) {
          Logger.warning(
            'AdminCalendarNotifier: Failed to load data for $date: $e',
          );
          // Create empty summary for days without data
          summaries.add(_createEmptySummary(date));
        }
      }

      state = state.copyWith(
        attendanceSummaries: summaries,
        events: _createEventsMap(summaries),
        isLoading: false,
      );

      Logger.info(
        'AdminCalendarNotifier: Loaded ${summaries.length} attendance summaries',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load attendance data: $e',
      );
      Logger.error('AdminCalendarNotifier: Error loading attendance data: $e');
    }
  }

  DailyAttendanceSummary _createEmptySummary(DateTime date) {
    return DailyAttendanceSummary(
      date: date,
      employeeAttendances: state.employees
          .map(
            (emp) => EmployeeAttendance(
              employeeId: emp['id'],
              employeeName: emp['name'] ?? 'Unknown',
              checkIn: null,
              checkOut: null,
              isPresent: false,
              workingHours: null,
            ),
          )
          .toList(),
      totalEmployees: state.employees.length,
      presentEmployees: 0,
      absentEmployees: state.employees.length,
      attendancePercentage: 0.0,
    );
  }

  Map<DateTime, List<DailyAttendanceSummary>> _createEventsMap(
    List<DailyAttendanceSummary> summaries,
  ) {
    final events = <DateTime, List<DailyAttendanceSummary>>{};
    for (final summary in summaries) {
      final dateKey = DateTime(
        summary.date.year,
        summary.date.month,
        summary.date.day,
      );
      events[dateKey] = [summary];
    }
    return events;
  }

  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  void changeFocusedDay(DateTime day) {
    if (!isSameDay(state.focusedDay, day)) {
      state = state.copyWith(focusedDay: day);
      loadAttendanceData();
    }
  }

  void setFilterDate(DateTime? date) {
    state = state.copyWith(filterDate: date);
  }

  void setFilterUserId(String? userId) {
    state = state.copyWith(filterUserId: userId);
  }

  void clearFilters() {
    state = state.copyWith(filterDate: null, filterUserId: null);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  List<DailyAttendanceSummary> getFilteredSummaries() {
    List<DailyAttendanceSummary> filtered = state.attendanceSummaries;

    if (state.filterDate != null) {
      filtered = filtered
          .where((summary) => isSameDay(summary.date, state.filterDate!))
          .toList();
    }

    if (state.filterUserId != null) {
      filtered = filtered.map((summary) {
        final filteredEmployees = summary.employeeAttendances
            .where((emp) => emp.employeeId.toString() == state.filterUserId)
            .toList();

        return DailyAttendanceSummary(
          date: summary.date,
          employeeAttendances: filteredEmployees,
          totalEmployees: filteredEmployees.length,
          presentEmployees: filteredEmployees
              .where((emp) => emp.isPresent)
              .length,
          absentEmployees: filteredEmployees
              .where((emp) => !emp.isPresent)
              .length,
          attendancePercentage: filteredEmployees.isNotEmpty
              ? (filteredEmployees.where((emp) => emp.isPresent).length /
                        filteredEmployees.length) *
                    100
              : 0.0,
        );
      }).toList();
    }

    return filtered;
  }

  DailyAttendanceSummary? getSelectedDaySummary() {
    if (state.selectedDay == null) return null;

    return state.attendanceSummaries.firstWhere(
      (s) => isSameDay(s.date, state.selectedDay!),
      orElse: () => _createEmptySummary(state.selectedDay!),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

final adminCalendarProvider =
    NotifierProvider<AdminCalendarNotifier, AdminCalendarState>(() {
      // For now, return a basic notifier without auth checking
      // The auth state checking will need to be handled differently in the new Riverpod
      final calendarService = CalendarService();
      return AdminCalendarNotifier(odooService, calendarService);
    });
