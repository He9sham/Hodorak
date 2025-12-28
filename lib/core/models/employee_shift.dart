import 'shift.dart';

/// Represents an employee's assignment to a work shift
///
/// This model tracks when an employee is assigned to a specific shift,
/// with support for date ranges to handle shift changes over time.
class EmployeeShift {
  final String id;
  final String userId;
  final String shiftId;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional: Populated shift data when joined
  final Shift? shift;

  const EmployeeShift({
    required this.id,
    required this.userId,
    required this.shiftId,
    required this.effectiveFrom,
    this.effectiveTo,
    required this.createdAt,
    required this.updatedAt,
    this.shift,
  });

  /// Creates an EmployeeShift from JSON data from Supabase
  factory EmployeeShift.fromJson(Map<String, dynamic> json) {
    return EmployeeShift(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      shiftId: json['shift_id'] as String,
      effectiveFrom: DateTime.parse(json['effective_from'] as String),
      effectiveTo: json['effective_to'] != null
          ? DateTime.parse(json['effective_to'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      shift: json['shifts'] != null ? Shift.fromJson(json['shifts']) : null,
    );
  }

  /// Converts EmployeeShift to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shift_id': shiftId,
      'effective_from': effectiveFrom.toIso8601String(),
      'effective_to': effectiveTo?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Converts EmployeeShift to JSON for insert/update operations (without id)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'shift_id': shiftId,
      'effective_from': _formatDateOnly(effectiveFrom),
      'effective_to': effectiveTo != null
          ? _formatDateOnly(effectiveTo!)
          : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Format DateTime to date-only string (YYYY-MM-DD)
  String _formatDateOnly(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Checks if this shift assignment is currently active
  bool get isActive {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return effectiveFrom.isBefore(today) ||
        effectiveFrom.isAtSameMomentAs(today) &&
            (effectiveTo == null ||
                effectiveTo!.isAfter(today) ||
                effectiveTo!.isAtSameMomentAs(today));
  }

  /// Checks if this shift assignment is active on a specific date
  bool isActiveOnDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return (effectiveFrom.isBefore(dateOnly) ||
            effectiveFrom.isAtSameMomentAs(dateOnly)) &&
        (effectiveTo == null ||
            effectiveTo!.isAfter(dateOnly) ||
            effectiveTo!.isAtSameMomentAs(dateOnly));
  }

  /// Creates a copy of this EmployeeShift with updated fields
  EmployeeShift copyWith({
    String? id,
    String? userId,
    String? shiftId,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    Shift? shift,
  }) {
    return EmployeeShift(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shiftId: shiftId ?? this.shiftId,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shift: shift ?? this.shift,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmployeeShift &&
        other.id == id &&
        other.userId == userId &&
        other.shiftId == shiftId &&
        other.effectiveFrom == effectiveFrom &&
        other.effectiveTo == effectiveTo;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, shiftId, effectiveFrom, effectiveTo);
  }

  @override
  String toString() {
    return 'EmployeeShift(id: $id, userId: $userId, shiftId: $shiftId, from: $effectiveFrom, to: $effectiveTo, active: $isActive)';
  }
}
