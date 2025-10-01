import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/features/admin_leave_requests/constants/admin_leave_constants.dart';
import 'package:hodorak/features/admin_leave_requests/providers/admin_leave_providers.dart';
import 'package:hodorak/features/admin_leave_requests/widgets/leave_request_card.dart';
import 'package:hodorak/features/admin_leave_requests/widgets/leave_requests_empty_state.dart';
import 'package:hodorak/features/admin_leave_requests/widgets/leave_requests_error_state.dart';

class AdminLeaveRequestsScreen extends ConsumerWidget {
  const AdminLeaveRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaveRequestsAsync = ref.watch(leaveRequestsStreamProvider);
    final leaveRequestActions = ref.watch(leaveRequestActionsProvider);
    final isDeleteAllLoading = ref.watch(deleteAllLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AdminLeaveConstants.screenTitle),
        backgroundColor: AdminLeaveConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              return leaveRequestsAsync.when(
                data: (requests) {
                  if (requests.isEmpty) return const SizedBox.shrink();

                  return IconButton(
                    icon: isDeleteAllLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.delete_forever),
                    onPressed: isDeleteAllLoading
                        ? null
                        : () => _showDeleteAllConfirmationDialog(
                            context,
                            ref,
                            leaveRequestActions,
                          ),
                    tooltip: AdminLeaveConstants.deleteAllButtonText,
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: leaveRequestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const LeaveRequestsEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AdminLeaveConstants.cardMargin),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return LeaveRequestCard(request: request);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return LeaveRequestsErrorState(
            error: error.toString(),
            onRetry: () => ref.invalidate(leaveRequestsStreamProvider),
          );
        },
      ),
    );
  }

  void _showDeleteAllConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    LeaveRequestActions leaveRequestActions,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AdminLeaveConstants.deleteAllConfirmTitle),
          content: const Text(AdminLeaveConstants.deleteAllConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AdminLeaveConstants.deleteAllCancelButtonText),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAllRequests(context, ref, leaveRequestActions);
              },
              style: TextButton.styleFrom(
                foregroundColor: AdminLeaveConstants.errorColor,
              ),
              child: const Text(AdminLeaveConstants.deleteAllConfirmButtonText),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllRequests(
    BuildContext context,
    WidgetRef ref,
    LeaveRequestActions leaveRequestActions,
  ) async {
    // Check if the widget is still mounted
    if (!context.mounted) return;

    try {
      await leaveRequestActions.deleteAllRequests();

      // Check if the widget is still mounted before showing success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AdminLeaveConstants.deleteAllSuccessMessage),
            backgroundColor: AdminLeaveConstants.successColor,
          ),
        );
      }
    } catch (e) {
      // Check if the widget is still mounted before showing error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AdminLeaveConstants.deleteAllErrorMessage}: $e'),
            backgroundColor: AdminLeaveConstants.errorColor,
          ),
        );
      }
    }
  }
}
