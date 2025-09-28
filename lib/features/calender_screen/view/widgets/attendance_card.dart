import 'package:flutter/material.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/features/calender_screen/utils/utils.dart';
import 'package:hodorak/features/calender_screen/view/widgets/employee_card.dart';
import 'package:hodorak/features/calender_screen/view/widgets/stat_column.dart';

class AttendanceCard extends StatelessWidget {
  final DailyAttendanceSummary summary;

  const AttendanceCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: summary.attendancePercentage >= 80
                ? Colors.green.shade100
                : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            summary.attendancePercentage >= 80
                ? Icons.check_circle
                : Icons.warning,
            color: summary.attendancePercentage >= 80
                ? Colors.green
                : Colors.orange,
          ),
        ),
        title: Text(
          summary.presentEmployees > 0 ? 'Present' : 'Absent',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          summary.presentEmployees > 0
              ? 'You checked in today'
              : 'You were absent today',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary stats for current user
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StatColumn(
                      label: 'Status',
                      value: summary.presentEmployees > 0
                          ? 'Present'
                          : 'Absent',
                      color: summary.presentEmployees > 0
                          ? Colors.green
                          : Colors.red,
                    ),
                    if (summary.employeeAttendances.isNotEmpty &&
                        summary.employeeAttendances.first.checkIn != null)
                      StatColumn(
                        label: 'Check In',
                        value: CalendarDateUtils.formatTime(
                          summary.employeeAttendances.first.checkIn,
                        ),
                        color: Colors.blue,
                      ),
                    if (summary.employeeAttendances.isNotEmpty &&
                        summary.employeeAttendances.first.checkOut != null)
                      StatColumn(
                        label: 'Check Out',
                        value: CalendarDateUtils.formatTime(
                          summary.employeeAttendances.first.checkOut,
                        ),
                        color: Colors.orange,
                      ),
                  ],
                ),
                verticalSpace(16),

                // User details
                if (summary.employeeAttendances.isNotEmpty) ...[
                  Text(
                    'Your Attendance Details:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  verticalSpace(8),
                  EmployeeCard(employee: summary.employeeAttendances.first),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
