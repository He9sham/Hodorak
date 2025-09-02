class DailyAttendanceSummary {
  final DateTime date;
  final List<EmployeeAttendance> employeeAttendances;
  final int totalEmployees;
  final int presentEmployees;
  final int absentEmployees;
  final double attendancePercentage;

  DailyAttendanceSummary({
    required this.date,
    required this.employeeAttendances,
    required this.totalEmployees,
    required this.presentEmployees,
    required this.absentEmployees,
    required this.attendancePercentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'employee_attendances': employeeAttendances
          .map((e) => e.toJson())
          .toList(),
      'total_employees': totalEmployees,
      'present_employees': presentEmployees,
      'absent_employees': absentEmployees,
      'attendance_percentage': attendancePercentage,
    };
  }

  factory DailyAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return DailyAttendanceSummary(
      date: DateTime.parse(json['date']),
      employeeAttendances: (json['employee_attendances'] as List)
          .map((e) => EmployeeAttendance.fromJson(e))
          .toList(),
      totalEmployees: json['total_employees'],
      presentEmployees: json['present_employees'],
      absentEmployees: json['absent_employees'],
      attendancePercentage: json['attendance_percentage'].toDouble(),
    );
  }
}

class EmployeeAttendance {
  final int employeeId;
  final String employeeName;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final bool isPresent;
  final Duration? workingHours;

  EmployeeAttendance({
    required this.employeeId,
    required this.employeeName,
    this.checkIn,
    this.checkOut,
    required this.isPresent,
    this.workingHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'check_in': checkIn?.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'is_present': isPresent,
      'working_hours': workingHours?.inMinutes,
    };
  }

  factory EmployeeAttendance.fromJson(Map<String, dynamic> json) {
    return EmployeeAttendance(
      employeeId: json['employee_id'],
      employeeName: json['employee_name'],
      checkIn: json['check_in'] != null
          ? DateTime.parse(json['check_in'])
          : null,
      checkOut: json['check_out'] != null
          ? DateTime.parse(json['check_out'])
          : null,
      isPresent: json['is_present'],
      workingHours: json['working_hours'] != null
          ? Duration(minutes: json['working_hours'])
          : null,
    );
  }
}
