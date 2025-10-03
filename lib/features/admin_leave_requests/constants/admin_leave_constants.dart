import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminLeaveConstants {
  // Colors
  static const Color primaryColor = Color(0xff8C9F5F);
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color pendingColor = Colors.orange;
  static const Color approvedColor = Colors.green;
  static const Color rejectedColor = Colors.red;

  // Dimensions
  static const double cardMargin = 16.0;
  static const double cardPadding = 16.0;
  static const double statusChipPadding = 12.0;
  static const double statusChipVerticalPadding = 6.0;
  static const double statusChipBorderRadius = 20.0;
  static const double statusChipBorderWidth = 1.0;
  static const double iconSize = 20.0;
  static const double detailRowSpacing = 12.0;
  static const double buttonSpacing = 12.0;

  // Text Styles
  static TextStyle statusChipTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12.sp,
  );

  static TextStyle detailLabelStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14.sp,
  );

  static TextStyle detailValueStyle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle userIdStyle = TextStyle(fontSize: 14.sp);

  // Strings
  static const String screenTitle = 'Leave Requests Management';
  static const String noRequestsTitle = 'No leave requests found';
  static const String noRequestsSubtitle =
      'Leave requests will appear here when employees submit them.';
  static const String errorTitle = 'Error loading leave requests';
  static const String retryButtonText = 'Retry';
  static const String approveButtonText = 'Approve';
  static const String rejectButtonText = 'Reject';
  static const String processingText = 'Processing...';

  // Field Labels
  static const String reasonLabel = 'Reason';
  static const String startDateLabel = 'Start Date';
  static const String endDateLabel = 'End Date';
  static const String submittedLabel = 'Submitted';
  static const String userIdLabel = 'User ID';

  // Success Messages
  static const String approveSuccessMessage =
      'Leave request approved successfully!';
  static const String rejectSuccessMessage =
      'Leave request rejected successfully!';

  // Error Messages
  static const String updateErrorMessage = 'Failed to update leave status';
  static const String loadErrorMessage = 'Failed to load leave requests';

  // Delete All Constants
  static const String deleteAllButtonText = 'Delete All Requests';
  static const String deleteAllConfirmTitle = 'Delete All Requests';
  static const String deleteAllConfirmMessage =
      'Are you sure you want to delete all leave requests? This action cannot be undone.';
  static const String deleteAllConfirmButtonText = 'Delete All';
  static const String deleteAllCancelButtonText = 'Cancel';
  static const String deleteAllSuccessMessage =
      'All leave requests deleted successfully!';
  static const String deleteAllErrorMessage = 'Failed to delete all requests';
}
