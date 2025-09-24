import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/odoo_service/odoo_service.dart';
import 'package:hodorak/core/providers/ai_attendance_provider.dart';
import 'dart:convert';

class AIAttendanceScreen extends ConsumerStatefulWidget {
  final OdooService odoo;
  const AIAttendanceScreen({super.key, required this.odoo});

  @override
  ConsumerState<AIAttendanceScreen> createState() => _AIAttendanceScreenState();
}

class _AIAttendanceScreenState extends ConsumerState<AIAttendanceScreen> {
  final employeeIdCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  bool includeLocation = true;

  @override
  void dispose() {
    employeeIdCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkIn() async {
    final id = int.tryParse(employeeIdCtrl.text);
    if (id == null) {
      _toast('Please enter a valid Employee ID');
      return;
    }

    final location = locationCtrl.text.trim().isEmpty ? null : locationCtrl.text.trim();
    
    try {
      final response = await ref.read(aiAttendanceProvider(widget.odoo).notifier).checkIn(
        employeeId: id,
        location: location,
        includeLocation: includeLocation,
      );

      _showResponseDialog('Check In Response', response);
      _toast('Check In completed successfully');
    } catch (e) {
      _toast('Check In failed: $e');
    }
  }

  Future<void> _checkOut() async {
    final id = int.tryParse(employeeIdCtrl.text);
    if (id == null) {
      _toast('Please enter a valid Employee ID');
      return;
    }

    final location = locationCtrl.text.trim().isEmpty ? null : locationCtrl.text.trim();
    
    try {
      final response = await ref.read(aiAttendanceProvider(widget.odoo).notifier).checkOut(
        employeeId: id,
        location: location,
        includeLocation: includeLocation,
      );

      _showResponseDialog('Check Out Response', response);
      _toast('Check Out completed successfully');
    } catch (e) {
      _toast('Check Out failed: $e');
    }
  }

  void _showResponseDialog(String title, Map<String, dynamic> response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Status: ${response['status']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: response['status'] == 'success' ? Colors.green : Colors.red,
                ),
              ),
              verticalSpace(8),
              Text('Message: ${response['message']}'),
              verticalSpace(8),
              Text('Odoo Record:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('  User ID: ${response['odoo']['userId']}'),
              Text('  Action: ${response['odoo']['action']}'),
              Text('  Timestamp: ${response['odoo']['timestamp']}'),
              if (response['odoo']['location'] != null)
                Text('  Location: ${response['odoo']['location']}'),
              verticalSpace(8),
              Text('Calendar Event:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('  Event ID: ${response['calendar']['eventId']}'),
              Text('  Title: ${response['calendar']['title']}'),
              Text('  Start: ${response['calendar']['start']}'),
              if (response['calendar']['end'] != null)
                Text('  End: ${response['calendar']['end']}'),
              if (response['calendar']['notes'] != null)
                Text('  Notes: ${response['calendar']['notes']}'),
              verticalSpace(16),
              Text('Raw JSON Response:', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  const JsonEncoder.withIndent('  ').convert(response),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showUserHistory() async {
    final id = int.tryParse(employeeIdCtrl.text);
    if (id == null) {
      _toast('Please enter a valid Employee ID');
      return;
    }

    try {
      final history = await ref.read(aiAttendanceProvider(widget.odoo).notifier)
          .getUserAttendanceHistory(id);
      
      _showHistoryDialog('Attendance History for User $id', history);
    } catch (e) {
      _toast('Failed to load history: $e');
    }
  }

  void _showHistoryDialog(String title, List<Map<String, dynamic>> history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: history.isEmpty
              ? const Center(child: Text('No attendance history found'))
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final event = history[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(event['title'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start: ${event['start'] ?? ''}'),
                            if (event['end'] != null)
                              Text('End: ${event['end']}'),
                            if (event['notes'] != null)
                              Text('Notes: ${event['notes']}'),
                          ],
                        ),
                        trailing: Text(event['eventId'] ?? ''),
                      ),
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
      ),
    );
  }

  Future<void> _showDailySummary() async {
    try {
      final summary = await ref.read(aiAttendanceProvider(widget.odoo).notifier)
          .getDailyAttendanceSummary(DateTime.now());
      
      _showSummaryDialog('Daily Attendance Summary', summary);
    } catch (e) {
      _toast('Failed to load daily summary: $e');
    }
  }

  void _showSummaryDialog(String title, Map<String, dynamic> summary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${summary['date'] ?? ''}'),
            Text('Total Users: ${summary['totalUsers'] ?? 0}'),
            Text('Present Users: ${summary['presentUsers'] ?? 0}'),
            Text('Complete Users: ${summary['completeUsers'] ?? 0}'),
            Text('Attendance Rate: ${summary['attendanceRate']?.toStringAsFixed(1) ?? '0.0'}%'),
            Text('Completion Rate: ${summary['completionRate']?.toStringAsFixed(1) ?? '0.0'}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(aiAttendanceProvider(widget.odoo));

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI Attendance Assistant'),
          actions: [
            IconButton(
              onPressed: _showDailySummary,
              icon: const Icon(Icons.analytics),
              tooltip: 'Daily Summary',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Employee ID input
              TextField(
                controller: employeeIdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Employee ID',
                  hintText: 'Enter employee ID (e.g., 1)',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              verticalSpace(12),

              // Location input
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  hintText: 'Enter location (e.g., 37.7749, -122.4194)',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              verticalSpace(8),

              // Include location checkbox
              CheckboxListTile(
                title: const Text('Include automatic location detection'),
                value: includeLocation,
                onChanged: (value) {
                  setState(() {
                    includeLocation = value ?? true;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              verticalSpace(12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _checkIn,
                      icon: const Icon(Icons.login),
                      label: const Text('Check In'),
                    ),
                  ),
                  horizontalSpace(8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _checkOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Check Out'),
                    ),
                  ),
                ],
              ),
              verticalSpace(8),

              // History button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showUserHistory,
                  icon: const Icon(Icons.history),
                  label: const Text('View User History'),
                ),
              ),
              verticalSpace(12),

              // Error display
              if (attendanceState.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    attendanceState.error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),

              // Loading indicator
              if (attendanceState.loading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),

              // Today's attendance records
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Attendance Events',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    verticalSpace(8),
                    Expanded(
                      child: attendanceState.records.isEmpty
                          ? const Center(
                              child: Text('No attendance events for today'),
                            )
                          : ListView.builder(
                              itemCount: attendanceState.records.length,
                              itemBuilder: (context, index) {
                                final event = attendanceState.records[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(event['title'] ?? ''),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Start: ${event['start'] ?? ''}'),
                                        if (event['end'] != null)
                                          Text('End: ${event['end']}'),
                                        if (event['notes'] != null)
                                          Text('Notes: ${event['notes']}'),
                                      ],
                                    ),
                                    trailing: Text(
                                      event['eventId'] ?? '',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}