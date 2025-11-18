import 'package:hodorak/core/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/supabase_user.dart';

import '../supabase/supabase_service.dart';
import '../utils/logger.dart';
import 'service_locator.dart';

class SupabaseAuthService {
  final SupabaseClient _client = SupabaseService.client;

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return _client.auth.currentUser != null;
  }

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      Logger.debug('SupabaseAuthService: Attempting login for $email');

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }

      // Get user profile from database
      final userProfile = await getUserProfile(response.user!.id);

      Logger.info(
        'SupabaseAuthService: Login successful for ${response.user!.email}',
      );

      return {
        'uid': response.user!.id,
        'email': response.user!.email,
        'profile': userProfile,
      };
    } catch (e) {
      Logger.error('SupabaseAuthService: Login failed: $e');
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('Invalid email or password. Please try again.');
      }
      rethrow;
    }
  }

  // Sign up new user
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String jobTitle,
    required String department,
    required String phone,
    required String nationalId,
    required String gender,
    required String companyId,
    bool isAdmin = false,
  }) async {
    try {
      Logger.debug('SupabaseAuthService: Creating user account for $email');

      // First create auth user
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'job_title': jobTitle,
          'department': department,
          'phone': phone,
          'national_id': nationalId,
          'gender': gender,
        },
      );

      if (response.user == null) {
        throw Exception('Failed to create user account');
      }

      // Create user profile in database (use upsert to handle trigger-created profile)
      final userData = {
        'id': response.user!.id,
        'email': email,
        'name': name,
        'job_title': jobTitle,
        'department': department,
        'phone': phone,
        'national_id': nationalId,
        'gender': gender,
        'is_admin': isAdmin,
        'company_id': companyId.isNotEmpty ? companyId : null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from(SupabaseConfig.usersTable).upsert(userData);

      // If user is admin and created a new company, update the company's admin_user_id
      if (isAdmin) {
        try {
          await supabaseCompanyService.updateCompanyAdmin(
            companyId: companyId,
            adminUserId: response.user!.id,
          );
        } catch (e) {
          Logger.error('SupabaseAuthService: Error updating company admin: $e');
          // Don't fail the signup if company admin update fails
        }
      }

      Logger.info('SupabaseAuthService: User created successfully for $email');

      return {'uid': response.user!.id, 'email': response.user!.email};
    } catch (e) {
      Logger.error('SupabaseAuthService: Sign up failed: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<SupabaseUser?> getUserProfile([String? userId]) async {
    try {
      final targetUserId = userId ?? currentUser?.id;
      if (targetUserId == null) return null;

      final data = await _client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', targetUserId)
          .single();

      return SupabaseUser.fromJson(data);
    } catch (e) {
      Logger.error('SupabaseAuthService: Error getting user profile: $e');
      return null;
    }
  }

  // Check if current user is admin
  Future<bool> isAdmin() async {
    try {
      final profile = await getUserProfile();
      return profile?.isAdmin ?? false;
    } catch (e) {
      Logger.error('SupabaseAuthService: Error checking admin status: $e');
      return false;
    }
  }

  // Reset user password (admin only)
  Future<bool> resetUserPassword({
    required String userEmail,
    required String newPassword,
  }) async {
    try {
      // Check if current user is admin
      final isAdminUser = await isAdmin();
      if (!isAdminUser) {
        throw Exception('Only administrators can reset user passwords');
      }

      // Get current session token
      final session = _client.auth.currentSession;
      if (session == null) {
        throw Exception('No active session found');
      }

      // Call the Edge Function to reset password
      final response = await _client.functions.invoke(
        'admin-reset-password',
        body: {'userEmail': userEmail, 'newPassword': newPassword},
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error'] ?? 'Password reset failed';
        throw Exception(errorMessage);
      }

      final responseData = response.data as Map<String, dynamic>;
      final success = responseData['success'] as bool? ?? false;

      if (success) {
        Logger.info(
          'SupabaseAuthService: Password reset successful for $userEmail',
        );
        return true;
      } else {
        throw Exception('Password reset failed');
      }
    } catch (e) {
      Logger.error('SupabaseAuthService: Password reset failed: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
      Logger.info('SupabaseAuthService: User logged out successfully');
    } catch (e) {
      Logger.error('SupabaseAuthService: Logout failed: $e');
      rethrow;
    }
  }

  // Get all users (admin only)
  Future<List<SupabaseUser>> getAllUsers() async {
    try {
      final isAdminUser = await isAdmin();
      if (!isAdminUser) {
        throw Exception('Only administrators can view all users');
      }

      final data = await _client
          .from(SupabaseConfig.usersTable)
          .select()
          .order('created_at', ascending: false);

      return (data as List).map((user) => SupabaseUser.fromJson(user)).toList();
    } catch (e) {
      Logger.error('SupabaseAuthService: Error fetching users: $e');
      rethrow;
    }
  }

  // Create employee (admin only) - automatically assigns admin's company ID
  Future<Map<String, dynamic>> createEmployee({
    required String name,
    required String email,
    required String password,
    required String jobTitle,
    required String department,
    required String phone,
    required String nationalId,
    required String gender,
  }) async {
    try {
      // Check if current user is admin
      final isAdminUser = await isAdmin();
      if (!isAdminUser) {
        throw Exception('Only administrators can create employees');
      }

      // Get current admin's profile to retrieve company ID
      final adminProfile = await getUserProfile();
      if (adminProfile == null || adminProfile.companyId == null) {
        throw Exception('Admin user must be associated with a company');
      }

      Logger.debug(
        'SupabaseAuthService: Creating employee $email for company ${adminProfile.companyId}',
      );

      // Create the employee using the admin's company ID
      final result = await signUp(
        name: name,
        email: email,
        password: password,
        jobTitle: jobTitle,
        department: department,
        phone: phone,
        nationalId: nationalId,
        gender: gender,
        companyId: adminProfile.companyId!, // Use admin's company ID
        isAdmin: false, // Employee is not admin
      );

      Logger.info(
        'SupabaseAuthService: Employee created successfully for $email',
      );
      return result;
    } catch (e) {
      Logger.error('SupabaseAuthService: Employee creation failed: $e');
      rethrow;
    }
  }

  // Get employees for current admin's company
  Future<List<SupabaseUser>> getCompanyEmployees() async {
    try {
      // Check if current user is admin
      final isAdminUser = await isAdmin();
      if (!isAdminUser) {
        throw Exception('Only administrators can view company employees');
      }

      // Get current admin's profile to retrieve company ID
      final adminProfile = await getUserProfile();
      if (adminProfile == null || adminProfile.companyId == null) {
        throw Exception('Admin user must be associated with a company');
      }

      // Get all users from the same company
      final data = await _client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('company_id', adminProfile.companyId!)
          .order('created_at', ascending: false);

      return (data as List).map((user) => SupabaseUser.fromJson(user)).toList();
    } catch (e) {
      Logger.error('SupabaseAuthService: Error fetching company employees: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      // Check if current user is admin or updating their own profile
      final isAdminUser = await isAdmin();
      final currentUserId = currentUser?.id;

      if (!isAdminUser && currentUserId != userId) {
        throw Exception('You can only update your own profile');
      }

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _client
          .from(SupabaseConfig.usersTable)
          .update(updates)
          .eq('id', userId);

      Logger.info('SupabaseAuthService: Profile updated for user $userId');
    } catch (e) {
      Logger.error('SupabaseAuthService: Error updating profile: $e');
      rethrow;
    }
  }

  // Delete user (admin only)
  Future<bool> deleteUser(String userId) async {
    try {
      // Check if current user is admin
      final isAdminUser = await isAdmin();
      if (!isAdminUser) {
        throw Exception('Only administrators can delete users');
      }

      // Prevent admin from deleting themselves
      final currentUserId = currentUser?.id;
      if (currentUserId == userId) {
        throw Exception('You cannot delete your own account');
      }

      // Get the target user's profile to check if they are admin
      final targetUser = await getUserProfile(userId);
      if (targetUser == null) {
        throw Exception('User not found');
      }

      // Prevent deletion of admin users
      if (targetUser.isAdmin) {
        throw Exception('Cannot delete administrator accounts');
      }

      Logger.debug('SupabaseAuthService: Deleting user $userId');

      // Delete from users table first (this should cascade to other tables)
      await _client.from(SupabaseConfig.usersTable).delete().eq('id', userId);

      Logger.info('SupabaseAuthService: User deleted successfully: $userId');
      return true;
    } catch (e) {
      Logger.error('SupabaseAuthService: Error deleting user: $e');
      rethrow;
    }
  }
}
