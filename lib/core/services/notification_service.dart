import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hodorak/core/models/notification_model.dart';
import 'package:hodorak/core/services/notification_storage_service.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final NotificationStorageService _storageService =
      NotificationStorageService();
  final Uuid _uuid = const Uuid();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _requestAndroidPermissions();
    }

    _isInitialized = true;
  }

  /// Request Android notification permissions
  Future<void> _requestAndroidPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.requestNotificationsPermission();
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap if needed
    debugPrint('Notification tapped: ${notificationResponse.payload}');
  }

  /// Ensure the service is initialized before showing notifications
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Show a simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.general,
    String? userId,
  }) async {
    await _ensureInitialized();
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'leave_requests_channel',
          'Leave Requests Notifications',
          channelDescription: 'Notifications for leave request updates',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    // Save notification to storage
    await _saveNotificationToStorage(
      title: title,
      body: body,
      type: type,
      payload: payload,
      userId: userId,
    );
  }

  /// Save notification to local storage
  Future<void> _saveNotificationToStorage({
    required String title,
    required String body,
    required NotificationType type,
    String? payload,
    String? userId,
  }) async {
    try {
      final notification = NotificationModel(
        id: _uuid.v4(),
        title: title,
        body: body,
        type: type,
        payload: payload,
        createdAt: DateTime.now(),
        isRead: false,
        userId: userId,
      );

      await _storageService.saveNotification(notification);
    } catch (e) {
      debugPrint('Failed to save notification to storage: $e');
    }
  }

  /// Show notification when user submits leave request
  Future<void> showLeaveRequestSubmittedNotification({
    required String userId,
  }) async {
    await showNotification(
      id: 1,
      title: 'Leave Request Sent',
      body: 'Your leave request has been sent to the manager.',
      payload: 'leave_request_submitted',
      type: NotificationType.leaveRequestSubmitted,
      userId: userId,
    );
  }

  /// Show notification to manager when user submits leave request
  Future<void> showManagerLeaveRequestNotification({
    required String username,
    String? managerId,
  }) async {
    await showNotification(
      id: 2,
      title: 'New Leave Request',
      body: 'User $username has submitted a leave request.',
      payload: 'new_leave_request_for_manager',
      type: NotificationType.newLeaveRequest,
      userId: managerId,
    );
  }

  /// Show notification when leave request is approved
  Future<void> showLeaveRequestApprovedNotification({
    required String userId,
  }) async {
    await showNotification(
      id: 3,
      title: 'Leave Request Approved',
      body: 'Your leave request has been approved.',
      payload: 'leave_request_approved',
      type: NotificationType.leaveRequestApproved,
      userId: userId,
    );
  }

  /// Show notification when leave request is rejected
  Future<void> showLeaveRequestRejectedNotification({
    required String userId,
  }) async {
    await showNotification(
      id: 4,
      title: 'Leave Request Rejected',
      body: 'Your leave request has been rejected.',
      payload: 'leave_request_rejected',
      type: NotificationType.leaveRequestRejected,
      userId: userId,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
