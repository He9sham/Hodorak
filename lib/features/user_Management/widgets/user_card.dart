import 'package:flutter/material.dart';
import 'package:hodorak/core/models/supabase_user.dart';
import 'package:hodorak/features/user_Management/constants/admin_user_management_constants.dart';

class UserCard extends StatelessWidget {
  final SupabaseUser user;
  final VoidCallback onResetPassword;
  final VoidCallback onDeleteEmployee;

  const UserCard({
    super.key,
    required this.user,
    required this.onResetPassword,
    required this.onDeleteEmployee,
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
    final List<PopupMenuEntry<String>> menuItems = [
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
    ];

    // Only show delete option for non-admin users
    if (!user.isAdmin) {
      menuItems.add(
        const PopupMenuItem(
          value: 'delete_employee',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: AdminUserManagementConstants.errorColor,
              ),
              SizedBox(width: 8),
              Text(AdminUserManagementConstants.deleteEmployee),
            ],
          ),
        ),
      );
    }

    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'reset_password':
            onResetPassword();
            break;
          case 'delete_employee':
            onDeleteEmployee();
            break;
        }
      },
      itemBuilder: (context) => menuItems,
    );
  }
}
