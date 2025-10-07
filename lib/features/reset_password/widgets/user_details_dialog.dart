import 'package:flutter/material.dart';
import 'package:hodorak/core/models/supabase_user.dart';
import 'package:hodorak/features/reset_password/constants/admin_user_management_constants.dart';

class UserDetailsDialog extends StatelessWidget {
  final SupabaseUser user;

  const UserDetailsDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('User Details - ${user.name}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(AdminUserManagementConstants.email, user.email),
            _buildDetailRow(AdminUserManagementConstants.name, user.name),
            _buildDetailRow(
              AdminUserManagementConstants.jobTitle,
              user.jobTitle ?? AdminUserManagementConstants.na,
            ),
            _buildDetailRow(
              AdminUserManagementConstants.department,
              user.department ?? AdminUserManagementConstants.na,
            ),
            _buildDetailRow(
              AdminUserManagementConstants.phone,
              user.phone ?? AdminUserManagementConstants.na,
            ),
            _buildDetailRow(
              AdminUserManagementConstants.nationalId,
              user.nationalId ?? AdminUserManagementConstants.na,
            ),
            _buildDetailRow(
              AdminUserManagementConstants.gender,
              user.gender ?? AdminUserManagementConstants.na,
            ),
            _buildDetailRow(
              AdminUserManagementConstants.adminStatus,
              user.isAdmin
                  ? AdminUserManagementConstants.yes
                  : AdminUserManagementConstants.no,
            ),
            _buildDetailRow(
              AdminUserManagementConstants.companyId,
              user.companyId ?? AdminUserManagementConstants.na,
            ),
            _buildDetailRow(
              AdminUserManagementConstants.created,
              _formatDate(user.createdAt),
            ),
            _buildDetailRow(
              AdminUserManagementConstants.updated,
              _formatDate(user.updatedAt),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AdminUserManagementConstants.close),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AdminUserManagementConstants.detailLabelWidth,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? AdminUserManagementConstants.na : value,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return AdminUserManagementConstants.na;
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
