import 'package:hodorak/core/models/daily_attendance_summary.dart';

class MonthlyAttendanceSummary {
  final int year;
  final int month;
  final int totalDays;
  final int daysPresent;
  final int daysAbsent;
  final Duration totalWorkingHours;
  final double attendancePercentage;
  final List<DailyAttendanceSummary> dailySummaries;

  MonthlyAttendanceSummary({
    required this.year,
    required this.month,
    required this.totalDays,
    required this.daysPresent,
    required this.daysAbsent,
    required this.totalWorkingHours,
    required this.attendancePercentage,
    required this.dailySummaries,
  });

  factory MonthlyAttendanceSummary.fromDailySummaries(
    List<DailyAttendanceSummary> summaries,
    int year,
    int month,
  ) {
    if (summaries.isEmpty) {
      return MonthlyAttendanceSummary(
        year: year,
        month: month,
        totalDays: 0,
        daysPresent: 0,
        daysAbsent: 0,
        totalWorkingHours: Duration.zero,
        attendancePercentage: 0.0,
        dailySummaries: summaries,
      );
    }

    int totalDays = summaries.length;
    int daysPresent = 0;
    int daysAbsent = 0;
    Duration totalWorkingHours = Duration.zero;
    double totalPercentage = 0.0;

    for (final summary in summaries) {
      if (summary.presentEmployees > 0) {
        daysPresent++;
      } else {
        daysAbsent++;
      }

      // Calculate total working hours from employee attendances
      for (final attendance in summary.employeeAttendances) {
        if (attendance.workingHours != null) {
          totalWorkingHours += attendance.workingHours!;
        }
      }

      totalPercentage += summary.attendancePercentage;
    }

    return MonthlyAttendanceSummary(
      year: year,
      month: month,
      totalDays: totalDays,
      daysPresent: daysPresent,
      daysAbsent: daysAbsent,
      totalWorkingHours: totalWorkingHours,
      attendancePercentage: totalDays > 0 ? totalPercentage / totalDays : 0.0,
      dailySummaries: summaries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'total_days': totalDays,
      'days_present': daysPresent,
      'days_absent': daysAbsent,
      'total_working_hours': totalWorkingHours.inMinutes,
      'attendance_percentage': attendancePercentage,
      'daily_summaries': dailySummaries.map((s) => s.toJson()).toList(),
    };
  }

  factory MonthlyAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return MonthlyAttendanceSummary(
      year: json['year'],
      month: json['month'],
      totalDays: json['total_days'],
      daysPresent: json['days_present'],
      daysAbsent: json['days_absent'],
      totalWorkingHours: Duration(minutes: json['total_working_hours']),
      attendancePercentage: json['attendance_percentage'].toDouble(),
      dailySummaries: (json['daily_summaries'] as List)
          .map((s) => DailyAttendanceSummary.fromJson(s))
          .toList(),
    );
  }
}

