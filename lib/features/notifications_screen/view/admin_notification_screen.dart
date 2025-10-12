import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/models/notification_model.dart';
import 'package:hodorak/core/providers/notification_provider.dart';
import 'package:intl/intl.dart';

/// Admin Notifications Screen
/// Shows all notifications including check-in/out activities from all employees
class AdminNotificationScreen extends ConsumerWidget {
  const AdminNotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    final notificationNotifier = ref.read(notificationProvider.notifier);

    // Debug logging
    debugPrint('🔍 Admin Notification Screen Debug:');
    debugPrint(
      '   Total notifications: ${notificationState.notifications.length}',
    );
    debugPrint('   Loading: ${notificationState.isLoading}');
    debugPrint('   Error: ${notificationState.error}');

    // Filter to show only admin notifications
    final adminNotifications = notificationState.notifications
        .where((n) => _isAdminNotification(n))
        .toList();

    debugPrint('   Admin notifications: ${adminNotifications.length}');
    for (var notification in adminNotifications) {
      debugPrint('     - ${notification.type}: ${notification.title}');
    }

    // Group admin notifications by type for better organization
    final checkInOutNotifications = adminNotifications
        .where(
          (n) =>
              n.type == NotificationType.checkIn ||
              n.type == NotificationType.checkOut,
        )
        .toList();

    final leaveNotifications = adminNotifications
        .where(
          (n) =>
              n.type == NotificationType.newLeaveRequest ||
              n.type == NotificationType.leaveRequestApproved ||
              n.type == NotificationType.leaveRequestRejected,
        )
        .toList();

