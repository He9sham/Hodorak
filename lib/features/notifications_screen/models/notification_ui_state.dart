import 'package:hodorak/core/models/notification_model.dart';

/// UI State for notification screens
class NotificationUiState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const NotificationUiState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationUiState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationUiState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  bool get hasNotifications => notifications.isNotEmpty;
  bool get hasError => error != null;
}

/// UI State specifically for admin notifications with grouped data
class AdminNotificationUiState extends NotificationUiState {
  final List<NotificationModel> checkInOutNotifications;
  final List<NotificationModel> leaveNotifications;
  final List<NotificationModel> otherNotifications;

  const AdminNotificationUiState({
    super.notifications,
    super.isLoading,
    super.error,
    super.unreadCount,
    this.checkInOutNotifications = const [],
    this.leaveNotifications = const [],
    this.otherNotifications = const [],
  });

  @override
  AdminNotificationUiState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
    List<NotificationModel>? checkInOutNotifications,
    List<NotificationModel>? leaveNotifications,
    List<NotificationModel>? otherNotifications,
  }) {
    return AdminNotificationUiState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      unreadCount: unreadCount ?? this.unreadCount,
      checkInOutNotifications:
          checkInOutNotifications ?? this.checkInOutNotifications,
      leaveNotifications: leaveNotifications ?? this.leaveNotifications,
      otherNotifications: otherNotifications ?? this.otherNotifications,
    );
  }

  bool get hasCheckInOutNotifications => checkInOutNotifications.isNotEmpty;
  bool get hasLeaveNotifications => leaveNotifications.isNotEmpty;
  bool get hasOtherNotifications => otherNotifications.isNotEmpty;
}
