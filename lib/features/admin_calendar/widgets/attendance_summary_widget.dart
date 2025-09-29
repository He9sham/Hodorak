import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/utils/logger.dart';

class AttendanceSummaryWidget extends StatelessWidget {
  final DailyAttendanceSummary summary;
  final Function(EmployeeAttendance) onUserTap;

  const AttendanceSummaryWidget({
    super.key,
    required this.summary,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    // Debug: Print summary data
    Logger.debug(
      'AttendanceSummaryWidget: Building with ${summary.employeeAttendances.length} employees',
    );
    Logger.debug(
      'AttendanceSummaryWidget: Present: ${summary.presentEmployees}, Absent: ${summary.absentEmployees}',
    );

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date header
          Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: Colors.blue[600]),
              horizontalSpace(8),
              Text(
                _formatDate(summary.date),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          verticalSpace(12),

          // Summary stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Present',
                  summary.presentEmployees.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              horizontalSpace(8),
              Expanded(
                child: _buildStatCard(
                  'Absent',
                  summary.absentEmployees.toString(),
                  Colors.red,
                  Icons.cancel,
                ),
              ),
              horizontalSpace(8),
              Expanded(
                child: _buildStatCard(
                  'Total',
                  summary.totalEmployees.toString(),
                  Colors.blue,
                  Icons.people,
                ),
              ),
              horizontalSpace(8),
              Expanded(
                child: _buildStatCard(
                  'Rate',
                  '${summary.attendancePercentage.toStringAsFixed(1)}%',
                  Colors.orange,
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          verticalSpace(16),

          // Employee list
          Text(
            'Employee Details',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          verticalSpace(8),

          // Employee attendance list - No scrolling, just content
          summary.employeeAttendances.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No employee data available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : Column(
                  children: summary.employeeAttendances.map((employee) {
                    return _buildEmployeeCard(context, employee);
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, EmployeeAttendance employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: employee.isPresent ? Colors.green : Colors.red,
          child: Icon(
            employee.isPresent ? Icons.check : Icons.close,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          employee.employeeName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (employee.isPresent) ...[
              if (employee.checkIn != null)
                Text('Check In: ${_formatTime(employee.checkIn!)}'),
              if (employee.checkOut != null)
                Text('Check Out: ${_formatTime(employee.checkOut!)}'),
              if (employee.workingHours != null)
                Text('Hours: ${_formatDuration(employee.workingHours!)}'),
            ] else
              const Text('Absent', style: TextStyle(color: Colors.red)),
          ],
        ),
        trailing: employee.isPresent
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null,
        onTap: employee.isPresent ? () => onUserTap(employee) : null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
