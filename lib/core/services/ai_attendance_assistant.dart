import 'package:hodorak/core/models/attendance_response.dart';
import 'package:hodorak/core/services/enhanced_attendance_service.dart';
import 'package:hodorak/core/services/calendar_event_service.dart';
import 'package:hodorak/core/odoo_service/odoo_service.dart';

class AIAttendanceAssistant {
  final EnhancedAttendanceService _attendanceService;
  final CalendarEventService _calendarEventService;

  AIAttendanceAssistant({required OdooService odooService})
      : _attendanceService = EnhancedAttendanceService(odooService: odooService),
        _calendarEventService = CalendarEventService();

  /// Main method to handle Check In operations
  /// Returns JSON response as specified in requirements
  Future<Map<String, dynamic>> checkIn({
    required int userId,
    String? location,
    bool includeLocation = true,
  }) async {
    try {
      // Perform Check In with location
      final response = await _attendanceService.checkInWithLocation(
        employeeId: userId,
        includeLocation: includeLocation,
      );

      // If location was requested but not provided, use the one from response
      final finalLocation = location ?? 
          (includeLocation ? await _attendanceService.getCurrentLocation() : null);

      // Create calendar event
      await _calendarEventService.saveAttendanceEvent(response.calendar);

      // Return the JSON response
      return response.toJson();
    } catch (e) {
      return AttendanceResponse.error('Check In operation failed: $e').toJson();
    }
  }

  /// Main method to handle Check Out operations
  /// Returns JSON response as specified in requirements
  Future<Map<String, dynamic>> checkOut({
    required int userId,
    String? location,
    bool includeLocation = true,
  }) async {
    try {
      // Perform Check Out with location
      final response = await _attendanceService.checkOutWithLocation(
        employeeId: userId,
        includeLocation: includeLocation,
      );

      // If location was requested but not provided, use the one from response
      final finalLocation = location ?? 
          (includeLocation ? await _attendanceService.getCurrentLocation() : null);

      // Create calendar event
      await _calendarEventService.saveAttendanceEvent(response.calendar);

      // Return the JSON response
      return response.toJson();
    } catch (e) {
      return AttendanceResponse.error('Check Out operation failed: $e').toJson();
    }
  }

  /// Get attendance history for a user
  Future<List<Map<String, dynamic>>> getUserAttendanceHistory(int userId) async {
    try {
      final events = await _calendarEventService.getEventsForUser(userId.toString());
      return events.map((event) => event.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to get attendance history: $e');
    }
  }

  /// Get today's attendance for a user
  Future<Map<String, dynamic>?> getTodayAttendance(int userId) async {
    try {
      return await _calendarEventService.getUserAttendanceSummary(
        userId.toString(),
        DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get today\'s attendance: $e');
    }
  }

  /// Get attendance events for a specific date
  Future<List<Map<String, dynamic>>> getAttendanceForDate(DateTime date) async {
    try {
      final events = await _calendarEventService.getEventsForDate(date);
      return events.map((event) => event.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to get attendance for date: $e');
    }
  }

  /// Get attendance events in a date range
  Future<List<Map<String, dynamic>>> getAttendanceInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final events = await _calendarEventService.getEventsInRange(startDate, endDate);
      return events.map((event) => event.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to get attendance in range: $e');
    }
  }

  /// Get all Check In events
  Future<List<Map<String, dynamic>>> getAllCheckIns() async {
    try {
      final events = await _calendarEventService.getEventsByAction('Check In');
      return events.map((event) => event.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to get Check In events: $e');
    }
  }

  /// Get all Check Out events
  Future<List<Map<String, dynamic>>> getAllCheckOuts() async {
    try {
      final events = await _calendarEventService.getEventsByAction('Check Out');
      return events.map((event) => event.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to get Check Out events: $e');
    }
  }

  /// Get attendance summary for all users on a specific date
  Future<Map<String, dynamic>> getDailyAttendanceSummary(DateTime date) async {
    try {
      final events = await _calendarEventService.getEventsForDate(date);
      
      // Group events by user
      final userEvents = <String, List<CalendarEvent>>{};
      for (final event in events) {
        final userId = event.title.split(' - ')[0];
        userEvents.putIfAbsent(userId, () => []).add(event);
      }

      // Calculate summary
      int totalUsers = userEvents.length;
      int presentUsers = 0;
      int completeUsers = 0; // Users who both checked in and out

      for (final userEventList in userEvents.values) {
        bool hasCheckIn = userEventList.any((e) => e.title.contains('Check In'));
        bool hasCheckOut = userEventList.any((e) => e.title.contains('Check Out'));
        
        if (hasCheckIn) {
          presentUsers++;
          if (hasCheckOut) {
            completeUsers++;
          }
        }
      }

      return {
        'date': _formatDate(date),
        'totalUsers': totalUsers,
        'presentUsers': presentUsers,
        'completeUsers': completeUsers,
        'attendanceRate': totalUsers > 0 ? (presentUsers / totalUsers) * 100 : 0.0,
        'completionRate': presentUsers > 0 ? (completeUsers / presentUsers) * 100 : 0.0,
        'userEvents': userEvents.map((userId, events) => 
          MapEntry(userId, events.map((e) => e.toJson()).toList())),
      };
    } catch (e) {
      throw Exception('Failed to get daily attendance summary: $e');
    }
  }

  /// Export all attendance data
  Future<String> exportAttendanceData() async {
    try {
      return await _calendarEventService.exportEvents();
    } catch (e) {
      throw Exception('Failed to export attendance data: $e');
    }
  }

  /// Import attendance data
  Future<void> importAttendanceData(String jsonData) async {
    try {
      await _calendarEventService.importEvents(jsonData);
    } catch (e) {
      throw Exception('Failed to import attendance data: $e');
    }
  }

  /// Clear all attendance data
  Future<void> clearAllAttendanceData() async {
    try {
      await _calendarEventService.clearAllEvents();
    } catch (e) {
      throw Exception('Failed to clear attendance data: $e');
    }
  }

  /// Format date as yyyy-MM-dd
  String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}