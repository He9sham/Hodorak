import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/analytics_screen/providers/analytics_providers.dart';

class RecentAnalytics extends ConsumerWidget {
  const RecentAnalytics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyStatsAsync = ref.watch(dailyStatsProvider(DateTime.now()));

    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, Routes.analyticsScreen),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Attendance',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.analyticsScreen),
                    child: const Text('View Details'),
                  ),
                ],
              ),
              verticalSpace(16),
              dailyStatsAsync.when(
                data: (stats) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatIndicator(
                      'Present',
                      stats.present,
                      Colors.green,
                      Icons.check_circle,
                    ),
                    _buildStatIndicator(
                      'Late',
                      stats.late,
                      Colors.orange,
                      Icons.warning,
                    ),
                    _buildStatIndicator(
                      'Absent',
                      stats.absent,
                      Colors.red,
                      Icons.cancel,
                    ),
                  ],
                ),
                loading: () => SizedBox(
                  height: 100.h,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xff8C9F5F)),
                  ),
                ),
                error: (error, stack) {
                  debugPrint('Analytics Error: $error\n$stack');
                  String errorMessage = 'Unable to load attendance data';
                  if (error.toString().contains('Could not find the table')) {
                    errorMessage = 'Database setup required';
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            horizontalSpace(8),
                            Flexible(
                              child: Text(
                                errorMessage,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                        verticalSpace(8),
                        TextButton(
                          onPressed: () =>
                              ref.refresh(dailyStatsProvider(DateTime.now())),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatIndicator(
    String label,
    int value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
        verticalSpace(8),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
