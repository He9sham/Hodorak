import 'package:hodorak/core/models/notification_model.dart';

/// Filter logic for different types of notifications
class NotificationFilter {
  /// Check if a notification is meant for admin viewing
  static bool isAdminNotification(NotificationModel notification) {
    switch (notification.type) {
      // Admin sees all employee check-in/out activities
      case NotificationType.checkIn:
      case NotificationType.checkOut:
        return notification.userId == null ||
            notification.payload?.contains('_admin') == true;

      // Admin only sees new requests and rejected notifications
      case NotificationType.newLeaveRequest:
        return true;

      // Admin should NOT see submitted or approved notifications
      case NotificationType.leaveRequestSubmitted:
      case NotificationType.leaveRequestApproved:
      case NotificationType.leaveRequestRejected:
        return false;

      // Admin sees general and attendance notifications
      case NotificationType.attendance:
      case NotificationType.general:
        return true;
    }
  }

  /// Check if notification is check-in/out type
  static bool isCheckInOutNotification(NotificationModel notification) {
    return notification.type == NotificationType.checkIn ||
        notification.type == NotificationType.checkOut;
  }

  /// Check if notification is leave request related
  static bool isLeaveNotification(NotificationModel notification) {
    return notification.type == NotificationType.newLeaveRequest ||
        notification.type == NotificationType.leaveRequestApproved ||
        notification.type == NotificationType.leaveRequestRejected ||
        notification.type == NotificationType.leaveRequestSubmitted;
  }

  /// Group notifications by category
  static Map<String, List<NotificationModel>> groupNotifications(
    List<NotificationModel> notifications,
  ) {
    final checkInOut = <NotificationModel>[];
    final leave = <NotificationModel>[];
    final other = <NotificationModel>[];

    for (var notification in notifications) {
      if (isCheckInOutNotification(notification)) {
        checkInOut.add(notification);
      } else if (isLeaveNotification(notification)) {
        leave.add(notification);
      } else {
        other.add(notification);
      }
    }

    return {'checkInOut': checkInOut, 'leave': leave, 'other': other};
  }
}
