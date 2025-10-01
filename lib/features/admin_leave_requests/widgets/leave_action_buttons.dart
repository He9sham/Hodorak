import 'package:flutter/material.dart';
import 'package:hodorak/features/admin_leave_requests/constants/admin_leave_constants.dart';

class LeaveActionButtons extends StatelessWidget {
  final String requestId;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const LeaveActionButtons({
    super.key,
    required this.requestId,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isProcessing ? null : onApprove,
            icon: _buildButtonIcon(Icons.check),
            label: const Text(AdminLeaveConstants.approveButtonText),
            style: OutlinedButton.styleFrom(
              foregroundColor: AdminLeaveConstants.approvedColor,
              side: const BorderSide(color: AdminLeaveConstants.approvedColor),
            ),
          ),
        ),
        const SizedBox(width: AdminLeaveConstants.buttonSpacing),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isProcessing ? null : onReject,
            icon: _buildButtonIcon(Icons.close),
            label: const Text(AdminLeaveConstants.rejectButtonText),
            style: OutlinedButton.styleFrom(
              foregroundColor: AdminLeaveConstants.rejectedColor,
              side: const BorderSide(color: AdminLeaveConstants.rejectedColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonIcon(IconData icon) {
    if (isProcessing) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Icon(icon);
  }
}
