import 'package:flutter/material.dart';
import 'package:hodorak/core/models/supabase_user.dart';
import 'package:hodorak/features/user_Management/constants/admin_user_management_constants.dart';

class DeleteEmployeeDialog extends StatelessWidget {
  final SupabaseUser user;
  final VoidCallback onConfirm;

  const DeleteEmployeeDialog({
    super.key,
    required this.user,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: AdminUserManagementConstants.warningColor),
          const SizedBox(width: 8),
          const Text(AdminUserManagementConstants.deleteEmployeeConfirm),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AdminUserManagementConstants.deleteEmployeeMessage),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee Details:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Name: ${user.name}'),
                Text('Email: ${user.email}'),
                if (user.jobTitle?.isNotEmpty == true)
                  Text('Job Title: ${user.jobTitle}'),
                if (user.department?.isNotEmpty == true)
                  Text('Department: ${user.department}'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AdminUserManagementConstants.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminUserManagementConstants.errorColor,
            foregroundColor: Colors.white,
          ),
          child: const Text(AdminUserManagementConstants.deleteEmployeeConfirm),
        ),
      ],
    );
  }
}
