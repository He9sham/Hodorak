import 'package:hodorak/core/services/ai_attendance_assistant.dart';
import 'package:hodorak/core/odoo_service/odoo_service.dart';

/// Test class for AI Attendance Assistant
/// This demonstrates how to use the AI attendance assistant
class AIAttendanceTest {
  final AIAttendanceAssistant assistant;

  AIAttendanceTest({required OdooService odooService})
      : assistant = AIAttendanceAssistant(odooService: odooService);

  /// Test Check In functionality
  Future<Map<String, dynamic>> testCheckIn({
    required int userId,
    String? location,
  }) async {
    print('Testing Check In for user $userId...');
    
    final response = await assistant.checkIn(
      userId: userId,
      location: location,
      includeLocation: true,
    );

    print('Check In Response:');
    print('Status: ${response['status']}');
    print('Message: ${response['message']}');
    print('Odoo Record: ${response['odoo']}');
    print('Calendar Event: ${response['calendar']}');

    return response;
  }

  /// Test Check Out functionality
  Future<Map<String, dynamic>> testCheckOut({
    required int userId,
    String? location,
  }) async {
    print('Testing Check Out for user $userId...');
    
    final response = await assistant.checkOut(
      userId: userId,
      location: location,
      includeLocation: true,
    );

    print('Check Out Response:');
    print('Status: ${response['status']}');
    print('Message: ${response['message']}');
    print('Odoo Record: ${response['odoo']}');
    print('Calendar Event: ${response['calendar']}');

    return response;
  }

  /// Test getting user attendance history
  Future<void> testUserHistory(int userId) async {
    print('Testing attendance history for user $userId...');
    
    final history = await assistant.getUserAttendanceHistory(userId);
    print('Found ${history.length} attendance records');
    
    for (final record in history) {
      print('  - ${record['title']} at ${record['start']}');
    }
  }

  /// Test getting daily summary
  Future<void> testDailySummary() async {
    print('Testing daily attendance summary...');
    
    final summary = await assistant.getDailyAttendanceSummary(DateTime.now());
    print('Daily Summary:');
    print('  Date: ${summary['date']}');
    print('  Total Users: ${summary['totalUsers']}');
    print('  Present Users: ${summary['presentUsers']}');
    print('  Attendance Rate: ${summary['attendanceRate']}%');
  }

  /// Run all tests
  Future<void> runAllTests() async {
    print('=== AI Attendance Assistant Test Suite ===\n');

    try {
      // Test Check In
      await testCheckIn(userId: 1, location: '37.7749, -122.4194');
      print('');

      // Test Check Out
      await testCheckOut(userId: 1, location: '37.7749, -122.4194');
      print('');

      // Test user history
      await testUserHistory(1);
      print('');

      // Test daily summary
      await testDailySummary();
      print('');

      print('=== All tests completed successfully! ===');
    } catch (e) {
      print('Test failed: $e');
    }
  }
}

/// Example usage function
Future<void> exampleUsage() async {
  // Initialize Odoo service (you would need to authenticate first)
  final odooService = OdooService();
  
  // Create AI attendance assistant
  final aiAssistant = AIAttendanceAssistant(odooService: odooService);

  // Example 1: Check In with location
  final checkInResponse = await aiAssistant.checkIn(
    userId: 1,
    location: '37.7749, -122.4194', // San Francisco coordinates
    includeLocation: true,
  );

  print('Check In Response:');
  print(checkInResponse);

  // Example 2: Check Out with location
  final checkOutResponse = await aiAssistant.checkOut(
    userId: 1,
    location: '37.7749, -122.4194',
    includeLocation: true,
  );

  print('Check Out Response:');
  print(checkOutResponse);

  // Example 3: Get user attendance history
  final history = await aiAssistant.getUserAttendanceHistory(1);
  print('User History: $history');

  // Example 4: Get daily summary
  final summary = await aiAssistant.getDailyAttendanceSummary(DateTime.now());
  print('Daily Summary: $summary');
}