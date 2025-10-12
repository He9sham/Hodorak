import 'package:flutter/material.dart';
import 'package:hodorak/core/models/notification_model.dart';
import 'package:hodorak/core/providers/notification_provider.dart';
import 'package:hodorak/features/notifications_screen/models/notification_filter.dart';
import 'package:hodorak/features/notifications_screen/utils/notification_formatter.dart';

/// ViewModel for the admin notification screen
/// Handles business logic, filtering, and grouping of admin notifications
class AdminNotificationViewModel {
  final NotificationNotifier notificationNotifier;

  AdminNotificationViewModel(this.notificationNotifier);

  /// Filter notifications to show only admin notifications
  List<NotificationModel> filterAdminNotifications(
    List<NotificationModel> notifications,
  ) {
    return notifications.where(NotificationFilter.isAdminNotification).toList();
  }

  /// Group notifications by category
  Map<String, List<NotificationModel>> groupNotifications(
    List<NotificationModel> notifications,
  ) {
    return NotificationFilter.groupNotifications(notifications);
  }

  /// Get formatted time string for a notification
  String getFormattedTime(DateTime dateTime) {
    return NotificationFormatter.formatTimeAgo(dateTime);
  }

  /// Get formatted notification body for admin view
  String getFormattedBody(NotificationModel notification) {
    return NotificationFormatter.formatNotificationBodyForAdmin(notification);
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

  /// Handle notification delete
  Future<bool> onNotificationDelete(NotificationModel notification) async {
    await deleteNotification(notification.id);
    return true;
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

  /// Log debug information about admin notifications
  void logDebugInfo(
    int totalNotifications,
    int adminNotifications,
    Map<String, List<NotificationModel>> grouped,
  ) {
    debugPrint('🔍 Admin Notification ViewModel Debug:');
    debugPrint('   Total notifications: $totalNotifications');
    debugPrint('   Admin notifications: $adminNotifications');
    debugPrint('   Check-in/out: ${grouped['checkInOut']?.length ?? 0}');
    debugPrint('   Leave: ${grouped['leave']?.length ?? 0}');
    debugPrint('   Other: ${grouped['other']?.length ?? 0}');
  }
}
