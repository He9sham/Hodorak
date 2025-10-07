import 'package:flutter/material.dart';

class AdminUserManagementConstants {
  // Strings
  static const String title = 'User Management';
  static const String resetPassword = 'Reset Password';
  static const String viewDetails = 'View Details';
  static const String cancel = 'Cancel';
  static const String close = 'Close';
  static const String retry = 'Retry';
  static const String refresh = 'Refresh';
  static const String noUsersFound = 'No users found';
  static const String errorLoadingUsers = 'Error loading users';
  static const String administrator = 'Administrator';
  static const String resettingPassword = 'Resetting password...';
  static const String passwordResetFailed =
      'Password reset failed. Please try again.';
  static const String enterNewPassword = 'Enter new password';
  static const String newPassword = 'New Password';
  static const String confirmPassword = 'Confirm Password';
  static const String pleaseEnterPassword = 'Please enter a new password';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String email = 'Email';
  static const String name = 'Name';
  static const String jobTitle = 'Job Title';
  static const String department = 'Department';
  static const String phone = 'Phone';
  static const String nationalId = 'National ID';
  static const String gender = 'Gender';
  static const String adminStatus = 'Admin Status';
  static const String companyId = 'Company ID';
  static const String created = 'Created';
  static const String updated = 'Updated';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String na = 'N/A';

  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color adminColor = Colors.orange;
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;

  // Dimensions
  static const double cardMargin = 12.0;
  static const double padding = 16.0;
  static const double iconSize = 64.0;
  static const double avatarRadius = 20.0;
  static const double detailLabelWidth = 100.0;

  // Validation
  static const int minPasswordLength = 6;
}
