import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/company_location.dart';
import '../supabase/supabase_config.dart';
import '../supabase/supabase_service.dart';
import '../utils/logger.dart';
import '../utils/uuid_generator.dart';

class SupabaseCompanyLocationService {
  final SupabaseClient _client = SupabaseService.client;

  /// Set admin location for a company
  /// This will either create a new location or update the existing one
  Future<CompanyLocation> setAdminLocation({
    required String companyId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      Logger.debug(
        'SupabaseCompanyLocationService: Setting location for company $companyId',
      );

      // Check if location already exists for this company
      final existingLocation = await getCompanyLocation(companyId);

      if (existingLocation != null) {
        // Update existing location
        final response = await _client
            .from(SupabaseConfig.companyLocationsTable)
            .update({
              'latitude': latitude,
              'longitude': longitude,
              'created_at': DateTime.now().toIso8601String(),
            })
            .eq('company_id', companyId)
            .select()
            .single();

        Logger.info(
          'SupabaseCompanyLocationService: Location updated for company $companyId',
        );
        return CompanyLocation.fromJson(response);
      } else {
        // Create new location
        final locationId = UuidGenerator.generateUuid();
        final locationData = {
          'id': locationId,
          'company_id': companyId,
          'latitude': latitude,
          'longitude': longitude,
          'created_at': DateTime.now().toIso8601String(),
        };

        final response = await _client
            .from(SupabaseConfig.companyLocationsTable)
            .insert(locationData)
            .select()
            .single();

        Logger.info(
          'SupabaseCompanyLocationService: Location created for company $companyId',
        );
        return CompanyLocation.fromJson(response);
      }
    } catch (e) {
      Logger.error(
        'SupabaseCompanyLocationService: Error setting location: $e',
      );
      rethrow;
    }
  }

  /// Get company location by company ID
  Future<CompanyLocation?> getCompanyLocation(String companyId) async {
    try {
      Logger.debug(
        'SupabaseCompanyLocationService: Getting location for company $companyId',
      );

      final response = await _client
          .from(SupabaseConfig.companyLocationsTable)
          .select()
          .eq('company_id', companyId)
          .maybeSingle();

      if (response == null) {
        Logger.info(
          'SupabaseCompanyLocationService: No location found for company $companyId',
        );
        return null;
      }

      Logger.info(
        'SupabaseCompanyLocationService: Location found for company $companyId',
      );
      return CompanyLocation.fromJson(response);
    } catch (e) {
      Logger.error(
        'SupabaseCompanyLocationService: Error getting location: $e',
      );
      return null;
    }
  }

  /// Delete company location
  Future<bool> deleteCompanyLocation(String companyId) async {
    try {
      Logger.debug(
        'SupabaseCompanyLocationService: Deleting location for company $companyId',
      );

      await _client
          .from(SupabaseConfig.companyLocationsTable)
          .delete()
          .eq('company_id', companyId);

      Logger.info(
        'SupabaseCompanyLocationService: Location deleted for company $companyId',
      );
      return true;
    } catch (e) {
      Logger.error(
        'SupabaseCompanyLocationService: Error deleting location: $e',
      );
      return false;
    }
  }

  /// Check if company has a location set
  Future<bool> hasCompanyLocation(String companyId) async {
    try {
      final location = await getCompanyLocation(companyId);
      return location != null;
    } catch (e) {
      Logger.error(
        'SupabaseCompanyLocationService: Error checking location existence: $e',
      );
      return false;
    }
  }
}

