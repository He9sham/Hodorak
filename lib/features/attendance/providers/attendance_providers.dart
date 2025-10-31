import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hodorak/core/providers/supabase_auth_provider.dart';
import 'package:hodorak/core/services/supabase_attendance_settings_service.dart';

final supabaseAttendanceSettingsServiceProvider =
    Provider<SupabaseAttendanceSettingsService>((ref) {
      return SupabaseAttendanceSettingsService();
    });

final attendanceSettingsProvider =
    StateNotifierProvider<AttendanceSettingsNotifier, AsyncValue<TimeOfDay>>((
      ref,
    ) {
      return AttendanceSettingsNotifier(ref);
    });

class AttendanceSettingsNotifier extends StateNotifier<AsyncValue<TimeOfDay>> {
  final Ref _ref;
  static const TimeOfDay _defaultTime = TimeOfDay(hour: 9, minute: 0);

  AttendanceSettingsNotifier(this._ref) : super(AsyncValue.data(_defaultTime)) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      state = const AsyncValue.loading();

      final authState = _ref.read(supabaseAuthProvider);
      if (authState.user?.companyId == null) {
        throw Exception('No company ID found for current user');
      }

      final service = _ref.read(supabaseAttendanceSettingsServiceProvider);
      final settings = await service.getAttendanceSettings(
        authState.user!.companyId!,
      );

      if (settings != null) {
        final minutes = settings.thresholdMinutes;
        state = AsyncValue.data(
          TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
        );
      } else {
        state = AsyncValue.data(_defaultTime);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTime(TimeOfDay newTime) async {
    try {
      final authState = _ref.read(supabaseAuthProvider);
      if (authState.user?.companyId == null) {
        throw Exception('No company ID found for current user');
      }

      final service = _ref.read(supabaseAttendanceSettingsServiceProvider);
      final totalMinutes = newTime.hour * 60 + newTime.minute;

      await service.setAttendanceSettings(
        companyId: authState.user!.companyId!,
        thresholdMinutes: totalMinutes,
      );

      state = AsyncValue.data(newTime);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
