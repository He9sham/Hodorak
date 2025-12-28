import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/shift.dart';
import 'package:hodorak/features/shift_management/view_models/admin_shift_view_model.dart';
import 'package:hodorak/features/shift_management/views/widgets/add_shift_dialog.dart';
import 'package:hodorak/features/shift_management/views/widgets/assign_employee_dialog.dart';
import 'package:hodorak/features/shift_management/views/widgets/shift_card.dart';

/// Shift Management Screen for Admins
///
/// Features:
/// - Display all company shifts
/// - Add new shifts via dialog
/// - Assign employees to shifts
/// - Real-time Supabase integration (via Riverpod)
class ShiftManagementScreen extends ConsumerStatefulWidget {
  const ShiftManagementScreen({super.key});

  @override
  ConsumerState<ShiftManagementScreen> createState() =>
      _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends ConsumerState<ShiftManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final shiftState = ref.watch(adminShiftViewModelProvider);

    // Listen for errors
    ref.listen(adminShiftViewModelProvider.select((s) => s.error), (
      previous,
      next,
    ) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(adminShiftViewModelProvider.notifier).loadData(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: shiftState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : shiftState.shifts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No shifts created yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddShiftDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create First Shift'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: shiftState.shifts.length,
              itemBuilder: (context, index) {
                final shift = shiftState.shifts[index];
                return ShiftCard(
                  shift: shift,
                  onAssignEmployee: () =>
                      _showAssignEmployeeDialog(context, shift),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddShiftDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Shift'),
      ),
    );
  }

  void _showAddShiftDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddShiftDialog(
        onAdd: ref.read(adminShiftViewModelProvider.notifier).addShift,
      ),
    );
  }

  void _showAssignEmployeeDialog(BuildContext context, Shift shift) {
    final employees = ref.read(adminShiftViewModelProvider).employees;

    showDialog(
      context: context,
      builder: (context) => AssignEmployeeDialog(
        shift: shift,
        employees: employees,
        onAssign: (userId) async {
          final success = await ref
              .read(adminShiftViewModelProvider.notifier)
              .assignEmployeeToShift(shift.id, userId);

          if (success && mounted) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Employee assigned successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
}
