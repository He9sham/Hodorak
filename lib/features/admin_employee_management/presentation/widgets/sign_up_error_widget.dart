import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpErrorWidget extends StatelessWidget {
  const SignUpErrorWidget({super.key, required this.error});

  final String error;

  Color _getErrorColor(String error) {
    if (error.contains('No internet connection') ||
        error.contains('Network error') ||
        error.contains('HTTP error')) {
      return Colors.orange;
    } else if (error.contains('Email not confirmed') ||
        error.contains('confirm your email')) {
      return Colors.blue;
    }
    return Colors.red;
  }

  Color _getErrorTextColor(String error) {
    if (error.contains('No internet connection') ||
        error.contains('Network error') ||
        error.contains('HTTP error')) {
      return Colors.orange.shade800;
    } else if (error.contains('Email not confirmed') ||
        error.contains('confirm your email')) {
      return Colors.blue.shade800;
    }
    return Colors.red.shade800;
  }

  IconData _getErrorIcon(String error) {
    if (error.contains('No internet connection') ||
        error.contains('Network error') ||
        error.contains('HTTP error')) {
      return Icons.wifi_off;
    } else if (error.contains('Email not confirmed') ||
        error.contains('confirm your email')) {
      return Icons.email_outlined;
    }
    return Icons.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _getErrorColor(error).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getErrorColor(error), width: 1),
      ),
      child: Row(
        children: [
          Icon(_getErrorIcon(error), color: _getErrorColor(error), size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: _getErrorTextColor(error),
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
