import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_model.dart';
import '../supabase/supabase_service.dart';
import '../utils/logger.dart';
import '../utils/uuid_generator.dart';

class SupabaseNotificationService {
  final SupabaseClient _client = SupabaseService.client;

  /// Save notification to Supabase (cross-device)
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      Logger.debug(
        '📱 SupabaseNotificationService: Saving notification to Supabase',
      );
      Logger.debug('   ID: ${notification.id}');
      Logger.debug('   Title: ${notification.title}');
      Logger.debug('   Type: ${notification.type}');
      Logger.debug('   UserId: ${notification.userId}');

      final notificationData = {
        'id': notification.id,
        'user_id': notification.userId,
        'title': notification.title,
        'body': notification.body,
        'type': notification.type.toString(),
        'payload': notification.payload,
        'is_read': notification.isRead,
        'created_at': notification.createdAt.toIso8601String(),
      };

      await _client.from('notifications').insert(notificationData);

      Logger.debug('   ✅ Notification saved to Supabase successfully');
    } catch (e) {
      Logger.error('   ❌ Failed to save notification to Supabase: $e');
      throw Exception('Failed to save notification to Supabase: $e');
    }
  }

  /// Get notifications for current user from Supabase
  Future<List<NotificationModel>> getNotifications() async {
    try {
      Logger.debug(
        '📱 SupabaseNotificationService: Getting notifications from Supabase',
      );

      final response = await _client
          .from('notifications')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      final notifications = (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      Logger.debug(
        '   ✅ Retrieved ${notifications.length} notifications from Supabase',
      );
      return notifications;
    } catch (e) {
      Logger.error('❌ Failed to get notifications from Supabase: $e');
      return [];
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('is_read', false);

      final count = (response as List).length;
      Logger.debug(
        '📱 SupabaseNotificationService: $count unread notifications',
      );
      return count;
    } catch (e) {
      Logger.error('❌ Failed to get unread count from Supabase: $e');
      return 0;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      Logger.debug(
        '📱 SupabaseNotificationService: Marking notification $notificationId as read',
      );

      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      Logger.debug('   ✅ Notification marked as read in Supabase');
    } catch (e) {
      Logger.error('❌ Failed to mark notification as read in Supabase: $e');
      throw Exception('Failed to mark notification as read in Supabase: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      Logger.debug(
        '📱 SupabaseNotificationService: Marking all notifications as read',
      );

      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('is_read', false);

      Logger.debug('   ✅ All notifications marked as read in Supabase');
    } catch (e) {
      Logger.error(
        '❌ Failed to mark all notifications as read in Supabase: $e',
      );
      throw Exception(
        'Failed to mark all notifications as read in Supabase: $e',
      );
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      Logger.debug(
        '📱 SupabaseNotificationService: Deleting notification $notificationId',
      );

      await _client.from('notifications').delete().eq('id', notificationId);

      Logger.debug('   ✅ Notification deleted from Supabase');
    } catch (e) {
      Logger.error('❌ Failed to delete notification from Supabase: $e');
      throw Exception('Failed to delete notification from Supabase: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      Logger.debug(
        '📱 SupabaseNotificationService: Clearing all notifications',
      );

      await _client
          .from('notifications')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000'); // Delete all

      Logger.debug('   ✅ All notifications cleared from Supabase');
    } catch (e) {
      Logger.error('❌ Failed to clear all notifications from Supabase: $e');
      throw Exception('Failed to clear all notifications from Supabase: $e');
    }
  }

  /// Send check-in notification to user and admin
  Future<void> sendCheckInNotification({
    required String userId,
    required String username,
    String? location,
  }) async {
    try {
      // Notification for the user
      final userNotification = NotificationModel(
        id: UuidGenerator.generateUuid(),
        title: 'Check In Successful',
        body: location != null
            ? 'You have checked in successfully at $location'
            : 'You have checked in successfully',
        payload: 'check_in',
        type: NotificationType.checkIn,
        createdAt: DateTime.now(),
        isRead: false,
        userId: userId,
      );

      await saveNotification(userNotification);

      // Notification for admin (userId = null means for all admins)
      final adminNotification = NotificationModel(
        id: UuidGenerator.generateUuid(),
        title: 'Employee Check In',
        body: location != null
            ? '$username checked in at $location'
            : '$username checked in',
        payload: 'check_in_admin',
        type: NotificationType.checkIn,
        createdAt: DateTime.now(),
        isRead: false,
        userId: null, // null userId indicates it's for all admins
      );

      await saveNotification(adminNotification);

      Logger.info('✅ Check-in notifications sent to user and admin');
    } catch (e) {
      Logger.error('❌ Failed to send check-in notifications: $e');
      rethrow;
    }
  }

  /// Send check-out notification to user and admin
  Future<void> sendCheckOutNotification({
    required String userId,
    required String username,
    String? location,
  }) async {
    try {
      // Notification for the user
      final userNotification = NotificationModel(
        id: UuidGenerator.generateUuid(),
        title: 'Check Out Successful',
        body: location != null
            ? 'You have checked out successfully at $location'
            : 'You have checked out successfully',
        payload: 'check_out',
        type: NotificationType.checkOut,
        createdAt: DateTime.now(),
        isRead: false,
        userId: userId,
      );

      await saveNotification(userNotification);

      // Notification for admin (userId = null means for all admins)
      final adminNotification = NotificationModel(
        id: UuidGenerator.generateUuid(),
        title: 'Employee Check Out',
        body: location != null
            ? '$username checked out at $location'
            : '$username checked out',
        payload: 'check_out_admin',
        type: NotificationType.checkOut,
        createdAt: DateTime.now(),
        isRead: false,
        userId: null, // null userId indicates it's for all admins
      );

      await saveNotification(adminNotification);

      Logger.info('✅ Check-out notifications sent to user and admin');
    } catch (e) {
      Logger.error('❌ Failed to send check-out notifications: $e');
      rethrow;
    }
  }
}
