import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/models/notification_model.dart';
import 'package:hodorak/features/notifications_screen/models/notification_display_config.dart';

/// Admin notification item widget with enhanced display
class AdminNotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String formattedTime;
  final String formattedBody;

  const AdminNotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
    required this.formattedTime,
    required this.formattedBody,
  });

  @override
  Widget build(BuildContext context) {
    final config = NotificationDisplayConfig.forType(notification.type);

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
                  color: config.color.withValues(alpha: 0.1),
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
                      formattedBody,
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
                          formattedTime,
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
                            color: config.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            config.label,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: config.color,
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
}
