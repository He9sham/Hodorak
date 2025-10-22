import 'package:flutter/material.dart';
import 'package:hodorak/features/user_Management/constants/admin_user_management_constants.dart';

class ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AdminUserManagementConstants.iconSize,
            color: Colors.red[300],
          ),
          const SizedBox(height: AdminUserManagementConstants.padding),
          Text(
            AdminUserManagementConstants.errorLoadingUsers,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[600]),
          ),
          const SizedBox(height: AdminUserManagementConstants.padding),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text(AdminUserManagementConstants.retry),
          ),
        ],
      ),
    );
  }
}
