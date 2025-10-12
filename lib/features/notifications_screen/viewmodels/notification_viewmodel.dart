import 'package:flutter/material.dart';
import 'package:hodorak/core/models/notification_model.dart';
import 'package:hodorak/core/providers/notification_provider.dart';
import 'package:hodorak/features/notifications_screen/utils/notification_formatter.dart';

/// ViewModel for the user notification screen
/// Handles business logic and coordinates between view and provider
class NotificationViewModel {
  final NotificationNotifier notificationNotifier;

  NotificationViewModel(this.notificationNotifier);

  /// Get formatted time string for a notification
  String getFormattedTime(DateTime dateTime) {
    return NotificationFormatter.formatTimeAgo(dateTime);
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await notificationNotifier.refresh();
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    await notificationNotifier.markAsRead(notificationId);
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await notificationNotifier.markAllAsRead();
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await notificationNotifier.deleteNotification(notificationId);
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await notificationNotifier.clearAllNotifications();
  }

  /// Handle notification tap
  Future<void> onNotificationTap(NotificationModel notification) async {
    if (!notification.isRead) {
      await markAsRead(notification.id);
    }
  }

  /// Handle notification delete with feedback
  Future<bool> onNotificationDelete(
    NotificationModel notification,
    BuildContext context,
  ) async {
    await deleteNotification(notification.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    return true;
  }

  /// Handle mark all as read action with feedback
  Future<void> handleMarkAllAsRead(BuildContext context) async {
    await markAllAsRead();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Handle clear all action with feedback
  Future<void> handleClearAll(BuildContext context) async {
    await clearAllNotifications();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications cleared'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
