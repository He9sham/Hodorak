import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/models/notification_model.dart';
import 'package:hodorak/core/providers/notification_provider.dart';
import 'package:hodorak/features/notifications_screen/view/widgets/clear_all_dialog.dart';
import 'package:hodorak/features/notifications_screen/view/widgets/empty_notification_state.dart';
import 'package:hodorak/features/notifications_screen/view/widgets/error_notification_state.dart';
import 'package:hodorak/features/notifications_screen/view/widgets/notification_item.dart';

/// User Notification Screen (MVVM Pattern)
/// View: Displays notifications with minimal business logic
class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
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

    return Scaffold(
      appBar: _buildAppBar(context, notificationState, notificationNotifier),
      body: _buildBody(notificationState, notificationNotifier),
    );
  }

  /// Build the app bar with actions
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    NotificationState state,
    NotificationNotifier notifier,
  ) {
    return AppBar(
      actionsIconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xff8C9F5F),
      centerTitle: true,
      title: Text(
        'Notifications',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      actions: [
        if (state.notifications.isNotEmpty)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(context, value, notifier),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    const Icon(Icons.done_all, color: Colors.black87),
                    horizontalSpace(8),
                    const Text('Mark all as read'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep, color: Colors.red),
                    horizontalSpace(8),
                    const Text(
                      'Clear all',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Build the body based on state
  Widget _buildBody(NotificationState state, NotificationNotifier notifier) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state.error != null) {
      return ErrorNotificationState(
        onRetry: () => notifier.loadNotifications(),
      );
    }

    if (state.notifications.isEmpty) {
      return const EmptyNotificationState();
    }

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      child: ListView.builder(
        itemCount: state.notifications.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final notification = state.notifications[index];
          return NotificationItem(
            notification: notification,
            formattedTime: _formatTimeAgo(notification.createdAt),
            onTap: () => _handleNotificationTap(notification, notifier),
            onDelete: () => _handleNotificationDelete(notification, notifier),
          );
        },
      ),
    );
  }

  /// Handle menu actions
  Future<void> _handleMenuAction(
    BuildContext context,
    String action,
    NotificationNotifier notifier,
  ) async {
    if (action == 'mark_all_read') {
      await notifier.markAllAsRead();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (action == 'clear_all') {
      final confirmed = await ClearAllDialog.show(context);
      if (confirmed == true) {
        await notifier.clearAllNotifications();
        if (!context.mounted) return;
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
    if (!mounted) return;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Format time ago (helper method - could be moved to utility)
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
