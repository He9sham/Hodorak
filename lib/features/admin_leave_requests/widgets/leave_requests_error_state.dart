import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/features/admin_leave_requests/constants/admin_leave_constants.dart';

class LeaveRequestsErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const LeaveRequestsErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red.shade300),
          const SizedBox(height: AdminLeaveConstants.cardMargin),
          Text(
            AdminLeaveConstants.errorTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: AdminLeaveConstants.cardMargin),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text(AdminLeaveConstants.retryButtonText),
          ),
        ],
      ),
    );
  }
}
