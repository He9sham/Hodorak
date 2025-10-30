import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hodorak/features/analytics_screen/models/attendance_stats.dart';
import 'package:intl/intl.dart';

class WorkingHoursChart extends StatelessWidget {
  final List<AttendanceStats> weeklyStats;

  const WorkingHoursChart({super.key, required this.weeklyStats});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              weeklyStats.fold<double>(
                0,
                (max, stat) => stat.totalHours > max ? stat.totalHours : max,
              ) +
              2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= weeklyStats.length)
                    return const Text('');
                  final date = weeklyStats[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('EEE').format(date),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey[300], strokeWidth: 1);
            },
          ),
          barGroups: weeklyStats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: stat.totalHours,
                  color: Colors.blue,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
