import 'package:flutter/material.dart';
import 'package:hodorak/features/admin_leave_requests/constants/admin_leave_constants.dart';

class LeaveRequestDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const LeaveRequestDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: AdminLeaveConstants.iconSize,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: AdminLeaveConstants.detailRowSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AdminLeaveConstants.detailLabelStyle.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: AdminLeaveConstants.detailValueStyle),
            ],
          ),
        ),
      ],
    );
  }
}
