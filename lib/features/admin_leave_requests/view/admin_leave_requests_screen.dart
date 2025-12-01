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
    final leaveRequestsAsync = ref.watch(filteredLeaveRequestsProvider);
    final leaveRequestActions = ref.watch(leaveRequestActionsProvider);
    final isDeleteAllLoading = ref.watch(deleteAllLoadingProvider);
    final selectedStatus = ref.watch(selectedFilterStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AdminLeaveConstants.screenTitle,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AdminLeaveConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(leaveRequestsProvider),
            tooltip: 'Refresh',
          ),
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
                error: (_, _) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Padding(
            padding: const EdgeInsets.all(AdminLeaveConstants.cardMargin),
            child: Row(
              children: [
                _buildFilterButton(
                  context,
                  ref,
                  label: 'All',
                  filterValue: null,
                  isSelected: selectedStatus == null,
                ),
                const SizedBox(width: 8),
                _buildFilterButton(
                  context,
                  ref,
                  label: 'Approved',
                  filterValue: 'approved',
                  isSelected: selectedStatus == 'approved',
                ),
                const SizedBox(width: 8),
                _buildFilterButton(
                  context,
                  ref,
                  label: 'Rejected',
                  filterValue: 'rejected',
                  isSelected: selectedStatus == 'rejected',
                ),
              ],
            ),
          ),
          // Leave requests list
          Expanded(
            child: leaveRequestsAsync.when(
              data: (requests) {
                if (requests.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(leaveRequestsProvider),
                    child: const LeaveRequestsEmptyState(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(leaveRequestsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AdminLeaveConstants.cardMargin,
                    ),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return LeaveRequestCard(request: request);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                return LeaveRequestsErrorState(
                  error: error.toString(),
                  onRetry: () => ref.invalidate(leaveRequestsProvider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String? filterValue,
    required bool isSelected,
  }) {
    return ElevatedButton(
      onPressed: () {
        ref.read(selectedFilterStatusProvider.notifier).setStatus(filterValue);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? AdminLeaveConstants.primaryColor
            : Colors.grey[300],
        foregroundColor: isSelected
            ? Colors.white
            : AdminLeaveConstants.primaryColor,
        side: BorderSide(
          color: AdminLeaveConstants.primaryColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Text(label),
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
