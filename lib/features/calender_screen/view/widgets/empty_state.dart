import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          verticalSpace(16),
          Text(
            'No Attendance Data',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          verticalSpace(8),
          Text(
            'Select a day to view attendance details\nor create test data to see the calendar in action',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
