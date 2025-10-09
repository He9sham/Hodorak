/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'Hodorak';
  static const String appTitle = 'Hodorak Attendance';
  static const String appVersion = '1.0.0';
  static const String developerName = 'Hesham hamdan';

  // Design Constants
  static const double defaultElevation = 2.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultPadding = 16.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Snackbar Duration
  static const Duration snackbarDuration = Duration(seconds: 2);

  // Private constructor to prevent instantiation
  AppConstants._();
}
