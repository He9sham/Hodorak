import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/odoo_service/odoo_http_service.dart';
import 'package:hodorak/core/services/calendar_service.dart';
import 'package:hodorak/core/utils/logger.dart';

class HttpAttendanceService {
  final OdooHttpService odooService;
  final CalendarService calendarService;

  HttpAttendanceService({
    required this.odooService,
    required this.calendarService,
  });

  /// Get all employees from Odoo
  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    return await odooService.getAllEmployees();
  }

  /// Get today's attendance records for all employees
  Future<List<Map<String, dynamic>>> getTodayAttendance() async {
    final today = DateTime.now();
    return getAttendanceForDate(today);
  }

  /// Get attendance records for a specific date
  Future<List<Map<String, dynamic>>> getAttendanceForDate(DateTime date) async {
    return await odooService.getAttendanceForDate(date);
  }

  /// Create daily attendance summary for today
  Future<DailyAttendanceSummary> createDailySummary() async {
    final today = DateTime.now();
    return createDailySummaryForDate(today);
  }

  /// Create daily attendance summary for current user on a specific date
  Future<DailyAttendanceSummary> createCurrentUserSummaryForDate(
    DateTime date,
  ) async {
    Logger.debug(
      'HttpAttendanceService: Creating current user summary for date: $date',
    );

    try {
      // Get current user's employee info
      final userProfile = await odooService.getUserProfile();
      if (userProfile == null) {
        throw Exception('Could not get current user profile');
      }

      Logger.info(
        'HttpAttendanceService: Current user: ${userProfile['name']} (ID: ${userProfile['id']})',
      );
      Logger.debug('HttpAttendanceService: User profile data: $userProfile');

      // Get current user's attendance for the date
      final attendance = await odooService.getCurrentUserAttendanceForDate(
        date,
      );
      Logger.debug(
        'HttpAttendanceService: Found ${attendance.length} attendance records for current user on $date',
      );

      // Create employee attendance record for current user
      final employeeAttendances = <EmployeeAttendance>[];
      int presentCount = 0;

      DateTime? checkIn;
      DateTime? checkOut;
      bool isPresent = false;
      Duration? workingHours;

      int employeeId = 0;
      String employeeName = 'Current User';

      if (attendance.isNotEmpty) {
        final record = attendance.first; // Get the first (most recent) record
        Logger.debug('HttpAttendanceService: Attendance record: $record');

        // Get employee ID from the attendance record
        employeeId = record['employee_id'] is List
            ? record['employee_id'][0]
            : record['employee_id'] ?? 0;
        Logger.debug(
          'HttpAttendanceService: Extracted employee ID: $employeeId',
        );

        checkIn = _parseDateTime(record['check_in']);
        checkOut = _parseDateTime(record['check_out']);
        isPresent = checkIn != null;

        if (checkIn != null && checkOut != null) {
          workingHours = checkOut.difference(checkIn);
        } else if (checkIn != null) {
          // Still at work, calculate hours until now
          workingHours = DateTime.now().difference(checkIn);
        }
      } else {
        // If no attendance record, try to get employee ID from user profile
        employeeId = userProfile['id'] ?? 0;
      }

      // Get employee name from user profile if available
      if (userProfile['name'] != null) {
        employeeName = userProfile['name'] as String;
      }

      if (isPresent) presentCount++;

      employeeAttendances.add(
        EmployeeAttendance(
          employeeId: employeeId,
          employeeName: employeeName,
          checkIn: checkIn,
          checkOut: checkOut,
          isPresent: isPresent,
          workingHours: workingHours,
        ),
      );

      final totalEmployees = 1; // Only current user
      final absentCount = totalEmployees - presentCount;
      final attendancePercentage = isPresent ? 100.0 : 0.0;

      final summary = DailyAttendanceSummary(
        date: date,
        employeeAttendances: employeeAttendances,
        totalEmployees: totalEmployees,
        presentEmployees: presentCount,
        absentEmployees: absentCount,
        attendancePercentage: attendancePercentage,
      );

      Logger.info(
        'HttpAttendanceService: Created current user summary - ${isPresent ? "Present" : "Absent"} on $date',
      );
      return summary;
    } catch (e) {
      Logger.error(
        'HttpAttendanceService: Error creating current user summary for $date: $e',
      );
      rethrow;
    }
  }

  /// Create daily attendance summary for a specific date
  Future<DailyAttendanceSummary> createDailySummaryForDate(
    DateTime date,
  ) async {
    Logger.debug('HttpAttendanceService: Creating summary for date: $date');

    try {
      final employees = await getAllEmployees();
      Logger.info('HttpAttendanceService: Found ${employees.length} employees');

      final attendance = await getAttendanceForDate(date);
      Logger.info(
        'HttpAttendanceService: Found ${attendance.length} attendance records for $date',
      );

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

      final summary = DailyAttendanceSummary(
        date: date,
        employeeAttendances: employeeAttendances,
        totalEmployees: totalEmployees,
        presentEmployees: presentCount,
        absentEmployees: absentCount,
        attendancePercentage: attendancePercentage,
      );

      Logger.info(
        'HttpAttendanceService: Created summary - $presentCount/$totalEmployees present (${attendancePercentage.toStringAsFixed(1)}%)',
      );
      return summary;
    } catch (e) {
      Logger.error(
        'HttpAttendanceService: Error creating summary for $date: $e',
      );
      rethrow;
    }
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
