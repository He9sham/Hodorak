import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/notification_model.dart';
import 'package:hodorak/core/services/firebase_messaging_service.dart';
import 'package:hodorak/core/services/notification_storage_service.dart';
import 'package:hodorak/core/services/supabase_auth_service.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  final NotificationStorageService _storageService;
  final FirebaseMessagingService _messagingService;
  final SupabaseAuthService _authService;

  NotificationNotifier(
    this._storageService,
    this._messagingService,
    this._authService,
  );

  @override
  NotificationState build() {
    // Set up listener for new notifications from FCM
    _messagingService.onNotificationReceived = () {
      loadNotifications();
    };

    // Initialize notifications when provider is created
    loadNotifications();
    return const NotificationState();
  }

  /// Load all notifications from storage with user role filtering
  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final allNotifications = await _storageService.getAllNotifications();

      // Filter notifications based on current user's role
      final filteredNotifications = await _filterNotificationsByUserRole(
        allNotifications,
      );

      final unreadCount = filteredNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: filteredNotifications,
        isLoading: false,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Filter notifications based on current user's role
  Future<List<NotificationModel>> _filterNotificationsByUserRole(
    List<NotificationModel> notifications,
  ) async {
    try {
      debugPrint(
        '🔍 Filtering ${notifications.length} notifications by user role',
      );

      // Check if auth service is available
      if (_authService.currentUser == null) {
        debugPrint('Auth service not initialized, showing all notifications');
        return notifications;
      }

      // Check if current user is admin/manager
      final isAdmin = await _authService.isAdmin();
      final currentUserId = _authService.currentUser?.id;

      debugPrint('   Current user: $currentUserId');
      debugPrint('   Is admin: $isAdmin');

      final filteredNotifications = notifications.where((notification) {
        // Show notifications based on type and user role
        bool shouldShow;

        // Special handling for notifications with null userId (broadcast to all admins)
        if (notification.userId == null) {
          // Notifications with null userId are meant for all admins
          shouldShow = isAdmin;
          debugPrint(
            '   ${notification.type} (${notification.title}): $shouldShow [null userId, isAdmin: $isAdmin]',
          );
          return shouldShow;
        }

        switch (notification.type) {
          case NotificationType.leaveRequestSubmitted:
          case NotificationType.leaveRequestApproved:
          case NotificationType.leaveRequestRejected:
            shouldShow = isAdmin || notification.userId == currentUserId;
            break;

          case NotificationType.newLeaveRequest:
            // newLeaveRequest with specific userId (rare case)
            shouldShow = isAdmin || notification.userId == currentUserId;
            break;

          case NotificationType.checkIn:
          case NotificationType.checkOut:
            shouldShow = isAdmin || notification.userId == currentUserId;
            break;

          case NotificationType.attendance:
          case NotificationType.general:
            shouldShow = true;
            break;
        }

        debugPrint(
          '   ${notification.type} (${notification.title}): $shouldShow [userId: ${notification.userId}, currentUserId: $currentUserId]',
        );
        return shouldShow;
      }).toList();

      debugPrint('   Filtered notifications: ${filteredNotifications.length}');
      return filteredNotifications;
    } catch (e) {
      debugPrint('Error filtering notifications by role: $e');
      // If filtering fails, return all notifications
      return notifications;
    }
  }

  /// Add a new notification
  Future<void> addNotification(NotificationModel notification) async {
    try {
      await _storageService.saveNotification(notification);
      await loadNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _storageService.markAsRead(notificationId);
      await loadNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _storageService.markAllAsRead();
      await loadNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _storageService.deleteNotification(notificationId);
      await loadNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _storageService.clearAllNotifications();
      await loadNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return state.notifications.where((n) => !n.isRead).toList();
  }

  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return state.notifications.where((n) => n.type == type).toList();
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await loadNotifications();
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(() {
      return NotificationNotifier(
        NotificationStorageService(),
        FirebaseMessagingService(),
        SupabaseAuthService(),
      );
    });

/// Provider for unread count (computed)
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationState = ref.watch(notificationProvider);
  return notificationState.unreadCount;
});
