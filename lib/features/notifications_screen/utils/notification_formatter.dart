import 'package:hodorak/core/models/notification_model.dart';
import 'package:intl/intl.dart';

/// Utility class for formatting notification data for display
class NotificationFormatter {
  /// Format time ago string (e.g., "2h ago", "Just now")
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }

  /// Format notification body to show user names in admin-friendly format
  static String formatNotificationBodyForAdmin(NotificationModel notification) {
    final body = notification.body;

    // Pattern matching for different notification types
    switch (notification.type) {
      case NotificationType.newLeaveRequest:
        // Handle: "hesham hemdan has submitted a leave request"
        if (body.contains(' has submitted a leave request')) {
          final username = body.substring(
            0,
            body.indexOf(' has submitted a leave request'),
          );
          return '$username has submitted a leave request';
        }
        return body;

      case NotificationType.checkIn:
        // Handle: "Employee John has checked in at location"
        if (body.startsWith('Employee ') && body.contains(' has checked in')) {
          final remaining = body.substring(9); // Remove "Employee "
          if (remaining.contains(' at ')) {
            final username = remaining.substring(
              0,
              remaining.indexOf(' has checked in'),
            );
            final location = remaining.substring(remaining.indexOf(' at ') + 4);
            return '$username checked in at $location';
          } else {
            final username = remaining.substring(
              0,
              remaining.indexOf(' has checked in'),
            );
            return '$username checked in';
          }
        }
        return body;

      case NotificationType.checkOut:
        // Handle: "Employee John has checked out at location"
        if (body.startsWith('Employee ') && body.contains(' has checked out')) {
          final remaining = body.substring(9); // Remove "Employee "
          if (remaining.contains(' at ')) {
            final username = remaining.substring(
              0,
              remaining.indexOf(' has checked out'),
            );
            final location = remaining.substring(remaining.indexOf(' at ') + 4);
            return '$username checked out at $location';
          } else {
            final username = remaining.substring(
              0,
              remaining.indexOf(' has checked out'),
            );
            return '$username checked out';
          }
        }
        return body;

      default:
        return body;
    }
  }
}
