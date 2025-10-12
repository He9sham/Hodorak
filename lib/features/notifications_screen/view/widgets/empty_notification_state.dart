import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';

/// Empty state widget for notifications
class EmptyNotificationState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;

  const EmptyNotificationState({
    super.key,
    this.message = 'No notifications yet',
    this.subtitle,
    this.icon = Icons.notifications_none,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.sp, color: Colors.grey),
          verticalSpace(16),
          Text(
            message,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
          if (subtitle != null) ...[
            verticalSpace(8),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }
}
