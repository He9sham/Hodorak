import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/models/daily_attendance_summary.dart';
import 'package:hodorak/odoo/odoo_service.dart';
import 'package:hodorak/services/calendar_service.dart';
import 'package:hodorak/services/daily_attendance_service.dart';
import 'package:hodorak/providers/auth_provider.dart';

// Attendance state class
class AttendanceState {
  final List<Map<String, dynamic>> records;
  final bool isLoading;
  final bool dayCompleted;
  final String? errorMessage;

  const AttendanceState({
    this.records = const [],
    this.isLoading = false,
    this.dayCompleted = false,
    this.errorMessage,
  });

  AttendanceState copyWith({
    List<Map<String, dynamic>>? records,
    bool? isLoading,
    bool? dayCompleted,
    String? errorMessage,
  }) {
    return AttendanceState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      dayCompleted: dayCompleted ?? this.dayCompleted,
      errorMessage: errorMessage,
    );
  }
}

// Attendance provider
class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final OdooService odooService;
  late final DailyAttendanceService dailyService;
  late final CalendarService calendarService;

  AttendanceNotifier(this.odooService) : super(const AttendanceState()) {
    calendarService = CalendarService();
    dailyService = DailyAttendanceService(
      odooService: odooService,
      calendarService: calendarService,
    );
    _initialize();
  }

  Future<void> _initialize() async {
    await loadAttendance();
    await _initializeDayStatus();
  }

  Future<void> loadAttendance() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final records = await odooService.fetchAttendance(limit: 20);
      state = state.copyWith(records: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Fetch error: $e',
      );
    }
  }

  Future<void> checkIn(int employeeId) async {
    try {
      final attId = await odooService.checkIn(employeeId);
      await loadAttendance(); // Refresh records
      // Success message handled by UI
    } catch (e) {
      state = state.copyWith(errorMessage: 'Check-in failed: $e');
    }
  }

  Future<void> checkOut(int employeeId) async {
    try {
      await odooService.checkOut(employeeId);
      await loadAttendance(); // Refresh records
      // Success message handled by UI
    } catch (e) {
      state = state.copyWith(errorMessage: 'Check-out failed: $e');
    }
  }

  Future<DailyAttendanceSummary?> endDay() async {
    try {
      await dailyService.checkAndResetForNewDay();
      await dailyService.endDay();
      
      final summary = await dailyService.createDailySummary();
      
      state = state.copyWith(
        dayCompleted: true,
        records: [], // Clear records
      );
      
      return summary;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to end day: $e');
      return null;
    }
  }

  Future<void> _initializeDayStatus() async {
    try {
      await dailyService.checkAndResetForNewDay();
      final completed = await dailyService.isDayCompleted();
      state = state.copyWith(dayCompleted: completed);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error initializing day status: $e');
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider factory that depends on auth
final attendanceProvider = StateNotifierProvider.family<AttendanceNotifier, AttendanceState, OdooService>((ref, odooService) {
  return AttendanceNotifier(odooService);
});

// Convenience provider that automatically uses the authenticated OdooService
final currentAttendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  final authState = ref.watch(authProvider);
  if (authState.odooService == null) {
    throw Exception('Not authenticated');
  }
  return AttendanceNotifier(authState.odooService!);
});