import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/supabase_user.dart';
import 'package:hodorak/features/reset_password/constants/admin_user_management_constants.dart';
import 'package:hodorak/features/reset_password/models/password_reset_request.dart';
import 'package:hodorak/features/reset_password/models/user_management_state.dart';
import 'package:hodorak/features/reset_password/viewmodels/admin_user_management_viewmodel.dart';
import 'package:hodorak/features/reset_password/widgets/delete_employee_dialog.dart';
import 'package:hodorak/features/reset_password/widgets/empty_state.dart';
import 'package:hodorak/features/reset_password/widgets/error_state.dart';
import 'package:hodorak/features/reset_password/widgets/loading_dialog.dart';
import 'package:hodorak/features/reset_password/widgets/password_reset_dialog.dart';
import 'package:hodorak/features/reset_password/widgets/user_card.dart';

class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState
    extends ConsumerState<AdminUserManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load users when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminUserManagementProvider.notifier).loadUsers();
    });
  }

  Future<void> _resetUserPassword(SupabaseUser user) async {
    await showDialog<void>(
      context: context,
      builder: (context) => PasswordResetDialog(
        user: user,
        onConfirm: (newPassword) =>
            _performPasswordReset(user.email, newPassword),
      ),
    );
  }

  Future<void> _performPasswordReset(
    String userEmail,
    String newPassword,
  ) async {
    final viewModel = ref.read(adminUserManagementProvider.notifier);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(
        message: AdminUserManagementConstants.resettingPassword,
      ),
    );

    try {
      final request = PasswordResetRequest(
        userEmail: userEmail,
        newPassword: newPassword,
      );

      final success = await viewModel.resetUserPassword(request);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (success) {
          _showSnackBar(
            'Password reset successfully for $userEmail',
            AdminUserManagementConstants.successColor,
          );
        } else {
          _showSnackBar(
            AdminUserManagementConstants.passwordResetFailed,
            AdminUserManagementConstants.errorColor,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showSnackBar('Error: $e', AdminUserManagementConstants.errorColor);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: backgroundColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUserManagementProvider);
    final viewModel = ref.read(adminUserManagementProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AdminUserManagementConstants.title),
        backgroundColor: AdminUserManagementConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading ? null : viewModel.refresh,
            tooltip: AdminUserManagementConstants.refresh,
          ),
        ],
      ),
      body: _buildBody(state, viewModel),
    );
  }

  Widget _buildBody(
    UserManagementState state,
    AdminUserManagementNotifier viewModel,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isError) {
      return ErrorState(
        error: state.error ?? 'Unknown error occurred',
        onRetry: viewModel.refresh,
      );
    }

    if (state.isEmpty) {
      return const EmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => viewModel.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AdminUserManagementConstants.padding),
        itemCount: state.users.length,
        itemBuilder: (context, index) {
          final user = state.users[index];
          return UserCard(
            user: user,
            onResetPassword: () => _resetUserPassword(user),
            onDeleteEmployee: () => _deleteUser(user),
          );
        },
      ),
    );
  }

  Future<void> _deleteUser(SupabaseUser user) async {
    await showDialog<void>(
      context: context,
      builder: (context) => DeleteEmployeeDialog(
        user: user,
        onConfirm: () => _performUserDeletion(user.id),
      ),
    );
  }

  Future<void> _performUserDeletion(String userId) async {
    final viewModel = ref.read(adminUserManagementProvider.notifier);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(
        message: AdminUserManagementConstants.deletingEmployee,
      ),
    );

    try {
      final success = await viewModel.deleteUser(userId);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (success) {
          _showSnackBar(
            AdminUserManagementConstants.deleteEmployeeSuccess,
            AdminUserManagementConstants.successColor,
          );
        } else {
          _showSnackBar(
            AdminUserManagementConstants.deleteEmployeeFailed,
            AdminUserManagementConstants.errorColor,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        String errorMessage = 'Error: $e';
        if (e.toString().contains('Cannot delete administrator accounts')) {
          errorMessage = AdminUserManagementConstants.cannotDeleteAdmin;
        }

        _showSnackBar(errorMessage, AdminUserManagementConstants.errorColor);
      }
    }
  }
}
