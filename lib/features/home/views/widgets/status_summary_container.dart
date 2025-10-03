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
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),

            Text(
              title,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
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
