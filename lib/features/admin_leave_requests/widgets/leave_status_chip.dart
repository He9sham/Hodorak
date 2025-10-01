import 'package:flutter/material.dart';
import 'package:hodorak/features/admin_leave_requests/constants/admin_leave_constants.dart';

class LeaveStatusChip extends StatelessWidget {
  final String status;

  const LeaveStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminLeaveConstants.statusChipPadding,
        vertical: AdminLeaveConstants.statusChipVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(
          AdminLeaveConstants.statusChipBorderRadius,
        ),
        border: Border.all(
          color: statusColor,
          width: AdminLeaveConstants.statusChipBorderWidth,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: AdminLeaveConstants.statusChipTextStyle.copyWith(
          color: statusColor,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AdminLeaveConstants.approvedColor;
      case 'rejected':
        return AdminLeaveConstants.rejectedColor;
      case 'pending':
        return AdminLeaveConstants.pendingColor;
      default:
        return Colors.grey;
    }
  }
}
