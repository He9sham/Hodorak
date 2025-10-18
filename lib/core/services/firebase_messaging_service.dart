import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hodorak/core/models/notification_model.dart';
import 'package:hodorak/core/services/notification_memory_service.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

/// Top-level function for handling background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger.debug('Handling a background message: ${message.messageId}');
  Logger.debug('Message data: ${message.data}');
  Logger.debug('Message notification: ${message.notification?.title}');
}

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationMemoryService _memoryService = NotificationMemoryService();
  final Uuid _uuid = const Uuid();

  bool _isInitialized = false;
  String? _fcmToken;

  // Callback to refresh notifications in UI
  void Function()? onNotificationReceived;

  /// Get the FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission for iOS and web
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      Logger.info('User granted permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        Logger.info('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        Logger.info('User granted provisional permission');
      } else {
        Logger.warning('User declined or has not accepted permission');
      }

      // Get the FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      Logger.info('FCM Token: $_fcmToken');

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        Logger.info('FCM Token refreshed: $newToken');
      });

      // Configure foreground notification presentation options for iOS
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle when user taps on notification (app in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Check if app was opened from a terminated state
      RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      // Set the background messaging handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      _isInitialized = true;
      Logger.info('Firebase Messaging initialized successfully');
    } catch (e) {
      Logger.error('Error initializing Firebase Messaging: $e');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    Logger.debug('Got a message whilst in the foreground!');
    Logger.debug('Message data: ${message.data}');

    if (message.notification != null) {
      Logger.debug(
        'Message also contained a notification: ${message.notification}',
      );

      // Save notification to storage
      _saveNotificationToStorage(
        title: message.notification!.title ?? 'Notification',
        body: message.notification!.body ?? '',
        type: _getNotificationTypeFromData(message.data),
        payload: message.data['payload'],
        userId: message.data['userId'],
      );

      // Show in-app notification banner
      _showInAppNotification(
        message.notification!.title ?? 'Notification',
        message.notification!.body ?? '',
      );
    }
  }

  /// Handle when user taps on notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    Logger.debug('Message clicked!');
    Logger.debug('Message data: ${message.data}');
    // You can use a navigation service or global key for this
  }

  /// Send a notification via FCM data message
  /// Note: This requires a backend server to send FCM messages
  /// This method prepares the notification data for storage
  Future<void> sendNotification({
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.general,
    String? userId,
    bool showInApp = true,
  }) async {
    // Save notification to storage
    await _saveNotificationToStorage(
      title: title,
      body: body,
      type: type,
      payload: payload,
      userId: userId,
    );

    // Show in-app notification if requested
    if (showInApp) {
      _showInAppNotification(title, body);
    }

    Logger.debug('Notification saved: $title - $body');
    Logger.warning(
      '⚠️  Note: To send push notifications to other devices, you need a backend server!',
    );
    Logger.info('📱 FCM Token: $_fcmToken');
    // Note: Actual FCM push notification must be sent from your backend server
    // using the FCM token and Firebase Admin SDK
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
      Logger.debug('📤 Saving Notification to Storage:');
      Logger.debug('   Title: $title');
      Logger.debug('   Body: $body');
      Logger.debug('   Type: $type');
      Logger.debug(
        '   UserId: $userId ${userId == null ? "(for ALL admins)" : ""}',
      );
      Logger.debug('   Payload: $payload');

      // Check if this notification should be saved for the current user
      if (!_shouldSaveNotification(type, userId)) {
        Logger.debug(
          '❌ Notification filtered out (not relevant for current user): $title',
        );
        return;
      }

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

      await _memoryService.saveNotification(notification);

      Logger.debug('✅ Notification saved to memory successfully');
      Logger.debug('   Notification ID: ${notification.id}');
      Logger.debug('   UserId in model: ${notification.userId}');

      // Notify listeners that a new notification was saved
      onNotificationReceived?.call();

      Logger.debug('✅ UI listeners notified');
    } catch (e) {
      Logger.error('❌ Failed to save notification to storage: $e');
    }
  }

  /// Check if notification should be saved for current user
  bool _shouldSaveNotification(NotificationType type, String? targetUserId) {
    // For now, save all notifications locally
    // The filtering will happen in the UI layer based on user role
    return true;
  }

  /// Get notification type from message data
  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final typeString = data['type'] as String?;

    switch (typeString) {
      case 'leave_request_submitted':
        return NotificationType.leaveRequestSubmitted;
      case 'new_leave_request':
        return NotificationType.newLeaveRequest;
      case 'leave_request_approved':
        return NotificationType.leaveRequestApproved;
      case 'leave_request_rejected':
        return NotificationType.leaveRequestRejected;
      case 'check_in':
        return NotificationType.checkIn;
      case 'check_out':
        return NotificationType.checkOut;
      case 'attendance':
        return NotificationType.attendance;
      default:
        return NotificationType.general;
    }
  }

  /// Show in-app notification banner
  void _showInAppNotification(String title, String body) {
    // Note: This will only work if you have a GlobalKey<NavigatorState> set up
    // For now, we just log it
    Logger.debug('📬 IN-APP NOTIFICATION: $title - $body');
    // final context = navigatorKey.currentContext;
    // if (context != null && context.mounted) {
    //   showSimpleNotification(
    //     Text(title),
    //     subtitle: Text(body),
    //     background: const Color(0xff8C9F5F),
    //   );
    // }
  }

  /// Show notification when user submits leave request
  Future<void> showLeaveRequestSubmittedNotification({
    required String userId,
  }) async {
    await sendNotification(
      title: 'Leave Request Sent',
      body: 'Your leave request has been sent to the manager.',
      payload: 'leave_request_submitted',
      type: NotificationType.leaveRequestSubmitted,
      userId: userId,
    );
  }

  /// Show notification to manager when user submits leave request
  /// Note: This only saves locally. For real cross-device notifications, you need a backend server.
  Future<void> showManagerLeaveRequestNotification({
    required String username,
    String? managerId,
    bool saveLocally = true, // Save locally by default for demo purposes
  }) async {
    if (saveLocally) {
      await sendNotification(
        title: 'New Leave Request',
        body: '$username has submitted a leave request',
        payload: 'new_leave_request_for_manager',
        type: NotificationType.newLeaveRequest,
        userId: null, // null userId indicates it's for all admins
      );

      Logger.debug('📢 MANAGER NOTIFICATION SAVED:');
      Logger.debug('   Title: New Leave Request');
      Logger.debug('   Body: $username has submitted a leave request');
      Logger.debug('   Type: NotificationType.newLeaveRequest');
      Logger.debug('   UserId: null (for all admins)');
      Logger.debug('   Target: All Admins (local)');
    } else {
      // Just log that a notification would be sent to managers
      Logger.debug('📢 MANAGER NOTIFICATION (would be sent via backend):');
      Logger.debug('   Title: New Leave Request');
      Logger.debug('   Body: $username has submitted a leave request');
      Logger.debug('   Target: Managers');
      Logger.warning(
        '   ⚠️  This notification needs a backend server to reach managers!',
      );
    }
  }

  /// Show notification when leave request is approved
  Future<void> showLeaveRequestApprovedNotification({
    required String userId,
  }) async {
    await sendNotification(
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
    await sendNotification(
      title: 'Leave Request Rejected',
      body: 'Your leave request has been rejected.',
      payload: 'leave_request_rejected',
      type: NotificationType.leaveRequestRejected,
      userId: userId,
    );
  }

  /// Show notification when user checks in
  Future<void> showCheckInNotification({
    required String userId,
    required String username,
    String? location,
  }) async {
    // Notification for the user
    await sendNotification(
      title: 'Check In Successful',
      body: location != null
          ? 'You have checked in successfully at $location'
          : 'You have checked in successfully',
      payload: 'check_in',
      type: NotificationType.checkIn,
      userId: userId,
    );

    // Notification for admin (saved locally, but marked for admin view)
    await sendNotification(
      title: 'Employee Check In',
      body: location != null
          ? '$username checked in at $location'
          : '$username checked in',
      payload: 'check_in_admin',
      type: NotificationType.checkIn,
      userId: null, // null userId indicates it's for all admins
    );
  }

  /// Show notification when user checks out
  Future<void> showCheckOutNotification({
    required String userId,
    required String username,
    String? location,
  }) async {
    // Notification for the user
    await sendNotification(
      title: 'Check Out Successful',
      body: location != null
          ? 'You have checked out successfully at $location'
          : 'You have checked out successfully',
      payload: 'check_out',
      type: NotificationType.checkOut,
      userId: userId,
    );

    // Notification for admin (saved locally, but marked for admin view)
    await sendNotification(
      title: 'Employee Check Out',
      body: location != null
          ? '$username checked out at $location'
          : '$username checked out',
      payload: 'check_out_admin',
      type: NotificationType.checkOut,
      userId: null, // null userId indicates it's for all admins
    );
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      Logger.info('Subscribed to topic: $topic');
    } catch (e) {
      Logger.error('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      Logger.info('Unsubscribed from topic: $topic');
    } catch (e) {
      Logger.error('Error unsubscribing from topic: $e');
    }
  }

  /// Delete the FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      Logger.info('FCM token deleted');
    } catch (e) {
      Logger.error('Error deleting FCM token: $e');
    }
  }
}
