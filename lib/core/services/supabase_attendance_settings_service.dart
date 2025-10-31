import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/attendance_settings.dart';
import '../supabase/supabase_config.dart';
import '../supabase/supabase_service.dart';
import '../utils/logger.dart';
import '../utils/uuid_generator.dart';

class SupabaseAttendanceSettingsService {
  final SupabaseClient _client = SupabaseService.client;

  /// Get attendance settings for a company
  Future<AttendanceSettings?> getAttendanceSettings(String companyId) async {
    try {
      Logger.debug(
        'SupabaseAttendanceSettingsService: Getting settings for company $companyId',
      );

      final response = await _client
          .from(SupabaseConfig.attendanceSettingsTable)
          .select()
          .eq('company_id', companyId)
          .maybeSingle();

      if (response == null) {
        Logger.info(
          'SupabaseAttendanceSettingsService: No settings found for company $companyId',
        );
        return null;
      }

      Logger.info(
        'SupabaseAttendanceSettingsService: Settings found for company $companyId',
      );
      return AttendanceSettings.fromJson(response);
    } catch (e) {
      Logger.error(
        'SupabaseAttendanceSettingsService: Error getting settings: $e',
      );
      return null;
    }
  }

  /// Set attendance settings for a company
  Future<AttendanceSettings?> setAttendanceSettings({
    required String companyId,
    required int thresholdMinutes,
  }) async {
    try {
      Logger.debug(
        'SupabaseAttendanceSettingsService: Setting attendance threshold for company $companyId',
      );

      // Check if settings already exist for this company
      final existingSettings = await getAttendanceSettings(companyId);

      if (existingSettings != null) {
        // Update existing settings
        final response = await _client
            .from(SupabaseConfig.attendanceSettingsTable)
            .update({
              'threshold_minutes': thresholdMinutes,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('company_id', companyId)
            .select()
            .single();

        Logger.info(
          'SupabaseAttendanceSettingsService: Settings updated for company $companyId',
        );
        return AttendanceSettings.fromJson(response);
      } else {
        // Create new settings
        final settingsId = UuidGenerator.generateUuid();
        final settingsData = {
          'id': settingsId,
          'company_id': companyId,
          'threshold_minutes': thresholdMinutes,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        final response = await _client
            .from(SupabaseConfig.attendanceSettingsTable)
            .insert(settingsData)
            .select()
            .single();

        Logger.info(
          'SupabaseAttendanceSettingsService: Settings created for company $companyId',
        );
        return AttendanceSettings.fromJson(response);
      }
    } catch (e) {
      Logger.error(
        'SupabaseAttendanceSettingsService: Error setting attendance threshold: $e',
      );
      rethrow;
    }
  }

  /// Delete attendance settings for a company
  Future<bool> deleteAttendanceSettings(String companyId) async {
    try {
      Logger.debug(
        'SupabaseAttendanceSettingsService: Deleting settings for company $companyId',
      );

      await _client
          .from(SupabaseConfig.attendanceSettingsTable)
          .delete()
          .eq('company_id', companyId);

      Logger.info(
        'SupabaseAttendanceSettingsService: Settings deleted for company $companyId',
      );
      return true;
    } catch (e) {
      Logger.error(
        'SupabaseAttendanceSettingsService: Error deleting settings: $e',
      );
      return false;
    }
  }
}
