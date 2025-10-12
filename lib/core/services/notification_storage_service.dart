import 'dart:convert';

import 'package:hodorak/core/models/notification_model.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationStorageService {
  static final NotificationStorageService _instance =
      NotificationStorageService._internal();
  factory NotificationStorageService() => _instance;
  NotificationStorageService._internal();

  static const String _notificationsKey = 'user_notifications';
  static const int _maxNotifications = 50; // Limit stored notifications

  /// Save a notification to local storage
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      Logger.debug('💾 NotificationStorageService: Saving notification');
      Logger.debug('   ID: ${notification.id}');
      Logger.debug('   Title: ${notification.title}');
      Logger.debug('   Type: ${notification.type}');
      Logger.debug('   UserId: ${notification.userId}');

      final prefs = await SharedPreferences.getInstance();
      final notifications = await getAllNotifications();

      Logger.debug('   Current notifications count: ${notifications.length}');

      // Add new notification at the beginning
      notifications.insert(0, notification);

      // Keep only the latest notifications
      if (notifications.length > _maxNotifications) {
        notifications.removeRange(_maxNotifications, notifications.length);
      }

      // Save to SharedPreferences
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(jsonList));

      Logger.debug('   ✅ Notification saved successfully');
      Logger.debug('   Total notifications now: ${notifications.length}');
    } catch (e) {
      Logger.error('   ❌ Failed to save notification: $e');
      throw Exception('Failed to save notification: $e');
    }
  }

  /// Get all notifications from local storage
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_notificationsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getAllNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      return 0;
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getAllNotifications();

      final updatedNotifications = notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      final jsonList = updatedNotifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(jsonList));
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getAllNotifications();

      final updatedNotifications = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();

      final jsonList = updatedNotifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(jsonList));
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getAllNotifications();

      final updatedNotifications = notifications
          .where((n) => n.id != notificationId)
          .toList();

      final jsonList = updatedNotifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(jsonList));
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
    } catch (e) {
      throw Exception('Failed to clear notifications: $e');
    }
  }

  /// Get notifications by type
  Future<List<NotificationModel>> getNotificationsByType(
    NotificationType type,
  ) async {
    try {
      final notifications = await getAllNotifications();
      return notifications.where((n) => n.type == type).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get notifications for a specific user
  Future<List<NotificationModel>> getNotificationsByUserId(
    String userId,
  ) async {
    try {
      final notifications = await getAllNotifications();
      return notifications.where((n) => n.userId == userId).toList();
    } catch (e) {
      return [];
    }
  }
}
