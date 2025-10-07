import 'package:flutter/material.dart';
import 'package:hodorak/features/reset_password/constants/admin_user_management_constants.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: AdminUserManagementConstants.iconSize,
            color: Colors.grey,
          ),
          SizedBox(height: AdminUserManagementConstants.padding),
          Text(
            AdminUserManagementConstants.noUsersFound,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
