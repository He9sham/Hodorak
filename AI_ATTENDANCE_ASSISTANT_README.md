# AI Attendance Assistant

An intelligent attendance management system that integrates with Odoo and Calendar systems to provide comprehensive attendance tracking with location support and JSON API responses.

## Features

- **Check In/Check Out Operations**: Record employee attendance with automatic timestamp and location tracking
- **Odoo Integration**: Seamlessly saves attendance records to Odoo database
- **Calendar Events**: Creates individual calendar events for each attendance action
- **Location Support**: Optional GPS location tracking for attendance records
- **JSON API Responses**: Structured JSON responses for all operations
- **Attendance History**: Complete attendance tracking and reporting
- **Daily Summaries**: Automated daily attendance summaries

## Architecture

### Core Components

1. **AI Attendance Assistant** (`ai_attendance_assistant.dart`)
   - Main service that orchestrates all attendance operations
   - Provides JSON API responses as specified in requirements

2. **Enhanced Attendance Service** (`enhanced_attendance_service.dart`)
   - Handles Check In/Check Out operations with location support
   - Integrates with existing Odoo service

3. **Calendar Event Service** (`calendar_event_service.dart`)
   - Manages individual attendance events in calendar system
   - Provides event storage, retrieval, and management

4. **Attendance Response Models** (`attendance_response.dart`)
   - Defines structured response format for JSON API
   - Includes Odoo record and Calendar event data

5. **AI Attendance Provider** (`ai_attendance_provider.dart`)
   - Riverpod state management for Flutter UI
   - Handles reactive state updates

6. **AI Attendance Screen** (`ai_attendance_screen.dart`)
   - Flutter UI component for attendance operations
   - Displays JSON responses and attendance history

## JSON Response Format

All Check In/Check Out operations return a JSON response in the following format:

```json
{
  "status": "success",
  "message": "Attendance recorded successfully",
  "odoo": {
    "userId": "1",
    "action": "Check In",
    "timestamp": "2024-01-15 09:30:00",
    "location": "37.7749, -122.4194"
  },
  "calendar": {
    "eventId": "1_Check_In_1705312200000",
    "title": "1 - Check In",
    "start": "2024-01-15 09:30:00",
    "end": null,
    "notes": "Location: 37.7749, -122.4194"
  }
}
```

### Response Fields

- **status**: "success" or "error"
- **message**: Human-readable status message
- **odoo**: Odoo database record information
  - **userId**: Employee ID
  - **action**: "Check In" or "Check Out"
  - **timestamp**: Formatted timestamp (yyyy-MM-dd HH:mm:ss)
  - **location**: GPS coordinates (latitude, longitude) if available
- **calendar**: Calendar event information
  - **eventId**: Unique event identifier
  - **title**: Event title format: "{userId} - {action}"
  - **start**: Event start time
  - **end**: Event end time (only for Check Out)
  - **notes**: Location information if available

## Usage Examples

### Basic Check In/Check Out

```dart
// Initialize AI Attendance Assistant
final aiAssistant = AIAttendanceAssistant(odooService: odooService);

// Check In
final checkInResponse = await aiAssistant.checkIn(
  userId: 1,
  location: '37.7749, -122.4194',
  includeLocation: true,
);

// Check Out
final checkOutResponse = await aiAssistant.checkOut(
  userId: 1,
  location: '37.7749, -122.4194',
  includeLocation: true,
);
```

### Using with Flutter Provider

```dart
// In your Flutter widget
final attendanceNotifier = ref.read(aiAttendanceProvider(odooService).notifier);

// Check In
final response = await attendanceNotifier.checkIn(
  employeeId: 1,
  location: '37.7749, -122.4194',
  includeLocation: true,
);

// Check Out
final response = await attendanceNotifier.checkOut(
  employeeId: 1,
  location: '37.7749, -122.4194',
  includeLocation: true,
);
```

### Getting Attendance Data

```dart
// Get user attendance history
final history = await aiAssistant.getUserAttendanceHistory(1);

// Get today's attendance for a user
final todayAttendance = await aiAssistant.getTodayAttendance(1);

// Get daily attendance summary
final summary = await aiAssistant.getDailyAttendanceSummary(DateTime.now());

// Get attendance in date range
final rangeData = await aiAssistant.getAttendanceInRange(
  DateTime(2024, 1, 1),
  DateTime(2024, 1, 31),
);
```

## Integration with Existing System

The AI Attendance Assistant is designed to work alongside the existing attendance system:

1. **Backward Compatibility**: Existing attendance screens continue to work
2. **Enhanced Features**: New AI assistant provides additional functionality
3. **Shared Data**: Both systems use the same Odoo database
4. **Calendar Integration**: Events are stored separately for detailed tracking

## Location Support

Location tracking is optional and can be configured:

- **Automatic Detection**: Uses GPS to get current location (placeholder implementation)
- **Manual Input**: Users can manually enter location coordinates
- **Format**: Locations are stored as "latitude, longitude" strings
- **Privacy**: Location tracking can be disabled per operation

## Error Handling

The system provides comprehensive error handling:

- **Validation Errors**: Invalid employee IDs, missing data
- **Network Errors**: Odoo connection issues
- **Storage Errors**: Calendar event storage failures
- **Location Errors**: GPS access issues

All errors are returned in the JSON response format with appropriate error messages.

## Testing

A test suite is provided (`ai_attendance_test.dart`) that demonstrates:

- Check In/Check Out operations
- JSON response validation
- Attendance history retrieval
- Daily summary generation

Run tests to verify the integration:

```dart
final test = AIAttendanceTest(odooService: odooService);
await test.runAllTests();
```

## File Structure

```
lib/
├── core/
│   ├── models/
│   │   └── attendance_response.dart
│   ├── services/
│   │   ├── ai_attendance_assistant.dart
│   │   ├── enhanced_attendance_service.dart
│   │   ├── calendar_event_service.dart
│   │   └── ai_attendance_test.dart
│   └── providers/
│       └── ai_attendance_provider.dart
└── features/
    └── attendance_screen/
        └── view/
            └── ai_attendance_screen.dart
```

## Requirements Met

✅ **Odoo Integration**: Saves records to Odoo database with userId, action, timestamp, and location  
✅ **Calendar Events**: Creates calendar events with proper title, start/end times, and notes  
✅ **JSON Response**: Returns structured JSON responses as specified  
✅ **Location Support**: Optional location tracking with GPS coordinates  
✅ **Timestamp Format**: Uses yyyy-MM-dd HH:mm:ss format  
✅ **Event Management**: Individual events for each Check In/Check Out action  

## Future Enhancements

- **Real GPS Integration**: Implement actual GPS location fetching
- **Offline Support**: Cache attendance data for offline operations
- **Advanced Analytics**: More detailed attendance reporting and analytics
- **Multi-language Support**: Internationalization for different languages
- **Biometric Integration**: Fingerprint or face recognition support
- **Push Notifications**: Real-time notifications for attendance events