    final otherNotifications = adminNotifications
        .where(
          (n) =>
              n.type != NotificationType.checkIn &&
              n.type != NotificationType.checkOut &&
              n.type != NotificationType.leaveRequestSubmitted &&
              n.type != NotificationType.newLeaveRequest &&
              n.type != NotificationType.leaveRequestApproved &&
              n.type != NotificationType.leaveRequestRejected,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
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
              onSelected: (value) async {
                if (value == 'mark_all_read') {
                  await notificationNotifier.markAllAsRead();
                } else if (value == 'clear_all') {
                  final confirmed = await _showClearAllDialog(
                    context,
                    notificationNotifier,
                  );
                  if (confirmed == true) {
                    await notificationNotifier.clearAllNotifications();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notifications cleared'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, size: 20.sp),
                      horizontalSpace(8),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, size: 20.sp),
                      horizontalSpace(8),
                      Text('Clear all'),
                    ],
                  ),
                ),
              ],
            ),
          horizontalSpace(8),
        ],
      ),
      body: notificationState.isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : adminNotifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  verticalSpace(16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  verticalSpace(8),
                  Text(
                    'Admin notifications will appear here',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => notificationNotifier.refresh(),
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                children: [
                  // Check-In/Out Section
                  if (checkInOutNotifications.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Attendance Activities',
                      count: checkInOutNotifications.length,
                      icon: Icons.access_time,
                    ),
                    ...checkInOutNotifications.map(
                      (notification) => _AdminNotificationItem(
                        notification: notification,
                        onTap: () async {
                          if (!notification.isRead) {
                            await notificationNotifier.markAsRead(
                              notification.id,
                            );
                          }
                        },
                        onDelete: () async {
                          await notificationNotifier.deleteNotification(
                            notification.id,
                          );
                        },
                      ),
                    ),
                    verticalSpace(32),
                  ],

                  // Leave Requests Section
                  if (leaveNotifications.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Leave Requests',
                      count: leaveNotifications.length,
                      icon: Icons.event_note,
                    ),
                    ...leaveNotifications.map(
                      (notification) => _AdminNotificationItem(
                        notification: notification,
                        onTap: () async {
                          if (!notification.isRead) {
                            await notificationNotifier.markAsRead(
                              notification.id,
                            );
                          }
                        },
                        onDelete: () async {
                          await notificationNotifier.deleteNotification(
                            notification.id,
                          );
                        },
                      ),
                    ),
                    Divider(height: 32.h),
                  ],

                  // Other Notifications Section
                  if (otherNotifications.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Other Notifications',
                      count: otherNotifications.length,
                      icon: Icons.notifications,
                    ),
                    ...otherNotifications.map(
                      (notification) => _AdminNotificationItem(
                        notification: notification,
                        onTap: () async {
                          if (!notification.isRead) {
                            await notificationNotifier.markAsRead(
                              notification.id,
                            );
                          }
                        },
                        onDelete: () async {
                          await notificationNotifier.deleteNotification(
                            notification.id,
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Future<bool?> _showClearAllDialog(
    BuildContext context,
    NotificationNotifier notifier,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications?'),
        content: const Text(
          'This will permanently delete all notifications. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

/// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff8C9F5F), size: 20.sp),
          horizontalSpace(8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xff8C9F5F),
            ),
          ),
          horizontalSpace(8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xff8C9F5F).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xff8C9F5F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Admin Notification Item Widget
class _AdminNotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AdminNotificationItem({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : const Color(0xff8C9F5F).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade200
                  : const Color(0xff8C9F5F).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(
                    notification.type,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  notification.getIconPath(),
                  style: TextStyle(fontSize: 24.sp),
                ),
              ),
              horizontalSpace(12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xff8C9F5F),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    verticalSpace(4),
                    Text(
                      _formatNotificationBody(notification),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                    ),
                    verticalSpace(8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        horizontalSpace(4),
                        Text(
                          _formatTime(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getNotificationColor(
                              notification.type,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getNotificationTypeLabel(notification.type),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: _getNotificationColor(notification.type),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }

  /// Format notification body to show user names in admin-friendly format
  String _formatNotificationBody(NotificationModel notification) {
    // Extract username from notification body if it follows the pattern
    final body = notification.body;

    // Pattern matching for different notification types
    switch (notification.type) {
      case NotificationType.newLeaveRequest:
        // Handle: "hesham hemdan has submitted a leave request"
        if (body.contains(' has submitted a leave request')) {
          final username = body.substring(
            0,
            body.indexOf(' has submitted a leave request'),
          );
          return '$username has submitted a leave request';
        }
        return body;

      case NotificationType.checkIn:
        // Handle: "Employee John has checked in at location"
        if (body.startsWith('Employee ') && body.contains(' has checked in')) {
          final remaining = body.substring(9); // Remove "Employee "
          if (remaining.contains(' at ')) {
            final username = remaining.substring(
              0,
              remaining.indexOf(' has checked in'),
            );
            final location = remaining.substring(remaining.indexOf(' at ') + 4);
            return '$username checked in at $location';
          } else {
            final username = remaining.substring(
              0,
              remaining.indexOf(' has checked in'),
            );
            return '$username checked in';
          }
        }
        return body;

      case NotificationType.checkOut:
        // Handle: "Employee John has checked out at location"
        if (body.startsWith('Employee ') && body.contains(' has checked out')) {
          final remaining = body.substring(9); // Remove "Employee "
          if (remaining.contains(' at ')) {
            final username = remaining.substring(
              0,
              remaining.indexOf(' has checked out'),
            );
            final location = remaining.substring(remaining.indexOf(' at ') + 4);
            return '$username checked out at $location';
          } else {
            final username = remaining.substring(
              0,
              remaining.indexOf(' has checked out'),
            );
            return '$username checked out';
          }
        }
        return body;

      default:
        return body;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.checkIn:
        return Colors.green;
      case NotificationType.checkOut:
        return Colors.orange;
      case NotificationType.leaveRequestSubmitted:
      case NotificationType.newLeaveRequest:
        return Colors.blue;
      case NotificationType.leaveRequestApproved:
        return Colors.green;
      case NotificationType.leaveRequestRejected:
        return Colors.red;
      case NotificationType.attendance:
        return Colors.purple;
      case NotificationType.general:
        return Colors.grey;
    }
  }

  String _getNotificationTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.checkIn:
        return 'Check In';
      case NotificationType.checkOut:
        return 'Check Out';
      case NotificationType.leaveRequestSubmitted:
        return 'Leave Submitted';
      case NotificationType.newLeaveRequest:
        return 'New Leave';
      case NotificationType.leaveRequestApproved:
        return 'Approved';
      case NotificationType.leaveRequestRejected:
        return 'Rejected';
      case NotificationType.attendance:
        return 'Attendance';
      case NotificationType.general:
        return 'General';
    }
  }
}

/// Check if a notification is meant for admin viewing
extension AdminNotificationFilter on AdminNotificationScreen {
  bool _isAdminNotification(NotificationModel notification) {
    switch (notification.type) {
      // Admin sees all employee check-in/out activities
      case NotificationType.checkIn:
      case NotificationType.checkOut:
        // Show notifications with null userId (broadcast to all admins) or admin-specific payloads
        return notification.userId == null ||
            notification.payload?.contains('_admin') == true;

      // Admin sees all leave request notifications (new requests, approved, rejected)
      case NotificationType.newLeaveRequest:
      case NotificationType.leaveRequestApproved:
      case NotificationType.leaveRequestRejected:
        // Show all these types - they're already filtered by the provider
        return true;

      // Admin should NOT see user's own "leave request submitted" notifications
      // Those are personal confirmations for employees
      case NotificationType.leaveRequestSubmitted:
        return false;

      // Admin sees general and attendance notifications
      case NotificationType.attendance:
      case NotificationType.general:
        return true;
    }
  }
}
