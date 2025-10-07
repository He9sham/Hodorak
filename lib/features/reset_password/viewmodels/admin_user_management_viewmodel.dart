import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/services/supabase_auth_service.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:hodorak/features/reset_password/models/password_reset_request.dart';
import 'package:hodorak/features/reset_password/models/user_management_state.dart';

class AdminUserManagementNotifier extends Notifier<UserManagementState> {
  final SupabaseAuthService _authService = SupabaseAuthService();

  @override
  UserManagementState build() {
    return const UserManagementState();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(type: UserManagementStateType.loading, error: null);

    try {
      final users = await _authService.getAllUsers();
      state = state.copyWith(
        type: users.isEmpty
            ? UserManagementStateType.empty
            : UserManagementStateType.success,
        users: users,
      );
    } catch (e) {
      state = state.copyWith(
        type: UserManagementStateType.error,
        error: e.toString(),
      );
      Logger.error('Failed to load users: $e');
    }
  }

  Future<bool> resetUserPassword(PasswordResetRequest request) async {
    if (state.isResettingPassword) return false;

    state = state.copyWith(isResettingPassword: true);

    try {
      final success = await _authService.resetUserPassword(
        userEmail: request.userEmail,
        newPassword: request.newPassword,
      );

      if (success) {
        Logger.info('Password reset successful for ${request.userEmail}');
      } else {
        Logger.error('Password reset failed for ${request.userEmail}');
      }

      return success;
    } catch (e) {
      Logger.error('Password reset error: $e');
      return false;
    } finally {
      state = state.copyWith(isResettingPassword: false);
    }
  }

  void clearError() {
    if (state.isError) {
      state = state.copyWith(
        type: UserManagementStateType.initial,
        error: null,
      );
    }
  }

  void refresh() {
    loadUsers();
  }
}

// Provider for the Notifier
final adminUserManagementProvider =
    NotifierProvider<AdminUserManagementNotifier, UserManagementState>(
      () => AdminUserManagementNotifier(),
    );
