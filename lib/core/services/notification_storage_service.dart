import 'package:hodorak/core/models/notification_model.dart';
import 'package:hodorak/core/utils/logger.dart';

/// DEPRECATED: NotificationStorageService
/// This service is deprecated. Notifications are no longer stored locally.
/// Use NotificationMemoryService instead for in-memory only notifications.
@Deprecated('Use NotificationMemoryService instead. Local storage is disabled.')
class NotificationStorageService {
  static final NotificationStorageService _instance =
      NotificationStorageService._internal();
  factory NotificationStorageService() => _instance;
  NotificationStorageService._internal();

  /// Save a notification to local storage (DISABLED)
  @Deprecated('Local notification storage is disabled')
  Future<void> saveNotification(NotificationModel notification) async {
    Logger.info(
      '📱 Notification received (not stored locally): ${notification.title}',
    );
    // Do nothing - notifications are not stored locally anymore
  }

  /// Get all notifications from local storage (DISABLED)
  @Deprecated('Local notification storage is disabled')
  Future<List<NotificationModel>> getAllNotifications() async {
    Logger.debug('📱 No local notifications - returning empty list');
    return [];
  }

  /// Get unread notifications count (DISABLED)
  @Deprecated('Local notification storage is disabled')
  Future<int> getUnreadCount() async {
    return 0;
  }

  /// Mark a notification as read (DISABLED)
  @Deprecated('Local notification storage is disabled')
  Future<void> markAsRead(String notificationId) async {
    Logger.debug('📱 Mark as read disabled - no local storage');
  }

  /// Mark all notifications as read (DISABLED)
  @Deprecated('Local notification storage is disabled')
  Future<void> markAllAsRead() async {
    Logger.debug('📱 Mark all as read disabled - no local storage');
  }

  /// Clear all notifications (DISABLED)
  @Deprecated('Local notification storage is disabled')
  Future<void> clearAllNotifications() async {
    Logger.debug('📱 Clear all notifications disabled - no local storage');
  }

  /// Delete a specific notification (DISABLED)
  @Deprecated('Local notification storage is disabled')
  Future<void> deleteNotification(String notificationId) async {
    Logger.debug('📱 Delete notification disabled - no local storage');
  }
}
