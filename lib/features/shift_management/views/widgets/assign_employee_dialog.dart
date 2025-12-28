import 'package:flutter/material.dart';
import 'package:hodorak/core/models/shift.dart';
import 'package:hodorak/core/models/supabase_user.dart';

class AssignEmployeeDialog extends StatelessWidget {
  final Shift shift;
  final List<SupabaseUser> employees;
  final Function(String userId) onAssign;

  const AssignEmployeeDialog({
    super.key,
    required this.shift,
    required this.employees,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Employee to ${shift.name}'),
      content: SizedBox(
        width: double.maxFinite,
        child: employees.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No employees available'),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final employee = employees[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        (employee.name.isNotEmpty ? employee.name[0] : 'U')
                            .toUpperCase(),
                      ),
                    ),
                    title: Text(employee.name),
                    subtitle: Text(employee.email),
                    onTap: () {
                      Navigator.pop(context);
                      onAssign(employee.id);
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
