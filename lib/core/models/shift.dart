import 'package:flutter/material.dart';

/// Represents a work shift definition
///
/// A shift defines the working hours for employees, including:
/// - Start and end times
/// - Grace period for late arrivals
/// - Whether the shift spans across midnight (overnight)
class Shift {
  final String id;
  final String companyId;
  final String name;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int gracePeriodMinutes;
  final bool isOvernight;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Shift({
    required this.id,
    required this.companyId,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.gracePeriodMinutes,
    required this.isOvernight,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a Shift from JSON data from Supabase
  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      name: json['name'] as String,
      startTime: _parseTimeOfDay(json['start_time'] as String),
      endTime: _parseTimeOfDay(json['end_time'] as String),
      gracePeriodMinutes: json['grace_period_minutes'] as int,
      isOvernight: json['is_overnight'] as bool,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts Shift to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'start_time': _formatTimeOfDay(startTime),
      'end_time': _formatTimeOfDay(endTime),
      'grace_period_minutes': gracePeriodMinutes,
      'is_overnight': isOvernight,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Converts Shift to JSON for insert/update operations (without id)
  Map<String, dynamic> toInsertJson() {
    return {
      'company_id': companyId,
      'name': name,
      'start_time': _formatTimeOfDay(startTime),
      'end_time': _formatTimeOfDay(endTime),
      'grace_period_minutes': gracePeriodMinutes,
      'is_overnight': isOvernight,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Parse PostgreSQL TIME format (HH:MM:SS) to TimeOfDay
  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Format TimeOfDay to PostgreSQL TIME format (HH:MM:SS)
  static String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  /// Returns a formatted string for the shift time range
  /// Example: "09:00 AM - 05:00 PM"
  String get formattedTimeRange {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  /// Returns a formatted string for start time with grace period
  /// Example: "09:15 AM" (if start is 09:00 and grace is 15 minutes)
  String get formattedStartTimeWithGrace {
    final graceTime = _addMinutesToTime(startTime, gracePeriodMinutes);
    return _formatTime(graceTime);
  }

  /// Helper to format TimeOfDay to 12-hour format
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Helper to add minutes to TimeOfDay
  TimeOfDay _addMinutesToTime(TimeOfDay time, int minutes) {
    final totalMinutes = time.hour * 60 + time.minute + minutes;
    final newHour = (totalMinutes ~/ 60) % 24;
    final newMinute = totalMinutes % 60;
    return TimeOfDay(hour: newHour, minute: newMinute);
  }

  /// Creates a copy of this Shift with updated fields
  Shift copyWith({
    String? id,
    String? companyId,
    String? name,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? gracePeriodMinutes,
    bool? isOvernight,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Shift(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      gracePeriodMinutes: gracePeriodMinutes ?? this.gracePeriodMinutes,
      isOvernight: isOvernight ?? this.isOvernight,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Shift &&
        other.id == id &&
        other.companyId == companyId &&
        other.name == name &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.gracePeriodMinutes == gracePeriodMinutes &&
        other.isOvernight == isOvernight &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      companyId,
      name,
      startTime,
      endTime,
      gracePeriodMinutes,
      isOvernight,
      isActive,
    );
  }

  @override
  String toString() {
    return 'Shift(id: $id, name: $name, time: $formattedTimeRange, grace: ${gracePeriodMinutes}min, overnight: $isOvernight)';
  }
}
