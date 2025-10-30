import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/features/analytics_screen/providers/analytics_providers.dart';
import 'package:hodorak/features/analytics_screen/widgets/build_state_item.dart';
import 'package:hodorak/features/analytics_screen/widgets/working_hours_chart.dart';

class AnalyticsDashboard extends ConsumerWidget {
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);

    return RefreshIndicator(
      color: Color(0xff8C9F5F),
      onRefresh: () async {
        // Refresh both providers
        await Future.wait([
          ref.refresh(weeklyStatsProvider.future),
          ref.refresh(dailyStatsProvider(DateTime.now()).future),
        ]);
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Working Hours',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              weeklyStatsAsync.when(
                data: (weeklyStats) => Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        WorkingHoursChart(weeklyStats: weeklyStats.dailyStats),
                        Divider(height: 32.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            buildStatItem(
                              'Average Attendance',
                              '${weeklyStats.averageAttendance.toStringAsFixed(1)}%',
                              Icons.people,
                              Colors.blue,
                            ),
                            buildStatItem(
                              'Total Hours',
                              weeklyStats.totalHours.toStringAsFixed(1),
                              Icons.access_time,
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => Card(
                  elevation: 4,
                  child: SizedBox(
                    height: 300.h,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff8C9F5F),
                      ),
                    ),
                  ),
                ),
                error: (error, stack) {
                  debugPrint('Weekly stats error: $error\n$stack');
                  return Card(
                    elevation: 4,
                    child: Container(
                      height: 300.h,
                      padding: EdgeInsets.all(16.w),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48.sp,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Unable to load weekly data',
                              style: TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.h),
                            TextButton(
                              onPressed: () => ref.refresh(weeklyStatsProvider),
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      ),
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
}
