class LeaveRequest {
  final String id;
  final String userId;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime? updatedAt;

  LeaveRequest({
    required this.id,
    required this.userId,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory LeaveRequest.fromMap(Map<String, dynamic> map, String id) {
    return LeaveRequest(
      id: id,
      userId: map['userId'] ?? '',
      reason: map['reason'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'reason': reason,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  LeaveRequest copyWith({
    String? id,
    String? userId,
    String? reason,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reason: reason ?? this.reason,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get the duration of the leave request in days
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Check if the leave request is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Check if the leave request is in the past
  bool get isPast {
    return DateTime.now().isAfter(endDate);
  }

  /// Check if the leave request is in the future
  bool get isFuture {
    return DateTime.now().isBefore(startDate);
  }
}

enum LeaveStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const LeaveStatus(this.value);
  final String value;

  static LeaveStatus fromString(String status) {
    return LeaveStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => LeaveStatus.pending,
    );
  }
}
