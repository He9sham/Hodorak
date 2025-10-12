import 'package:flutter/material.dart';
import 'package:hodorak/core/models/notification_model.dart';

/// Configuration for how notifications should be displayed
class NotificationDisplayConfig {
  final NotificationType type;
  final IconData icon;
  final Color color;
  final String label;

  const NotificationDisplayConfig({
    required this.type,
    required this.icon,
    required this.color,
    required this.label,
  });

  /// Get display config for a notification type
  static NotificationDisplayConfig forType(NotificationType type) {
    switch (type) {
      case NotificationType.leaveRequestSubmitted:
        return const NotificationDisplayConfig(
          type: NotificationType.leaveRequestSubmitted,
          icon: Icons.send,
          color: Colors.blue,
          label: 'Leave Submitted',
        );
      case NotificationType.leaveRequestApproved:
        return const NotificationDisplayConfig(
          type: NotificationType.leaveRequestApproved,
          icon: Icons.check_circle,
          color: Colors.green,
          label: 'Approved',
        );
      case NotificationType.leaveRequestRejected:
        return const NotificationDisplayConfig(
          type: NotificationType.leaveRequestRejected,
          icon: Icons.cancel,
          color: Colors.red,
          label: 'Rejected',
        );
      case NotificationType.newLeaveRequest:
        return const NotificationDisplayConfig(
          type: NotificationType.newLeaveRequest,
          icon: Icons.assignment,
          color: Colors.orange,
          label: 'New Leave',
        );
      case NotificationType.attendance:
        return const NotificationDisplayConfig(
          type: NotificationType.attendance,
          icon: Icons.access_time,
          color: Colors.purple,
          label: 'Attendance',
        );
      case NotificationType.checkIn:
        return const NotificationDisplayConfig(
          type: NotificationType.checkIn,
          icon: Icons.login,
          color: Colors.green,
          label: 'Check In',
        );
      case NotificationType.checkOut:
        return const NotificationDisplayConfig(
          type: NotificationType.checkOut,
          icon: Icons.logout,
          color: Colors.orange,
          label: 'Check Out',
        );
      case NotificationType.general:
        return const NotificationDisplayConfig(
          type: NotificationType.general,
          icon: Icons.notifications,
          color: Color(0xff8C9F5F),
          label: 'General',
        );
    }
  }
}
