import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/auth_state_manager.dart';
import 'package:hodorak/core/widgets/custom_text_form_field.dart';
import 'package:hodorak/features/auth/views/widgets/login_button.dart';

class AdminPasswordResetScreen extends ConsumerStatefulWidget {
  const AdminPasswordResetScreen({super.key});

  @override
  ConsumerState<AdminPasswordResetScreen> createState() =>
      _AdminPasswordResetScreenState();
}

class _AdminPasswordResetScreenState
    extends ConsumerState<AdminPasswordResetScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authStateManager = ref.read(authStateManagerProvider.notifier);

    try {
      await authStateManager.adminResetUserPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Password Reset Successful'),
            content: Text(
              'Password has been successfully reset for user: ${_emailController.text.trim()}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to admin dashboard
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset User Password'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              verticalSpace(32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.blue.shade600,
                      size: 24.sp,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Admin Only: Reset User Password',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpace(32),
              Row(
                children: [
                  Text(
                    'User Email',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              verticalSpace(8),
              AppTextFormField(
                hintText: 'Enter user email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter user email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              verticalSpace(24),
              Row(
                children: [
                  Text(
                    'New Password',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              verticalSpace(8),
              AppTextFormField(
                hintText: 'Enter new password',
                controller: _passwordController,
                isObscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              verticalSpace(32),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'This will reset the password for the specified user. The user will need to use this new password to log in.',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              verticalSpace(24),
              CustomButtonAuth(
                title: 'Reset Password',
                onPressed: _handleResetPassword,
                isLoading: authState.isLoading,
              ),
              if (authState.error != null) ...[
                verticalSpace(16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade600,
                        size: 20.sp,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
