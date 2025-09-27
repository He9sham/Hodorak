import 'package:hodorak/constance.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/odoo_service/odoo_service.dart';
import 'package:hodorak/core/services/calendar_service.dart';

class DailyAttendanceService {
  final OdooService odooService;
  final CalendarService calendarService;

  DailyAttendanceService({
    required this.odooService,
    required this.calendarService,
  });

  /// Get all employees from Odoo
  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    try {
      final result = await odooService.client.callKw({
        'model': 'hr.employee',
        'method': 'search_read',
        'args': [[]],
        'kwargs': {
          'fields': ['id', 'name', 'work_email'],
          'order': 'name',
        },
      });
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      throw Exception('Failed to fetch employees: $e');
    }
  }

  /// Get today's attendance records for all employees
  Future<List<Map<String, dynamic>>> getTodayAttendance() async {
    final today = DateTime.now();
    return getAttendanceForDate(today);
  }

  /// Get attendance records for a specific date
  Future<List<Map<String, dynamic>>> getAttendanceForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final result = await odooService.client.callKw({
        'model': Constance.model,
        'method': Constance.methodSearchRead,
        'args': [
          [
            ['check_in', '>=', _formatDateTime(startOfDay)],
            ['check_in', '<', _formatDateTime(endOfDay)],
          ],
        ],
        'kwargs': {
          'fields': ['employee_id', 'check_in', 'check_out'],
          'order': 'check_in desc',
        },
      });
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      throw Exception('Failed to fetch attendance for date: $e');
    }
  }

  /// Create daily attendance summary for today
  Future<DailyAttendanceSummary> createDailySummary() async {
    final today = DateTime.now();
    return createDailySummaryForDate(today);
  }

  /// Create daily attendance summary for a specific date
  Future<DailyAttendanceSummary> createDailySummaryForDate(
    DateTime date,
  ) async {
    final employees = await getAllEmployees();
    final attendance = await getAttendanceForDate(date);

    // Create a map of employee attendance for quick lookup
    final attendanceMap = <int, Map<String, dynamic>>{};
    for (final record in attendance) {
      final empId = record['employee_id'] is List
          ? record['employee_id'][0]
          : record['employee_id'];
      attendanceMap[empId] = record;
    }

    // Create employee attendance records
    final employeeAttendances = <EmployeeAttendance>[];
    int presentCount = 0;

    for (final employee in employees) {
      final empId = employee['id'];
      final empName = employee['name'] ?? 'Unknown';
      final attendance = attendanceMap[empId];

      DateTime? checkIn;
      DateTime? checkOut;
      bool isPresent = false;
      Duration? workingHours;

      if (attendance != null) {
        checkIn = _parseDateTime(attendance['check_in']);
        checkOut = _parseDateTime(attendance['check_out']);
        isPresent = checkIn != null;

        if (checkIn != null && checkOut != null) {
          workingHours = checkOut.difference(checkIn);
        } else if (checkIn != null) {
          // Still at work, calculate hours until now
          workingHours = DateTime.now().difference(checkIn);
        }
      }

      if (isPresent) presentCount++;

      employeeAttendances.add(
        EmployeeAttendance(
          employeeId: empId,
          employeeName: empName,
          checkIn: checkIn,
          checkOut: checkOut,
          isPresent: isPresent,
          workingHours: workingHours,
        ),
      );
    }

    final totalEmployees = employees.length;
    final absentCount = totalEmployees - presentCount;
    final attendancePercentage = totalEmployees > 0
        ? (presentCount / totalEmployees) * 100
        : 0.0;

    return DailyAttendanceSummary(
      date: date,
      employeeAttendances: employeeAttendances,
      totalEmployees: totalEmployees,
      presentEmployees: presentCount,
      absentEmployees: absentCount,
      attendancePercentage: attendancePercentage,
    );
  }

  /// End the day: save summary to calendar and reset for new day
  Future<bool> endDay() async {
    try {
      // Create daily summary
      final summary = await createDailySummary();

      // Save to calendar
      await calendarService.saveDailySummary(summary);

      // Mark day as completed
      await _markDayAsCompleted();

      return true;
    } catch (e) {
      throw Exception('Failed to end day: $e');
    }
  }

  /// Check if today has already been completed
  Future<bool> isDayCompleted() async {
    return false; // Always allow new day in fallback mode
  }

  /// Mark today as completed
  Future<void> _markDayAsCompleted() async {
    return; // Skip in fallback mode
  }

  /// Reset for new day (clear completed flag)
  Future<void> resetForNewDay() async {
    return; // Skip in fallback mode
  }

  /// Check if it's a new day and reset if needed
  Future<void> checkAndResetForNewDay() async {
    return; // Skip in fallback mode
  }

  /// Check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Format DateTime for Odoo
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// Parse DateTime from Odoo
  DateTime? _parseDateTime(dynamic dateTimeStr) {
    if (dateTimeStr == null) return null;
    try {
      return DateTime.parse(dateTimeStr.toString());
    } catch (e) {
      return null;
    }
  }
}
