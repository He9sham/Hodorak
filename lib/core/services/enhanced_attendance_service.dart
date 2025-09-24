import 'package:hodorak/core/odoo_service/odoo_service.dart';
import 'package:hodorak/core/models/attendance_response.dart';

class EnhancedAttendanceService {
  final OdooService odooService;

  EnhancedAttendanceService({required this.odooService});

  /// Format DateTime to yyyy-MM-dd HH:mm:ss format
  String _formatDateTime(DateTime dateTime) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dateTime.year}-${two(dateTime.month)}-${two(dateTime.day)} '
        '${two(dateTime.hour)}:${two(dateTime.minute)}:${two(dateTime.second)}';
  }

  /// Generate a unique event ID
  String _generateEventId(String userId, String action, DateTime timestamp) {
    final timestampStr = timestamp.millisecondsSinceEpoch.toString();
    return '${userId}_${action.toLowerCase().replaceAll(' ', '_')}_$timestampStr';
  }

  /// Check In with location support
  Future<AttendanceResponse> checkIn({
    required int employeeId,
    String? location,
  }) async {
    try {
      final timestamp = DateTime.now();
      final timestampStr = _formatDateTime(timestamp);
      final userId = employeeId.toString();
      final action = 'Check In';
      final eventId = _generateEventId(userId, action, timestamp);

      // Save to Odoo database
      final attendanceId = await odooService.checkIn(employeeId);

      // Return success response
      return AttendanceResponse.success(
        userId: userId,
        action: action,
        timestamp: timestampStr,
        location: location,
        eventId: eventId,
        endTime: null, // Check In doesn't have end time
      );
    } catch (e) {
      return AttendanceResponse.error('Check In failed: $e');
    }
  }

  /// Check Out with location support
  Future<AttendanceResponse> checkOut({
    required int employeeId,
    String? location,
  }) async {
    try {
      final timestamp = DateTime.now();
      final timestampStr = _formatDateTime(timestamp);
      final userId = employeeId.toString();
      final action = 'Check Out';
      final eventId = _generateEventId(userId, action, timestamp);

      // Save to Odoo database
      final success = await odooService.checkOut(employeeId);

      if (!success) {
        return AttendanceResponse.error('No open attendance record found for this employee');
      }

      // Return success response with end time
      return AttendanceResponse.success(
        userId: userId,
        action: action,
        timestamp: timestampStr,
        location: location,
        eventId: eventId,
        endTime: timestampStr, // Check Out has end time
      );
    } catch (e) {
      return AttendanceResponse.error('Check Out failed: $e');
    }
  }

  /// Get current location (placeholder for future GPS integration)
  Future<String?> getCurrentLocation() async {
    // TODO: Implement GPS location fetching
    // For now, return a placeholder
    return '37.7749, -122.4194'; // San Francisco coordinates as example
  }

  /// Check In with automatic location detection
  Future<AttendanceResponse> checkInWithLocation({
    required int employeeId,
    bool includeLocation = true,
  }) async {
    String? location;
    if (includeLocation) {
      location = await getCurrentLocation();
    }

    return await checkIn(
      employeeId: employeeId,
      location: location,
    );
  }

  /// Check Out with automatic location detection
  Future<AttendanceResponse> checkOutWithLocation({
    required int employeeId,
    bool includeLocation = true,
  }) async {
    String? location;
    if (includeLocation) {
      location = await getCurrentLocation();
    }

    return await checkOut(
      employeeId: employeeId,
      location: location,
    );
  }
}