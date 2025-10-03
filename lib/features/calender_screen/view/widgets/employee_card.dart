import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/features/calender_screen/utils/utils.dart';

class EmployeeCard extends StatelessWidget {
  final EmployeeAttendance employee;

  const EmployeeCard({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              employee.isPresent ? Icons.check_circle : Icons.cancel,
              size: 20.sp,
              color: employee.isPresent ? Colors.green : Colors.red,
            ),
            horizontalSpace(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (employee.isPresent) ...[
                    verticalSpace(4),
                    Row(
                      children: [
                        Icon(Icons.login, size: 16.sp, color: Colors.grey[600]),
                        horizontalSpace(4),
                        Text(
                          'Check In: ${CalendarDateUtils.formatTime(employee.checkIn)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    if (employee.checkOut != null) ...[
                      verticalSpace(2),
                      Row(
                        children: [
                          Icon(
                            Icons.logout,
                            size: 16.sp,
                            color: Colors.grey[600],
                          ),
                          horizontalSpace(4),
                          Text(
                            'Check Out: ${CalendarDateUtils.formatTime(employee.checkOut)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      verticalSpace(2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16.sp,
                            color: Colors.grey[600],
                          ),
                          horizontalSpace(4),
                          Text(
                            'Hours: ${CalendarDateUtils.formatDuration(employee.workingHours)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      verticalSpace(2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16.sp,
                            color: Colors.grey[600],
                          ),
                          horizontalSpace(4),
                          Text(
                            'Hours: ${CalendarDateUtils.formatDuration(employee.workingHours)} (Still working)',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ] else ...[
                    verticalSpace(4),
                    Text(
                      'Absent',
                      style: TextStyle(color: Colors.red[600], fontSize: 12.sp),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
