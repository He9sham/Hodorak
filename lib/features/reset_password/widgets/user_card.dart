import 'package:flutter/material.dart';
import 'package:hodorak/core/models/supabase_user.dart';
import 'package:hodorak/features/reset_password/constants/admin_user_management_constants.dart';

class UserCard extends StatelessWidget {
  final SupabaseUser user;
  final VoidCallback onResetPassword;
  final VoidCallback onViewDetails;

  const UserCard({
    super.key,
    required this.user,
    required this.onResetPassword,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: AdminUserManagementConstants.cardMargin,
      ),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isAdmin
              ? AdminUserManagementConstants.adminColor
              : AdminUserManagementConstants.primaryColor,
          radius: AdminUserManagementConstants.avatarRadius,
          child: Icon(
            user.isAdmin ? Icons.admin_panel_settings : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: _buildSubtitle(),
        trailing: _buildPopupMenu(),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(user.email),
        if (user.jobTitle?.isNotEmpty == true)
          Text('${user.jobTitle} - ${user.department}'),
        if (user.isAdmin)
          const Text(
            AdminUserManagementConstants.administrator,
            style: TextStyle(
              color: AdminUserManagementConstants.adminColor,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'reset_password':
            onResetPassword();
            break;
          case 'view_details':
            onViewDetails();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'reset_password',
          child: Row(
            children: [
              Icon(
                Icons.lock_reset,
                color: AdminUserManagementConstants.warningColor,
              ),
              SizedBox(width: 8),
              Text(AdminUserManagementConstants.resetPassword),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'view_details',
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AdminUserManagementConstants.primaryColor,
              ),
              SizedBox(width: 8),
              Text(AdminUserManagementConstants.viewDetails),
            ],
          ),
        ),
      ],
    );
  }
}
