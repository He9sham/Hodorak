import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/services/supabase_auth_service.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:hodorak/features/user_Management/models/password_reset_request.dart';
import 'package:hodorak/features/user_Management/models/user_management_state.dart';

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
        error: 'An unexpected error occurred. Please try again',
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

  Future<bool> deleteUser(String userId) async {
    if (state.isDeletingUser) return false;

    state = state.copyWith(isDeletingUser: true);

    try {
      final success = await _authService.deleteUser(userId);

      if (success) {
        Logger.info('User deleted successfully: $userId');
        // Reload users to refresh the list
        await loadUsers();
      } else {
        Logger.error('Failed to delete user: $userId');
      }

      return success;
    } catch (e) {
      Logger.error('Delete user error: $e');
      return false;
    } finally {
      state = state.copyWith(isDeletingUser: false);
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
