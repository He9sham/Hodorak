import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/models/daily_attendance_summary.dart';
import 'package:hodorak/odoo/odoo_service.dart';
import 'package:hodorak/providers/auth_provider.dart';
import 'package:hodorak/services/calendar_service.dart';
import 'package:hodorak/services/daily_attendance_service.dart';

class AttendanceState {
  final List<Map<String, dynamic>> records;
  final bool loading;
  final bool dayCompleted;
  final String? error;

  AttendanceState({
    this.records = const [],
    this.loading = false,
    this.dayCompleted = false,
    this.error,
  });

  AttendanceState copyWith({
    List<Map<String, dynamic>>? records,
    bool? loading,
    bool? dayCompleted,
    String? error,
  }) {
    return AttendanceState(
      records: records ?? this.records,

      loading: loading ?? this.loading,
      dayCompleted: dayCompleted ?? this.dayCompleted,
      error: error ?? this.error,
    );
  }
}

// attendance provider

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final OdooService odooService;
  late final DailyAttendanceService dailyService;

  late final CalendarService calendarService;

  AttendanceNotifier(this.odooService) : super(AttendanceState()) {
    calendarService = CalendarService();
    dailyService = DailyAttendanceService(
      odooService: odooService,
      calendarService: calendarService,
    );
    initialize();
  }

  Future<void> initialize() async {
    await loadAttendance();
    await initializeDayStatus();
  }

  Future<void> loadAttendance() async {
    state = state.copyWith(loading: true, error: null);

    try {
      // Load only today's attendance records for a more logical start state
      final records = await dailyService.getTodayAttendance();
      state = state.copyWith(records: records, loading: false);
    } catch (e) {
      state = state.copyWith(
        error: "fetch error: ${e.toString()}",
        loading: false,
      );
    }
  }

  Future<void> initializeDayStatus() async {
    try {
      await dailyService.checkAndResetForNewDay();
      final dayCompleted = await dailyService.isDayCompleted();
      state = state.copyWith(dayCompleted: dayCompleted);
    } catch (e) {
      state = state.copyWith(
        error: "initialize day status error: ${e.toString()}",
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> checkIn(int employeeId) async {
    try {
      await odooService.checkIn(employeeId);

      await loadAttendance(); // for refresh records emp     by hesham
    } catch (e) {
      state = state.copyWith(error: 'checkIn failed: $e');
    }
  }

  Future<void> checkOut(int employeeId, BuildContext context) async {
    try {
      final attid = await odooService.checkOut(employeeId);

      await loadAttendance(); // for refresh records emp     by hesham

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('checkOut done for $attid')));
    } catch (e) {
      state = state.copyWith(error: 'checkOut failed: $e');
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
      state = state.copyWith(error: 'Failed to end day: $e');
      return null;
    }
  }
}

final attendanceProvider =
    StateNotifierProvider.family<
      AttendanceNotifier,
      AttendanceState,
      OdooService
    >((ref, odooService) {
      return AttendanceNotifier(odooService);
    });

final currentAttendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
      final authState = ref.watch(authProvider);
      if (authState.odooService == null) {
        throw Exception('Not authenticated');
      }
      return AttendanceNotifier(authState.odooService!);
    });
