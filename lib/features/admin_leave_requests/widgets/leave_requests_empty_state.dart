import 'package:flutter/material.dart';
import 'package:hodorak/features/admin_leave_requests/constants/admin_leave_constants.dart';

class LeaveRequestsEmptyState extends StatelessWidget {
  const LeaveRequestsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: AdminLeaveConstants.cardMargin),
          Text(
            AdminLeaveConstants.noRequestsTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            AdminLeaveConstants.noRequestsSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
