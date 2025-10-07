import 'package:flutter/material.dart';
import 'package:hodorak/features/reset_password/constants/admin_user_management_constants.dart';

class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: AdminUserManagementConstants.padding),
          Text(message),
        ],
      ),
    );
  }
}
