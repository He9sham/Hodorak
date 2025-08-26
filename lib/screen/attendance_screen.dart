import 'package:flutter/material.dart';
import 'package:hodorak/odoo/odoo_service.dart';

class AttendancePage extends StatefulWidget {
  final OdooService odoo;
  const AttendancePage({super.key, required this.odoo});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Map<String, dynamic>> records = [];
  bool loading = true;
  final employeeIdCtrl = TextEditingController(); // هتدخل ID الموظف

  @override
  void initState() {
    super.initState();
    _load();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Attendance')),
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
