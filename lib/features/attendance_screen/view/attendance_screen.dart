import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/odoo_service/odoo_service.dart';
import 'package:hodorak/core/providers/attendance_provider.dart';

class AttendancePage extends ConsumerStatefulWidget {
  final OdooService odoo;
  const AttendancePage({super.key, required this.odoo});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  final employeeIdCtrl = TextEditingController();

  @override
  void dispose() {
    employeeIdCtrl.dispose();
    super.dispose();
  }

  Future<void> load() async {
    await ref.read(attendanceProvider(widget.odoo).notifier).loadAttendance();
  }

  Future<void> _checkIn() async {
    final id = int.tryParse(employeeIdCtrl.text);
    if (id == null) {
      _toast('ادخل Employee ID صحيح');
      return;
    }
    try {
      await ref
          .read(attendanceProvider(widget.odoo).notifier)
          .checkIn(id);
      _toast('تم تسجيل الحضور');
    } catch (e) {
      _toast('Check-in failed: $e');
    }
  }

  Future<void> _checkOut() async {
    final id = int.tryParse(employeeIdCtrl.text);
    if (id == null) {
      _toast('ادخل Employee ID صحيح');
      return;
    }
    try {
      await ref
          .read(attendanceProvider(widget.odoo).notifier)
          .checkOut(id, context);
      _toast('تم تسجيل الانصراف');
    } catch (e) {
      _toast('Check-out failed: $e');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _endDay() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Day'),
        content: const Text(
          'Are you sure you want to end the day? This will:\n'
          '• Save all attendance data to calendar\n'
          '• Generate daily summary\n'
          '• Prepare for a new day\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('End Day'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Ending day...'),
          ],
        ),
      ),
    );

    try {
      final summary = await ref
          .read(attendanceProvider(widget.odoo).notifier)
          .endDay();

      // Close loading dialog
      Navigator.of(context).pop();

      if (summary != null) {
        // show success dialog wih summary

        await _showEndDaySummary(summary);

        _toast('Day ended successfully! Attendance records cleared');
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      _toast('Failed to end day: $e');
    }
  }

  Future<void> _showEndDaySummary(DailyAttendanceSummary summary) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${_formatDate(summary.date)}'),
            const SizedBox(height: 8),
            Text('Total Employees: ${summary.totalEmployees}'),
            Text('Present: ${summary.presentEmployees}'),
            Text('Absent: ${summary.absentEmployees}'),
            Text(
              'Attendance Rate: ${summary.attendancePercentage.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 16),
            const Text('Summary saved to calendar successfully!'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceProvider(widget.odoo));

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Attendance'),
          actions: [
            if (attendanceState.dayCompleted)
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Day Completed',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // enter emp id && check in or out
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: employeeIdCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Employee ID',
                        hintText: 'مثال: 1',
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _checkIn,
                    icon: const Icon(Icons.login),
                    label: const Text('Check In'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _checkOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Check Out'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // End Day Button
              if (!attendanceState.dayCompleted)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: FilledButton.icon(
                    onPressed: _endDay,
                    icon: const Icon(Icons.event_available),
                    label: const Text('End Day & Save to Calendar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

              // Day completed message
              if (attendanceState.dayCompleted)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day Completed',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            Text(
                              'Attendance data has been saved to calendar. Ready for a new day!',
                              style: TextStyle(color: Colors.green.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // show all emp
              Expanded(
                child: attendanceState.loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: attendanceState.records.length,
                        itemBuilder: (context, i) {
                          final r = attendanceState.records[i];
                          final emp = r['employee_id'];
                          final empText = (emp is List && emp.length >= 2)
                              ? '${emp[0]} • ${emp[1]}'
                              : emp.toString();
                          return Card(
                            child: ListTile(
                              title: Text(empText),
                              subtitle: Text(
                                'In : ${r['check_in'] ?? '-'}\n'
                                'Out: ${r['check_out'] ?? '-'}',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
