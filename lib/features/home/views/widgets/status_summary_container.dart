import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusSummaryContainer extends StatelessWidget {
  const StatusSummaryContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
  final String title, subtitle;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 90, // Increased height to accommodate longer titles
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20),
            Flexible(
              child: Text(
                title,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w400),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
