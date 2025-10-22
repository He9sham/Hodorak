import 'package:flutter/material.dart';
import 'package:hodorak/core/models/supabase_user.dart';
import 'package:hodorak/features/user_Management/constants/admin_user_management_constants.dart';

class PasswordResetDialog extends StatefulWidget {
  final SupabaseUser user;
  final Function(String) onConfirm;

  const PasswordResetDialog({
    super.key,
    required this.user,
    required this.onConfirm,
  });

  @override
  State<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '${AdminUserManagementConstants.resetPassword} for ${widget.user.name}',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${AdminUserManagementConstants.enterNewPassword} ${widget.user.email}',
            ),
            const SizedBox(height: AdminUserManagementConstants.padding),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: AdminUserManagementConstants.newPassword,
                border: OutlineInputBorder(),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: AdminUserManagementConstants.padding),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: AdminUserManagementConstants.confirmPassword,
                border: OutlineInputBorder(),
              ),
              validator: _validateConfirmPassword,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AdminUserManagementConstants.cancel),
        ),
        ElevatedButton(
          onPressed: _handleReset,
          child: const Text(AdminUserManagementConstants.resetPassword),
        ),
      ],
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AdminUserManagementConstants.pleaseEnterPassword;
    }
    if (value.length < AdminUserManagementConstants.minPasswordLength) {
      return AdminUserManagementConstants.passwordTooShort;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _newPasswordController.text) {
      return AdminUserManagementConstants.passwordsDoNotMatch;
    }
    return null;
  }

  void _handleReset() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onConfirm(_newPasswordController.text);
      Navigator.of(context).pop();
    }
  }
}
