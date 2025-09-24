class AttendanceResponse {
  final String status;
  final String message;
  final OdooRecord odoo;
  final CalendarEvent calendar;

  AttendanceResponse({
    required this.status,
    required this.message,
    required this.odoo,
    required this.calendar,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'odoo': odoo.toJson(),
      'calendar': calendar.toJson(),
    };
  }

  factory AttendanceResponse.success({
    required String userId,
    required String action,
    required String timestamp,
    String? location,
    required String eventId,
    String? endTime,
  }) {
    return AttendanceResponse(
      status: 'success',
      message: 'Attendance recorded successfully',
      odoo: OdooRecord(
        userId: userId,
        action: action,
        timestamp: timestamp,
        location: location,
      ),
      calendar: CalendarEvent(
        eventId: eventId,
        title: '$userId - $action',
        start: timestamp,
        end: endTime,
        notes: location != null ? 'Location: $location' : null,
      ),
    );
  }

  factory AttendanceResponse.error(String message) {
    return AttendanceResponse(
      status: 'error',
      message: message,
      odoo: OdooRecord(
        userId: '',
        action: '',
        timestamp: '',
        location: null,
      ),
      calendar: CalendarEvent(
        eventId: '',
        title: '',
        start: '',
        end: null,
        notes: null,
      ),
    );
  }
}

class OdooRecord {
  final String userId;
  final String action;
  final String timestamp;
  final String? location;

  OdooRecord({
    required this.userId,
    required this.action,
    required this.timestamp,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'action': action,
      'timestamp': timestamp,
      'location': location,
    };
  }
}

class CalendarEvent {
  final String eventId;
  final String title;
  final String start;
  final String? end;
  final String? notes;

  CalendarEvent({
    required this.eventId,
    required this.title,
    required this.start,
    this.end,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'title': title,
      'start': start,
      'end': end,
      'notes': notes,
    };
  }
}