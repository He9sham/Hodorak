import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/features/attendance/providers/attendance_providers.dart';
import 'package:hodorak/features/attendance/widgets/build_status_card.dart';

class AttendanceSettingsScreen extends ConsumerWidget {
  const AttendanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceTimeAsync = ref.watch(attendanceSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: attendanceTimeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error: ${error.toString()}')),
        data: (attendanceTime) => Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set Attendance Time Threshold',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              verticalSpace(8),
              Text(
                'Employees arriving after this time will be marked as late',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              verticalSpace(24),
              InkWell(
                onTap: () async {
                  final TimeOfDay? newTime = await showTimePicker(
                    context: context,
                    initialTime: attendanceTime,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          timePickerTheme: TimePickerThemeData(
                            backgroundColor: Colors.white,
                            hourMinuteShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (newTime != null) {
                    ref
                        .read(attendanceSettingsProvider.notifier)
                        .updateTime(newTime);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Threshold',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          verticalSpace(4),
                          Text(
                            '${attendanceTime.hour.toString().padLeft(2, '0')}:${attendanceTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.access_time, size: 32.sp, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              verticalSpace(24),
              Text(
                'Status Rules:',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              verticalSpace(16),
              buildStatusCard(
                icon: Icons.check_circle,
                color: Colors.green,
                status: 'Present',
                description:
                    'Check-in before ${attendanceTime.hour.toString().padLeft(2, '0')}:${attendanceTime.minute.toString().padLeft(2, '0')}',
              ),
              verticalSpace(12),
              buildStatusCard(
                icon: Icons.warning,
                color: Colors.orange,
                status: 'Late',
                description:
                    'Check-in after ${attendanceTime.hour.toString().padLeft(2, '0')}:${attendanceTime.minute.toString().padLeft(2, '0')}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
