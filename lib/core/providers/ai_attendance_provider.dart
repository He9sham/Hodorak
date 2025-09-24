import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/attendance_response.dart';
import 'package:hodorak/core/odoo_service/odoo_service.dart';
import 'package:hodorak/core/providers/auth_provider.dart';
import 'package:hodorak/core/services/ai_attendance_assistant.dart';

class AIAttendanceState {
  final List<Map<String, dynamic>> records;
  final bool loading;
  final bool dayCompleted;
  final String? error;
  final Map<String, dynamic>? lastResponse;

  AIAttendanceState({
    this.records = const [],
    this.loading = false,
    this.dayCompleted = false,
    this.error,
    this.lastResponse,
  });

  AIAttendanceState copyWith({
    List<Map<String, dynamic>>? records,
    bool? loading,
    bool? dayCompleted,
    String? error,
    Map<String, dynamic>? lastResponse,
  }) {
    return AIAttendanceState(
      records: records ?? this.records,
      loading: loading ?? this.loading,
      dayCompleted: dayCompleted ?? this.dayCompleted,
      error: error ?? this.error,
      lastResponse: lastResponse ?? this.lastResponse,
    );
  }
}

class AIAttendanceNotifier extends StateNotifier<AIAttendanceState> {
  final OdooService odooService;
  late final AIAttendanceAssistant aiAssistant;

  AIAttendanceNotifier(this.odooService) : super(AIAttendanceState()) {
    aiAssistant = AIAttendanceAssistant(odooService: odooService);
    initialize();
  }

  Future<void> initialize() async {
    await loadTodayAttendance();
  }

  Future<void> loadTodayAttendance() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final today = DateTime.now();
      final records = await aiAssistant.getAttendanceForDate(today);
      state = state.copyWith(records: records, loading: false);
    } catch (e) {
      state = state.copyWith(
        error: "Failed to load today's attendance: ${e.toString()}",
        loading: false,
      );
    }
  }

  Future<void> loadAttendanceForDate(DateTime date) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final records = await aiAssistant.getAttendanceForDate(date);
      state = state.copyWith(records: records, loading: false);
    } catch (e) {
      state = state.copyWith(
        error: "Failed to load attendance for date: ${e.toString()}",
        loading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Check In with AI assistant - returns JSON response
  Future<Map<String, dynamic>> checkIn({
    required int employeeId,
    String? location,
    bool includeLocation = true,
  }) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final response = await aiAssistant.checkIn(
        userId: employeeId,
        location: location,
        includeLocation: includeLocation,
      );

      state = state.copyWith(
        loading: false,
        lastResponse: response,
      );

      // Refresh today's attendance
      await loadTodayAttendance();

      return response;
    } catch (e) {
      final errorResponse = AttendanceResponse.error('Check In failed: $e').toJson();
      state = state.copyWith(
        loading: false,
        error: 'Check In failed: $e',
        lastResponse: errorResponse,
      );
      return errorResponse;
    }
  }

  /// Check Out with AI assistant - returns JSON response
  Future<Map<String, dynamic>> checkOut({
    required int employeeId,
    String? location,
    bool includeLocation = true,
  }) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final response = await aiAssistant.checkOut(
        userId: employeeId,
        location: location,
        includeLocation: includeLocation,
      );

      state = state.copyWith(
        loading: false,
        lastResponse: response,
      );

      // Refresh today's attendance
      await loadTodayAttendance();

      return response;
    } catch (e) {
      final errorResponse = AttendanceResponse.error('Check Out failed: $e').toJson();
      state = state.copyWith(
        loading: false,
        error: 'Check Out failed: $e',
        lastResponse: errorResponse,
      );
      return errorResponse;
    }
  }

  /// Get user's attendance history
  Future<List<Map<String, dynamic>>> getUserAttendanceHistory(int userId) async {
    try {
      return await aiAssistant.getUserAttendanceHistory(userId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to get attendance history: $e');
      return [];
    }
  }

  /// Get today's attendance for a specific user
  Future<Map<String, dynamic>?> getTodayAttendanceForUser(int userId) async {
    try {
      return await aiAssistant.getTodayAttendance(userId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to get today\'s attendance: $e');
      return null;
    }
  }

  /// Get daily attendance summary
  Future<Map<String, dynamic>> getDailyAttendanceSummary(DateTime date) async {
    try {
      return await aiAssistant.getDailyAttendanceSummary(date);
    } catch (e) {
      state = state.copyWith(error: 'Failed to get daily summary: $e');
      return {};
    }
  }

  /// Get attendance in date range
  Future<List<Map<String, dynamic>>> getAttendanceInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await aiAssistant.getAttendanceInRange(startDate, endDate);
    } catch (e) {
      state = state.copyWith(error: 'Failed to get attendance in range: $e');
      return [];
    }
  }

  /// Export attendance data
  Future<String> exportAttendanceData() async {
    try {
      return await aiAssistant.exportAttendanceData();
    } catch (e) {
      state = state.copyWith(error: 'Failed to export data: $e');
      return '';
    }
  }

  /// Import attendance data
  Future<void> importAttendanceData(String jsonData) async {
    try {
      await aiAssistant.importAttendanceData(jsonData);
      await loadTodayAttendance(); // Refresh after import
    } catch (e) {
      state = state.copyWith(error: 'Failed to import data: $e');
    }
  }

  /// Clear all attendance data
  Future<void> clearAllAttendanceData() async {
    try {
      await aiAssistant.clearAllAttendanceData();
      state = state.copyWith(records: []);
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear data: $e');
    }
  }
}

// Provider for AI attendance assistant
final aiAttendanceProvider = StateNotifierProvider.family<
    AIAttendanceNotifier,
    AIAttendanceState,
    OdooService>((ref, odooService) {
  return AIAttendanceNotifier(odooService);
});

// Provider for current authenticated user's AI attendance
final currentAIAttendanceProvider =
    StateNotifierProvider<AIAttendanceNotifier, AIAttendanceState>((ref) {
  final authState = ref.watch(authProvider);
  if (authState.odooService == null) {
    throw Exception('Not authenticated');
  }
  return AIAttendanceNotifier(authState.odooService!);
});