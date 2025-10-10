enum NotificationType {
  leaveRequestSubmitted,
  leaveRequestApproved,
  leaveRequestRejected,
  newLeaveRequest,
  attendance,
  general,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? payload;
  final DateTime createdAt;
  final bool isRead;
  final String? userId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.payload,
    required this.createdAt,
    this.isRead = false,
    this.userId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.general,
      ),
      payload: json['payload'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      userId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString(),
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'user_id': userId,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    String? payload,
    DateTime? createdAt,
    bool? isRead,
    String? userId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
    );
  }

  /// Get icon based on notification type
  String getIconPath() {
    switch (type) {
      case NotificationType.leaveRequestSubmitted:
      case NotificationType.leaveRequestApproved:
      case NotificationType.leaveRequestRejected:
      case NotificationType.newLeaveRequest:
        return '📋';
      case NotificationType.attendance:
        return '⏰';
      case NotificationType.general:
        return '🔔';
    }
  }
}
