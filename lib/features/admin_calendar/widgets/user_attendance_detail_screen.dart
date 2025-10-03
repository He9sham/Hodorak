import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';

class UserAttendanceDetailScreen extends StatelessWidget {
  final EmployeeAttendance employeeAttendance;
  final DateTime date;

  const UserAttendanceDetailScreen({
    super.key,
    required this.employeeAttendance,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(employeeAttendance.employeeName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: employeeAttendance.isPresent
                                ? Colors.green
                                : Colors.red,
                            child: Icon(
                              employeeAttendance.isPresent
                                  ? Icons.check
                                  : Icons.close,
                              color: Colors.white,
                              size: 30.sp,
                            ),
                          ),
                          horizontalSpace(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employeeAttendance.employeeName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                verticalSpace(4),
                                Text(
                                  'Employee ID: ${employeeAttendance.employeeId}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                verticalSpace(8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: employeeAttendance.isPresent
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    employeeAttendance.isPresent
                                        ? 'Present'
                                        : 'Absent',
                                    style: TextStyle(
                                      color: employeeAttendance.isPresent
                                          ? Colors.green[800]
                                          : Colors.red[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              verticalSpace(24),

              // Date information
              Text(
                'Date Information',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              verticalSpace(12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blue[600]),
                      horizontalSpace(12),
                      Text(
                        _formatDate(date),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              verticalSpace(24),

              // Attendance details
              Text(
                'Attendance Details',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              verticalSpace(12),

              if (employeeAttendance.isPresent) ...[
                // Check In
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Icon(Icons.login, color: Colors.green[600]),
                    ),
                    title: const Text('Check In Time'),
                    subtitle: employeeAttendance.checkIn != null
                        ? Text(
                            _formatDateTime(employeeAttendance.checkIn!),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          )
                        : const Text('Not recorded'),
                  ),
                ),
                verticalSpace(8),

                // Check Out
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red[100],
                      child: Icon(Icons.logout, color: Colors.red[600]),
                    ),
                    title: const Text('Check Out Time'),
                    subtitle: employeeAttendance.checkOut != null
                        ? Text(
                            _formatDateTime(employeeAttendance.checkOut!),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          )
                        : const Text('Still at work'),
                  ),
                ),
                verticalSpace(8),

                // Working Hours
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Icon(Icons.access_time, color: Colors.blue[600]),
                    ),
                    title: const Text('Total Working Hours'),
                    subtitle: employeeAttendance.workingHours != null
                        ? Text(
                            _formatDuration(employeeAttendance.workingHours!),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          )
                        : const Text('Calculating...'),
                  ),
                ),
              ] else ...[
                // Absent information
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_off,
                          size: 64.sp,
                          color: Colors.red[300],
                        ),
                        verticalSpace(16),
                        Text(
                          'Employee was absent on this day',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.red[600]),
                          textAlign: TextAlign.center,
                        ),
                        verticalSpace(8),
                        Text(
                          'No check-in or check-out records found',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              verticalSpace(24),

              // Additional information
              Text(
                'Additional Information',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              verticalSpace(12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Status',
                        employeeAttendance.isPresent ? 'Present' : 'Absent',
                      ),
                      Divider(),
                      _buildInfoRow(
                        'Employee ID',
                        employeeAttendance.employeeId.toString(),
                      ),
                      Divider(),
                      _buildInfoRow('Date', _formatDate(date)),
                      if (employeeAttendance.checkIn != null) ...[
                        Divider(),
                        _buildInfoRow(
                          'Check In',
                          _formatDateTime(employeeAttendance.checkIn!),
                        ),
                      ],
                      if (employeeAttendance.checkOut != null) ...[
                        const Divider(),
                        _buildInfoRow(
                          'Check Out',
                          _formatDateTime(employeeAttendance.checkOut!),
                        ),
                      ],
                      if (employeeAttendance.workingHours != null) ...[
                        const Divider(),
                        _buildInfoRow(
                          'Working Hours',
                          _formatDuration(employeeAttendance.workingHours!),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
