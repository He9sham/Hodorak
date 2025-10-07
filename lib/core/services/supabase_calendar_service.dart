import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/supabase_calendar_event.dart';
import '../supabase/supabase_config.dart';
import '../supabase/supabase_service.dart';
import '../utils/logger.dart';

class SupabaseCalendarService {
  final SupabaseClient _client = SupabaseService.client;

  // Save calendar event
  Future<SupabaseCalendarEvent> saveEvent({
    required String title,
    required String description,
    required DateTime startTime,
    DateTime? endTime,
    required String userId,
    String? location,
    required String eventType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      Logger.debug('SupabaseCalendarService: Saving event: $title');

      final eventData = {
        'title': title,
        'description': description,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'user_id': userId,
        'location': location,
        'event_type': eventType,
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final data = await _client
          .from(SupabaseConfig.calendarEventsTable)
          .insert(eventData)
          .select()
          .single();

      Logger.info(
        'SupabaseCalendarService: Event saved successfully: ${data['id']}',
      );
      return SupabaseCalendarEvent.fromJson(data);
    } catch (e) {
      Logger.error('SupabaseCalendarService: Error saving event: $e');
      rethrow;
    }
  }

  // Get events for a specific user
  Future<List<SupabaseCalendarEvent>> getEventsForUser({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
  }) async {
    try {
      dynamic query = _client
          .from(SupabaseConfig.calendarEventsTable)
          .select()
          .eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('start_time', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('start_time', endDate.toIso8601String());
      }

      if (eventType != null) {
        query = query.eq('event_type', eventType);
      }

      query = query.order('start_time', ascending: true);

      final data = await query;

      return (data as List)
          .map((event) => SupabaseCalendarEvent.fromJson(event))
          .toList();
    } catch (e) {
      Logger.error('SupabaseCalendarService: Error fetching user events: $e');
      rethrow;
    }
  }

  // Get events for a specific date
  Future<List<SupabaseCalendarEvent>> getEventsForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final data = await _client
          .from(SupabaseConfig.calendarEventsTable)
          .select('*, users(name)')
          .gte('start_time', startOfDay.toIso8601String())
          .lt('start_time', endOfDay.toIso8601String())
          .order('start_time', ascending: true);

      return (data as List)
          .map((event) => SupabaseCalendarEvent.fromJson(event))
          .toList();
    } catch (e) {
      Logger.error(
        'SupabaseCalendarService: Error fetching events for date: $e',
      );
      rethrow;
    }
  }

  // Get events in a date range
  Future<List<SupabaseCalendarEvent>> getEventsInRange({
    required DateTime startDate,
    required DateTime endDate,
    String? eventType,
  }) async {
    try {
      dynamic query = _client
          .from(SupabaseConfig.calendarEventsTable)
          .select('*, users(name)')
          .gte('start_time', startDate.toIso8601String())
          .lte('start_time', endDate.toIso8601String());

      if (eventType != null) {
        query = query.eq('event_type', eventType);
      }

      query = query.order('start_time', ascending: true);

      final data = await query;

      return (data as List)
          .map((event) => SupabaseCalendarEvent.fromJson(event))
          .toList();
    } catch (e) {
      Logger.error(
        'SupabaseCalendarService: Error fetching events in range: $e',
      );
      rethrow;
    }
  }

  // Get all events (admin only)
  Future<List<SupabaseCalendarEvent>> getAllEvents({
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
    int? limit,
  }) async {
    try {
      dynamic query = _client
          .from(SupabaseConfig.calendarEventsTable)
          .select('*, users(name, email)');

      if (startDate != null) {
        query = query.gte('start_time', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('start_time', endDate.toIso8601String());
      }

      if (eventType != null) {
        query = query.eq('event_type', eventType);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      query = query.order('start_time', ascending: false);

      final data = await query;

      return (data as List)
          .map((event) => SupabaseCalendarEvent.fromJson(event))
          .toList();
    } catch (e) {
      Logger.error('SupabaseCalendarService: Error fetching all events: $e');
      rethrow;
    }
  }

  // Update event
  Future<SupabaseCalendarEvent> updateEvent({
    required String eventId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? eventType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      Logger.debug('SupabaseCalendarService: Updating event: $eventId');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (startTime != null) {
        updateData['start_time'] = startTime.toIso8601String();
      }
      if (endTime != null) updateData['end_time'] = endTime.toIso8601String();
      if (location != null) updateData['location'] = location;
      if (eventType != null) updateData['event_type'] = eventType;
      if (metadata != null) updateData['metadata'] = metadata;

      final data = await _client
          .from(SupabaseConfig.calendarEventsTable)
          .update(updateData)
          .eq('id', eventId)
          .select()
          .single();

      Logger.info(
        'SupabaseCalendarService: Event updated successfully: $eventId',
      );
      return SupabaseCalendarEvent.fromJson(data);
    } catch (e) {
      Logger.error('SupabaseCalendarService: Error updating event: $e');
      rethrow;
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      Logger.debug('SupabaseCalendarService: Deleting event: $eventId');

      await _client
          .from(SupabaseConfig.calendarEventsTable)
          .delete()
          .eq('id', eventId);

      Logger.info(
        'SupabaseCalendarService: Event deleted successfully: $eventId',
      );
    } catch (e) {
      Logger.error('SupabaseCalendarService: Error deleting event: $e');
      rethrow;
    }
  }

  // Get event by ID
  Future<SupabaseCalendarEvent?> getEventById(String eventId) async {
    try {
      final data = await _client
          .from(SupabaseConfig.calendarEventsTable)
          .select('*, users(name, email)')
          .eq('id', eventId)
          .maybeSingle();

      if (data == null) return null;

      return SupabaseCalendarEvent.fromJson(data);
    } catch (e) {
      Logger.error('SupabaseCalendarService: Error fetching event by ID: $e');
      rethrow;
    }
  }

  // Create attendance event from check-in/check-out
  Future<SupabaseCalendarEvent> createAttendanceEvent({
    required String userId,
    required String action, // 'check_in' or 'check_out'
    required DateTime timestamp,
    String? location,
    String? attendanceId,
  }) async {
    try {
      final title = '$userId - $action';
      final description =
          'Attendance $action at ${timestamp.toIso8601String()}';

      return await saveEvent(
        title: title,
        description: description,
        startTime: timestamp,
        userId: userId,
        location: location,
        eventType: 'attendance',
        metadata: {'action': action, 'attendance_id': attendanceId},
      );
    } catch (e) {
      Logger.error(
        'SupabaseCalendarService: Error creating attendance event: $e',
      );
      rethrow;
    }
  }
}
