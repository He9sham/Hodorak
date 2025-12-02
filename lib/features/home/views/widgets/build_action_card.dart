import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Color palette for action cards - distinct colors for each action
const Map<int, Color> cardColorPalette = {
  0: Color(0xFF2C5AA0), // Deep Blue
  1: Color(0xFF0D8B8B), // Teal
  2: Color(0xFF2E7D32), // Deep Green
  3: Color(0xFFE8590F), // Deep Orange
  4: Color(0xFF5E35B1), // Deep Purple
  5: Color(0xFF00796B), // Teal Dark
  6: Color(0xFFC62828), // Deep Red
  7: Color(0xFF6A1B9A), // Purple
};

/// Build an action card with distinct coloring, elevated shadow, and modern design
Widget buildActionCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  bool showBadge = false,
  int colorIndex = 0,
}) {
  final cardColor =
      cardColorPalette[colorIndex % cardColorPalette.length] ?? Colors.blue;
  final lightColor = cardColor.withValues(alpha: 0.08);

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      splashColor: cardColor.withValues(alpha: 0.1),
      highlightColor: cardColor.withValues(alpha: 0.05),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(color: cardColor.withValues(alpha: 0.08), width: 1),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, size: 28.sp, color: cardColor),
                ),
                if (showBadge)
                  Positioned(
                    right: -6.w,
                    top: -6.w,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900,
                fontSize: 14.sp,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
                fontSize: 12.sp,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
