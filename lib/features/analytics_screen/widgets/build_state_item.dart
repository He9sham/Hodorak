import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';

Widget buildStatItem(String label, String value, IconData icon, Color color) {
  return Column(
    children: [
      Icon(icon, color: color, size: 24.sp),

      verticalSpace(8),
      Text(
        value,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),

      verticalSpace(4),
      Text(
        label,
        style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
      ),
    ],
  );
}
