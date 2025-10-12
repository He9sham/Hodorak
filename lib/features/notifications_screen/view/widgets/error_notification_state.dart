import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';

/// Error state widget for notifications
class ErrorNotificationState extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const ErrorNotificationState({
    super.key,
    required this.onRetry,
    this.message = 'Error loading notifications',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          verticalSpace(16),
          Text(message, style: TextStyle(fontSize: 16.sp)),
          verticalSpace(8),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
