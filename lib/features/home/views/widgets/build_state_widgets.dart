import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';

Widget buildStatsCards(
  BuildContext context, {
  required String pendingRequestsCount,
  required String notificationsCount,
  required String absencesCount,
}) {
  return Row(
    children: [
      // Pending Requests
      Expanded(
        child: _buildStatCard(
          context,
          icon: Icons.hourglass_top_rounded,
          label: 'Pending Requests',
          count: pendingRequestsCount,
          color: Colors.red.shade600,
          backgroundColor: Colors.red.shade50,
        ),
      ),
      horizontalSpace(12),

      // New Notifications
      Expanded(
        child: _buildStatCard(
          context,
          icon: Icons.notifications_rounded,
          label: 'New Notifications',
          count: notificationsCount,
          color: Colors.amber.shade600,
          backgroundColor: Colors.amber.shade50,
        ),
      ),
      horizontalSpace(12),

      // Today's Absences
      Expanded(
        child: _buildStatCard(
          context,
          icon: Icons.person_off_rounded,
          label: 'Today\'s Absences',
          count: absencesCount,
          color: Colors.orange.shade600,
          backgroundColor: Colors.orange.shade50,
        ),
      ),
    ],
  );
}

Widget _buildStatCard(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String count,
  required Color color,
  required Color backgroundColor,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
    ),
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        verticalSpace(8),
        Text(
          count,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 20.sp,
          ),
        ),
        verticalSpace(4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 12.sp,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
