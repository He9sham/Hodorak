import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/supabase_company.dart';
import '../supabase/supabase_config.dart';
import '../supabase/supabase_service.dart';
import '../utils/logger.dart';
import '../utils/uuid_generator.dart';

class SupabaseCompanyService {
  final SupabaseClient _client = SupabaseService.client;

  // Create a new company
  Future<SupabaseCompany> createCompany({
    required String name,
    String? adminUserId,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? website,
  }) async {
    try {
      Logger.debug('SupabaseCompanyService: Creating company $name');

      // Generate a unique company ID
      final companyId = UuidGenerator.generateUuid();

      final companyData = {
        'id': companyId, // Explicitly set the company ID
        'name': name,
        'admin_user_id': adminUserId,
        'description': description,
        'address': address,
        'phone': phone,
        'email': email,
        'website': website,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from(SupabaseConfig.companiesTable)
          .insert(companyData)
          .select()
          .single();

      Logger.info(
        'SupabaseCompanyService: Company created successfully: $name',
      );
      return SupabaseCompany.fromJson(response);
    } catch (e) {
      Logger.error('SupabaseCompanyService: Error creating company: $e');
      rethrow;
    }
  }

  // Update company admin user ID
  Future<SupabaseCompany> updateCompanyAdmin({
    required String companyId,
    required String adminUserId,
  }) async {
    try {
      final response = await _client
          .from(SupabaseConfig.companiesTable)
          .update({
            'admin_user_id': adminUserId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', companyId)
          .select()
          .single();

      Logger.info('SupabaseCompanyService: Company admin updated: $companyId');
      return SupabaseCompany.fromJson(response);
    } catch (e) {
      Logger.error('SupabaseCompanyService: Error updating company admin: $e');
      rethrow;
    }
  }

  // Get company by ID
  Future<SupabaseCompany?> getCompanyById(String companyId) async {
    try {
      final data = await _client
          .from(SupabaseConfig.companiesTable)
          .select()
          .eq('id', companyId)
          .single();

      return SupabaseCompany.fromJson(data);
    } catch (e) {
      Logger.error('SupabaseCompanyService: Error getting company: $e');
      return null;
    }
  }

  // Get company by admin user ID
  Future<SupabaseCompany?> getCompanyByAdminId(String adminUserId) async {
    try {
      final data = await _client
          .from(SupabaseConfig.companiesTable)
          .select()
          .eq('admin_user_id', adminUserId)
          .single();

      return SupabaseCompany.fromJson(data);
    } catch (e) {
      Logger.error(
        'SupabaseCompanyService: Error getting company by admin: $e',
      );
      return null;
    }
  }

  // Get all companies (admin only)
  Future<List<SupabaseCompany>> getAllCompanies() async {
    try {
      final data = await _client
          .from(SupabaseConfig.companiesTable)
          .select()
          .order('created_at', ascending: false);

      return (data as List)
          .map((company) => SupabaseCompany.fromJson(company))
          .toList();
    } catch (e) {
      Logger.error('SupabaseCompanyService: Error fetching companies: $e');
      rethrow;
    }
  }

  // Update company
  Future<SupabaseCompany> updateCompany({
    required String companyId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from(SupabaseConfig.companiesTable)
          .update(updates)
          .eq('id', companyId)
          .select()
          .single();

      Logger.info('SupabaseCompanyService: Company updated: $companyId');
      return SupabaseCompany.fromJson(response);
    } catch (e) {
      Logger.error('SupabaseCompanyService: Error updating company: $e');
      rethrow;
    }
  }

  // Delete company (admin only)
  Future<void> deleteCompany(String companyId) async {
    try {
      await _client
          .from(SupabaseConfig.companiesTable)
          .delete()
          .eq('id', companyId);

      Logger.info('SupabaseCompanyService: Company deleted: $companyId');
    } catch (e) {
      Logger.error('SupabaseCompanyService: Error deleting company: $e');
      rethrow;
    }
  }

  // Check if company name exists
  Future<bool> companyNameExists(String name) async {
    try {
      final data = await _client
          .from(SupabaseConfig.companiesTable)
          .select('id')
          .eq('name', name)
          .limit(1);

      return data.isNotEmpty;
    } catch (e) {
      Logger.error('SupabaseCompanyService: Error checking company name: $e');
      return false;
    }
  }

  // Search companies by name
  Future<List<SupabaseCompany>> searchCompanies(String query) async {
    try {
      final data = await _client
          .from(SupabaseConfig.companiesTable)
          .select()
          .ilike('name', '%$query%')
          .order('name');

      return (data as List)
          .map((company) => SupabaseCompany.fromJson(company))
          .toList();
    } catch (e) {
      Logger.error('SupabaseCompanyService: Error searching companies: $e');
      rethrow;
    }
  }
}
