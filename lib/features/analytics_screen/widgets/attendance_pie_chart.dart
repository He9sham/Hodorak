import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hodorak/features/analytics_screen/models/attendance_stats.dart';

class AttendancePieChart extends StatelessWidget {
  final AttendanceStats stats;

  const AttendancePieChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    // Check if all values are 0
    final bool noData =
        stats.present == 0 && stats.late == 0 && stats.absent == 0;

    return AspectRatio(
      aspectRatio: 1.3,
      child: noData
          ? Center(
              child: Text(
                'No attendance data for today',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            )
          : PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: stats.present.toDouble(),
                    title: 'Present\n${stats.present}',
                    color: Colors.green,
                    radius: 60,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: stats.late.toDouble(),
                    title: 'Late\n${stats.late}',
                    color: Colors.orange,
                    radius: 60,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: stats.absent.toDouble(),
                    title: 'Absent\n${stats.absent}',
                    color: Colors.red,
                    radius: 60,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                startDegreeOffset: -90,
              ),
            ),
    );
  }

  bool get hasData => stats.present > 0 || stats.late > 0 || stats.absent > 0;
}
