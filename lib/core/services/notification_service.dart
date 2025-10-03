import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
    );
  }

  /// Show notification to manager when user submits leave request
  Future<void> showManagerLeaveRequestNotification({
    required String username,
  }) async {
    await showNotification(
      id: 2,
      title: 'New Leave Request',
      body: 'User $username has submitted a leave request.',
      payload: 'new_leave_request_for_manager',
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
