import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';

/// Section header widget for grouping notifications
class SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  const SectionHeader({
    super.key,
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
