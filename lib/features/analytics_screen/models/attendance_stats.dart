class AttendanceStats {
  final int present;
  final int late;
  final int absent;
  final DateTime date;
  final double totalHours;

  AttendanceStats({
    required this.present,
    required this.late,
    required this.absent,
    required this.date,
    required this.totalHours,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      present: json['present'] ?? 0,
      late: json['late'] ?? 0,
      absent: json['absent'] ?? 0,
      date: DateTime.parse(json['date']),
      totalHours: (json['total_hours'] ?? 0).toDouble(),
    );
  }
}

class WeeklyStats {
  final List<AttendanceStats> dailyStats;
  final double averageAttendance;
  final double totalHours;

  WeeklyStats({
    required this.dailyStats,
    required this.averageAttendance,
    required this.totalHours,
  });
}
