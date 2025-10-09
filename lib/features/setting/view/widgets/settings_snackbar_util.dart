import 'package:flutter/material.dart';
import 'package:hodorak/core/helper/spacing.dart';

/// Utility class for showing snackbars in settings screen
class SettingsSnackbarUtil {
  /// Show snackbar message
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getSnackBarIcon(message), color: Colors.white),
            horizontalSpace(8),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Get appropriate icon for snackbar based on message
  static IconData _getSnackBarIcon(String message) {
    if (message.contains('dark')) {
      return Icons.dark_mode;
    } else if (message.contains('light')) {
      return Icons.light_mode;
    } else if (message.contains('system')) {
      return Icons.brightness_auto;
    } else if (message.contains('notification')) {
      return Icons.notifications;
    } else {
      return Icons.settings;
    }
  }
}
