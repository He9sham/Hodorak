import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/shift.dart';
import 'package:hodorak/core/models/supabase_user.dart';
import 'package:hodorak/features/shift_management/view_models/admin_shift_view_model.dart';

class ShiftEmployeesDialog extends ConsumerStatefulWidget {
  final Shift shift;

  const ShiftEmployeesDialog({super.key, required this.shift});

  @override
  ConsumerState<ShiftEmployeesDialog> createState() =>
      _ShiftEmployeesDialogState();
}

class _ShiftEmployeesDialogState extends ConsumerState<ShiftEmployeesDialog> {
  late Future<List<SupabaseUser>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _employeesFuture = ref
        .read(adminShiftViewModelProvider.notifier)
        .getShiftEmployees(widget.shift.id);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Employees in ${widget.shift.name}'),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<SupabaseUser>>(
          future: _employeesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final employees = snapshot.data ?? [];

            if (employees.isEmpty) {
              return const Text('No employees assigned to this shift.');
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(employee.name[0].toUpperCase()),
                  ),
                  title: Text(employee.name),
                  subtitle: Text(employee.email),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
