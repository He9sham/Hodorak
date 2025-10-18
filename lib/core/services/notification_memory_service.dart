import 'package:hodorak/core/models/notification_model.dart';
import 'package:hodorak/core/utils/logger.dart';

/// In-memory notification service
/// Notifications are only stored in memory and disappear when app is closed
class NotificationMemoryService {
  static final NotificationMemoryService _instance =
      NotificationMemoryService._internal();
  factory NotificationMemoryService() => _instance;
  NotificationMemoryService._internal();

  final List<NotificationModel> _notifications = [];
  static const int _maxNotifications = 20; // Limit in-memory notifications

  /// Save a notification to memory only
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      Logger.debug(
        '📱 NotificationMemoryService: Saving notification to memory',
      );
      Logger.debug('   ID: ${notification.id}');
      Logger.debug('   Title: ${notification.title}');
      Logger.debug('   Type: ${notification.type}');

      // Add new notification at the beginning
      _notifications.insert(0, notification);

      // Keep only the latest notifications
      if (_notifications.length > _maxNotifications) {
        _notifications.removeRange(_maxNotifications, _notifications.length);
      }

      Logger.debug('   ✅ Notification saved to memory successfully');
      Logger.debug(
        '   Total notifications in memory: ${_notifications.length}',
      );
    } catch (e) {
      Logger.error('   ❌ Failed to save notification to memory: $e');
      throw Exception('Failed to save notification to memory: $e');
    }
  }

  /// Get all notifications from memory
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      Logger.debug(
        '📱 NotificationMemoryService: ${_notifications.length} notifications from memory',
      );
      return List.from(_notifications);
    } catch (e) {
      Logger.error('❌ Failed to get notifications from memory: $e');
      return [];
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final unreadCount = _notifications.where((n) => !n.isRead).length;
      Logger.debug(
        '📱 NotificationMemoryService: ${unreadCount} unread notifications',
      );
      return unreadCount;
    } catch (e) {
      Logger.error('❌ Failed to get unread count: $e');
      return 0;
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      Logger.debug(
        '📱 NotificationMemoryService: Marking notification $notificationId as read',
      );

      for (int i = 0; i < _notifications.length; i++) {
        if (_notifications[i].id == notificationId) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
          Logger.debug('   ✅ Notification marked as read');
          return;
        }
      }

      Logger.debug('   ⚠️ Notification not found: $notificationId');
    } catch (e) {
      Logger.error('❌ Failed to mark notification as read: $e');
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      Logger.debug(
        '📱 NotificationMemoryService: Marking all notifications as read',
      );

      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }

      Logger.debug('   ✅ All notifications marked as read');
    } catch (e) {
      Logger.error('❌ Failed to mark all notifications as read: $e');
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Clear all notifications from memory
  Future<void> clearAllNotifications() async {
    try {
      Logger.debug(
        '📱 NotificationMemoryService: Clearing all notifications from memory',
      );
      _notifications.clear();
      Logger.debug('   ✅ All notifications cleared from memory');
    } catch (e) {
      Logger.error('❌ Failed to clear all notifications: $e');
      throw Exception('Failed to clear all notifications: $e');
    }
  }

  /// Delete a specific notification from memory
  Future<void> deleteNotification(String notificationId) async {
    try {
      Logger.debug(
        '📱 NotificationMemoryService: Deleting notification $notificationId from memory',
      );

      _notifications.removeWhere(
        (notification) => notification.id == notificationId,
      );

      Logger.debug('   ✅ Notification deleted from memory');
    } catch (e) {
      Logger.error('❌ Failed to delete notification: $e');
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Get current notification count
  int get notificationCount => _notifications.length;

  /// Check if there are any notifications
  bool get hasNotifications => _notifications.isNotEmpty;

  /// Clear all data (useful for testing)
  void clearAllData() {
    _notifications.clear();
    Logger.debug('📱 NotificationMemoryService: All data cleared');
  }
}
