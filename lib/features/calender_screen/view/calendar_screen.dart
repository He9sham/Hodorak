import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/providers/calendar_provider.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _selectMonth(
    BuildContext context,
    WidgetRef ref,
    DateTime currentMonth,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Month',
    );

    if (picked != null) {
      await ref.read(calendarProvider.notifier).selectMonth(picked);
    }
  }

  Future<void> _exportData(
    BuildContext context,
    List<DailyAttendanceSummary> summaries,
  ) async {
    try {
      // Create CSV content
      String csvContent =
          'Date,Total Employees,Present,Absent,Attendance Rate\n';

      for (final summary in summaries) {
        csvContent +=
            '${_formatDate(summary.date)},'
            '${summary.totalEmployees},'
            '${summary.presentEmployees},'
            '${summary.absentEmployees},'
            '${summary.attendancePercentage.toStringAsFixed(1)}%\n';
      }

      // Show export dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CSV data generated:'),
              const SizedBox(height: 8),
              Container(
                height: 200,
                width: double.maxFinite,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    csvContent,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
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
    } catch (e) {
      _showError(context, 'Export failed: $e');
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);

    // Show error if present
    if (calendarState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showError(context, calendarState.errorMessage!);
        ref.read(calendarProvider.notifier).clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Calendar'),
        actions: [
          IconButton(
            onPressed: () => _exportData(context, calendarState.summaries),
            icon: const Icon(Icons.download),
            tooltip: 'Export Data',
          ),
          IconButton(
            onPressed: () =>
                _selectMonth(context, ref, calendarState.selectedMonth),
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Select Month',
          ),
        ],
      ),
      body: Column(
        children: [
          // Month selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getMonthName(calendarState.selectedMonth.month)} ${calendarState.selectedMonth.year}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                FilledButton.icon(
                  onPressed: () =>
                      _selectMonth(context, ref, calendarState.selectedMonth),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Change Month'),
                ),
              ],
            ),
          ),

          // Calendar content
          Expanded(
            child: calendarState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : calendarState.summaries.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No attendance data found for this month',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: calendarState.summaries.length,
                    itemBuilder: (context, index) {
                      final summary = calendarState.summaries[index];
                      return _buildSummaryCard(context, summary);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    DailyAttendanceSummary summary,
  ) {
    final attendanceRate = summary.attendancePercentage;
    final isGoodAttendance = attendanceRate >= 80;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isGoodAttendance
                ? Colors.green.shade100
                : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            isGoodAttendance ? Icons.check_circle : Icons.warning,
            color: isGoodAttendance ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          _formatDate(summary.date),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${summary.presentEmployees}/${summary.totalEmployees} present (${attendanceRate.toStringAsFixed(1)}%)',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      'Total',
                      summary.totalEmployees.toString(),
                      Colors.blue,
                    ),
                    _buildStatColumn(
                      'Present',
                      summary.presentEmployees.toString(),
                      Colors.green,
                    ),
                    _buildStatColumn(
                      'Absent',
                      summary.absentEmployees.toString(),
                      Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Employee details
                if (summary.employeeAttendances.isNotEmpty) ...[
                  Text(
                    'Employee Details:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...summary.employeeAttendances
                      .take(5)
                      .map(
                        (emp) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                emp.isPresent
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 16,
                                color: emp.isPresent
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(emp.employeeName)),
                              if (emp.checkIn != null)
                                Text(
                                  '${emp.checkIn!.hour.toString().padLeft(2, '0')}:${emp.checkIn!.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      ),
                  if (summary.employeeAttendances.length > 5)
                    Text(
                      '... and ${summary.employeeAttendances.length - 5} more employees',
                      style: const TextStyle(color: Colors.grey),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
