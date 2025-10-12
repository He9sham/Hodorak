import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/models/notification_model.dart';
import 'package:hodorak/core/providers/notification_provider.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:hodorak/features/notifications_screen/models/notification_filter.dart';
import 'package:hodorak/features/notifications_screen/utils/notification_formatter.dart';
import 'package:hodorak/features/notifications_screen/view/widgets/admin_notification_item.dart';
import 'package:hodorak/features/notifications_screen/view/widgets/clear_all_dialog.dart';
import 'package:hodorak/features/notifications_screen/view/widgets/empty_notification_state.dart';
import 'package:hodorak/features/notifications_screen/view/widgets/section_header.dart';

/// Admin Notification Screen (MVVM Pattern)
/// View: Displays admin notifications with filtering and grouping
class AdminNotificationScreen extends ConsumerStatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  ConsumerState<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState
    extends ConsumerState<AdminNotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize by loading notifications on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the notification state from provider
    final notificationState = ref.watch(notificationProvider);
    final notificationNotifier = ref.read(notificationProvider.notifier);

    // Filter to show only admin notifications
    final adminNotifications = notificationState.notifications
        .where(NotificationFilter.isAdminNotification)
        .toList();

    // Group notifications by category
    final grouped = NotificationFilter.groupNotifications(adminNotifications);

    // Debug logging
    Logger.debug('🔍 Admin Notification Screen Debug:');
    Logger.debug(
      '   Total notifications: ${notificationState.notifications.length}',
    );
    Logger.debug('   Admin notifications: ${adminNotifications.length}');
    Logger.debug('   Check-in/out: ${grouped['checkInOut']?.length}');
    Logger.debug('   Leave: ${grouped['leave']?.length}');
    Logger.debug('   Other: ${grouped['other']?.length}');

    return Scaffold(
      appBar: _buildAppBar(adminNotifications, notificationNotifier),
      body: _buildBody(
        notificationState,
        adminNotifications,
        grouped,
        notificationNotifier,
      ),
    );
  }

  /// Build the app bar with actions
  PreferredSizeWidget _buildAppBar(
    List adminNotifications,
    NotificationNotifier notifier,
  ) {
    return AppBar(
      backgroundColor: const Color(0xff8C9F5F),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        'Admin Notifications',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      actions: [
        if (adminNotifications.isNotEmpty)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(value, notifier),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all, size: 20.sp),
                    horizontalSpace(8),
                    const Text('Mark all as read'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20.sp),
                    horizontalSpace(8),
                    const Text('Clear all'),
                  ],
                ),
              ),
            ],
          ),
        horizontalSpace(8),
      ],
    );
  }

  /// Build the body based on state
  Widget _buildBody(
    NotificationState state,
    List adminNotifications,
    Map<String, List> grouped,
    NotificationNotifier notifier,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (adminNotifications.isEmpty) {
      return const EmptyNotificationState(
        message: 'No notifications yet',
        subtitle: 'Admin notifications will appear here',
        icon: Icons.notifications_off,
      );
    }

    final checkInOutNotifications = grouped['checkInOut'] ?? [];
    final leaveNotifications = grouped['leave'] ?? [];
    final otherNotifications = grouped['other'] ?? [];

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        children: [
          // Check-In/Out Section
          if (checkInOutNotifications.isNotEmpty) ...[
            SectionHeader(
              title: 'Attendance Activities',
              count: checkInOutNotifications.length,
              icon: Icons.access_time,
            ),
            ...checkInOutNotifications.map(
              (notification) => AdminNotificationItem(
                notification: notification,
                formattedTime: NotificationFormatter.formatTimeAgo(
                  notification.createdAt,
                ),
                formattedBody:
                    NotificationFormatter.formatNotificationBodyForAdmin(
                      notification,
                    ),
                onTap: () => _handleNotificationTap(notification, notifier),
                onDelete: () =>
                    _handleNotificationDelete(notification, notifier),
              ),
            ),
            verticalSpace(32),
          ],

          // Leave Requests Section
          if (leaveNotifications.isNotEmpty) ...[
            SectionHeader(
              title: 'Leave Requests',
              count: leaveNotifications.length,
              icon: Icons.event_note,
            ),
            ...leaveNotifications.map(
              (notification) => AdminNotificationItem(
                notification: notification,
                formattedTime: NotificationFormatter.formatTimeAgo(
                  notification.createdAt,
                ),
                formattedBody:
                    NotificationFormatter.formatNotificationBodyForAdmin(
                      notification,
                    ),
                onTap: () => _handleNotificationTap(notification, notifier),
                onDelete: () =>
                    _handleNotificationDelete(notification, notifier),
              ),
            ),
            Divider(height: 32.h),
          ],

          // Other Notifications Section
          if (otherNotifications.isNotEmpty) ...[
            SectionHeader(
              title: 'Other Notifications',
              count: otherNotifications.length,
              icon: Icons.notifications,
            ),
            ...otherNotifications.map(
              (notification) => AdminNotificationItem(
                notification: notification,
                formattedTime: NotificationFormatter.formatTimeAgo(
                  notification.createdAt,
                ),
                formattedBody:
                    NotificationFormatter.formatNotificationBodyForAdmin(
                      notification,
                    ),
                onTap: () => _handleNotificationTap(notification, notifier),
                onDelete: () =>
                    _handleNotificationDelete(notification, notifier),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Handle menu actions
  Future<void> _handleMenuAction(
    String action,
    NotificationNotifier notifier,
  ) async {
    if (action == 'mark_all_read') {
      await notifier.markAllAsRead();
    } else if (action == 'clear_all') {
      final confirmed = await ClearAllDialog.show(context);
      if (confirmed == true) {
        await notifier.clearAllNotifications();
        if (!context.mounted) return;
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cleared'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Handle notification tap
  Future<void> _handleNotificationTap(
    NotificationModel notification,
    NotificationNotifier notifier,
  ) async {
    if (!notification.isRead) {
      await notifier.markAsRead(notification.id);
    }
  }

  /// Handle notification delete
  Future<void> _handleNotificationDelete(
    NotificationModel notification,
    NotificationNotifier notifier,
  ) async {
    await notifier.deleteNotification(notification.id);
  }
}
