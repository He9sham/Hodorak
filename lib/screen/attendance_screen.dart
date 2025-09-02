import 'package:flutter/material.dart';
import 'package:hodorak/models/daily_attendance_summary.dart';
import 'package:hodorak/odoo/odoo_service.dart';
import 'package:hodorak/services/calendar_service.dart';
import 'package:hodorak/services/daily_attendance_service.dart';

class AttendancePage extends StatefulWidget {
  final OdooService odoo;
  const AttendancePage({super.key, required this.odoo});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Map<String, dynamic>> records = [];
  bool loading = true;
  bool dayCompleted = false;
  final employeeIdCtrl = TextEditingController();
  late DailyAttendanceService dailyService;
  late CalendarService calendarService;

  @override
  void initState() {
    super.initState();
    calendarService = CalendarService();
    dailyService = DailyAttendanceService(
      odooService: widget.odoo,
      calendarService: calendarService,
    );
    _load();
    _initializeDayStatus();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final data = await widget.odoo.fetchAttendance(limit: 20);
      setState(() => records = data);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fetch error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _checkIn() async {
    final id = int.tryParse(employeeIdCtrl.text);
    if (id == null) {
      _toast('ادخل Employee ID صحيح');
      return;
    }
    try {
      final attId = await widget.odoo.checkIn(id);
      _toast('تم تسجيل الحضور. attendance_id=$attId');
      _load();
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
      final ok = await widget.odoo.checkOut(id);
      _toast(ok ? 'تم تسجيل الانصراف' : 'لا يوجد حضور مفتوح لهذا الموظف');
      _load();
    } catch (e) {
      _toast('Check-out failed: $e');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _initializeDayStatus() async {
    try {
      // Check and reset for new day if needed
      await dailyService.checkAndResetForNewDay();

      // Check if today is completed
      final completed = await dailyService.isDayCompleted();
      setState(() => dayCompleted = completed);
    } catch (e) {
      _toast('Error initializing day status: $e');
    }
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
      await dailyService.endDay();

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success dialog with summary
      final summary = await dailyService.createDailySummary();
      await _showEndDaySummary(summary);

      // Clear attendance records from screen
      setState(() {
        dayCompleted = true;
        records.clear(); // Remove all attendance records
      });

      _toast('Day ended successfully! Attendance records cleared.');
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Attendance'),
          actions: [
            if (dayCompleted)
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
              if (!dayCompleted)
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
              if (dayCompleted)
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

              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (context, i) {
                          final r = records[i];
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
