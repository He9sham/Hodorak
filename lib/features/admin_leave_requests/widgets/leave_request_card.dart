import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/leave_request.dart';
import 'package:hodorak/features/admin_leave_requests/constants/admin_leave_constants.dart';
import 'package:hodorak/features/admin_leave_requests/providers/admin_leave_providers.dart';
import 'package:hodorak/features/admin_leave_requests/widgets/leave_action_buttons.dart';
import 'package:hodorak/features/admin_leave_requests/widgets/leave_request_detail_row.dart';
import 'package:hodorak/features/admin_leave_requests/widgets/leave_status_chip.dart';

class LeaveRequestCard extends ConsumerWidget {
  final LeaveRequest request;

  const LeaveRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProcessing =
        ref.watch(processingRequestsProvider)[request.id] ?? false;
    final actions = ref.watch(leaveRequestActionsProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: AdminLeaveConstants.cardMargin),
      child: Padding(
        padding: const EdgeInsets.all(AdminLeaveConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            _buildHeader(),
            const SizedBox(height: AdminLeaveConstants.detailRowSpacing),

            // Request details
            _buildDetails(),

            // Action buttons (only for pending requests)
            if (request.status == 'pending') ...[
              const SizedBox(height: AdminLeaveConstants.cardMargin),
              const Divider(),
              const SizedBox(height: AdminLeaveConstants.cardMargin),
              LeaveActionButtons(
                requestId: request.id,
                isProcessing: isProcessing,
                onApprove: () => actions.approveRequest(request.id),
                onReject: () => actions.rejectRequest(request.id),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        LeaveStatusChip(status: request.status),
        const Spacer(),
        Text(
          '${AdminLeaveConstants.userIdLabel}: ${request.userId}',
          style: AdminLeaveConstants.userIdStyle.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      children: [
        LeaveRequestDetailRow(
          icon: Icons.description,
          label: AdminLeaveConstants.reasonLabel,
          value: request.reason,
        ),
        const SizedBox(height: 8),
        LeaveRequestDetailRow(
          icon: Icons.calendar_today,
          label: AdminLeaveConstants.startDateLabel,
          value: _formatDate(request.startDate),
        ),
        const SizedBox(height: 8),
        LeaveRequestDetailRow(
          icon: Icons.calendar_today,
          label: AdminLeaveConstants.endDateLabel,
          value: _formatDate(request.endDate),
        ),
        const SizedBox(height: 8),
        LeaveRequestDetailRow(
          icon: Icons.access_time,
          label: AdminLeaveConstants.submittedLabel,
          value: _formatDateTime(request.createdAt),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
