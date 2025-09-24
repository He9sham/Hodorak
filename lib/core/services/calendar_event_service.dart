import 'dart:convert';
import 'package:hodorak/core/models/attendance_response.dart';
import 'package:hodorak/core/services/file_storage_service.dart';

class CalendarEventService {
  final FileStorageService _storage = FileStorageService();
  static const String _eventsKey = 'attendance_events';

  /// Save individual attendance event to calendar
  Future<void> saveAttendanceEvent(CalendarEvent event) async {
    final events = await getAllEvents();
    events[event.eventId] = event.toJson();
    await _storage.saveData({_eventsKey: events});
  }

  /// Get all attendance events
  Future<Map<String, dynamic>> getAllEvents() async {
    final data = await _storage.loadData();
    final events = data[_eventsKey];
    return events is Map<String, dynamic> ? events : {};
  }

  /// Get events for a specific user
  Future<List<CalendarEvent>> getEventsForUser(String userId) async {
    final allEvents = await getAllEvents();
    final userEvents = <CalendarEvent>[];

    for (final eventData in allEvents.values) {
      if (eventData is Map<String, dynamic>) {
        final event = CalendarEvent.fromJson(eventData);
        if (event.title.startsWith('$userId -')) {
          userEvents.add(event);
        }
      }
    }

    // Sort by start time (most recent first)
    userEvents.sort((a, b) => b.start.compareTo(a.start));
    return userEvents;
  }

  /// Get events for a specific date
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    final allEvents = await getAllEvents();
    final dateEvents = <CalendarEvent>[];
    final dateStr = _formatDate(date);

    for (final eventData in allEvents.values) {
      if (eventData is Map<String, dynamic>) {
        final event = CalendarEvent.fromJson(eventData);
        if (event.start.startsWith(dateStr)) {
          dateEvents.add(event);
        }
      }
    }

    // Sort by start time
    dateEvents.sort((a, b) => a.start.compareTo(b.start));
    return dateEvents;
  }

  /// Get events for a date range
  Future<List<CalendarEvent>> getEventsInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allEvents = await getAllEvents();
    final rangeEvents = <CalendarEvent>[];

    for (final eventData in allEvents.values) {
      if (eventData is Map<String, dynamic>) {
        final event = CalendarEvent.fromJson(eventData);
        final eventDate = _parseDateTime(event.start);
        
        if (eventDate != null &&
            eventDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            eventDate.isBefore(endDate.add(const Duration(days: 1)))) {
          rangeEvents.add(event);
        }
      }
    }

    // Sort by start time (most recent first)
    rangeEvents.sort((a, b) => b.start.compareTo(a.start));
    return rangeEvents;
  }

  /// Get today's events
  Future<List<CalendarEvent>> getTodayEvents() async {
    return await getEventsForDate(DateTime.now());
  }

  /// Get events by action type (Check In or Check Out)
  Future<List<CalendarEvent>> getEventsByAction(String action) async {
    final allEvents = await getAllEvents();
    final actionEvents = <CalendarEvent>[];

    for (final eventData in allEvents.values) {
      if (eventData is Map<String, dynamic>) {
        final event = CalendarEvent.fromJson(eventData);
        if (event.title.contains(action)) {
          actionEvents.add(event);
        }
      }
    }

    // Sort by start time (most recent first)
    actionEvents.sort((a, b) => b.start.compareTo(a.start));
    return actionEvents;
  }

  /// Delete an event
  Future<bool> deleteEvent(String eventId) async {
    final events = await getAllEvents();
    if (events.containsKey(eventId)) {
      events.remove(eventId);
      await _storage.saveData({_eventsKey: events});
      return true;
    }
    return false;
  }

  /// Clear all events
  Future<void> clearAllEvents() async {
    await _storage.saveData({_eventsKey: {}});
  }

  /// Export events as JSON
  Future<String> exportEvents() async {
    final events = await getAllEvents();
    return jsonEncode(events);
  }

  /// Import events from JSON
  Future<void> importEvents(String jsonData) async {
    try {
      final data = jsonDecode(jsonData);
      if (data is Map<String, dynamic>) {
        await _storage.saveData({_eventsKey: data});
      } else {
        throw Exception('Invalid data format');
      }
    } catch (e) {
      throw Exception('Failed to import events: $e');
    }
  }

  /// Get attendance summary for a user on a specific date
  Future<Map<String, dynamic>> getUserAttendanceSummary(
    String userId,
    DateTime date,
  ) async {
    final events = await getEventsForDate(date);
    final userEvents = events.where((e) => e.title.startsWith('$userId -')).toList();

    DateTime? checkIn;
    DateTime? checkOut;
    String? checkInLocation;
    String? checkOutLocation;

    for (final event in userEvents) {
      if (event.title.contains('Check In')) {
        checkIn = _parseDateTime(event.start);
        checkInLocation = event.notes?.replaceFirst('Location: ', '');
      } else if (event.title.contains('Check Out')) {
        checkOut = _parseDateTime(event.start);
        checkOutLocation = event.notes?.replaceFirst('Location: ', '');
      }
    }

    Duration? workingHours;
    if (checkIn != null && checkOut != null) {
      workingHours = checkOut.difference(checkIn);
    } else if (checkIn != null) {
      workingHours = DateTime.now().difference(checkIn);
    }

    return {
      'userId': userId,
      'date': _formatDate(date),
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'checkInLocation': checkInLocation,
      'checkOutLocation': checkOutLocation,
      'workingHours': workingHours?.inMinutes,
      'isPresent': checkIn != null,
      'isComplete': checkIn != null && checkOut != null,
    };
  }

  /// Format date as yyyy-MM-dd
  String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  /// Parse DateTime from string
  DateTime? _parseDateTime(String dateTimeStr) {
    try {
      return DateTime.parse(dateTimeStr);
    } catch (e) {
      return null;
    }
  }
}

// Extension to add fromJson method to CalendarEvent
extension CalendarEventExtension on CalendarEvent {
  static CalendarEvent fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      eventId: json['eventId'] ?? '',
      title: json['title'] ?? '',
      start: json['start'] ?? '',
      end: json['end'],
      notes: json['notes'],
    );
  }
}