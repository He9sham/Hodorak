import 'dart:developer' as developer;

/// A utility class for logging messages with different levels
class Logger {
  /// Log debug messages (for development debugging)
  static void debug(String message) {
    developer.log(message, name: 'DEBUG');
  }

  /// Log info messages (for general information)
  static void info(String message) {
    developer.log(message, name: 'INFO');
  }

  /// Log error messages (for errors and exceptions)
  static void error(String message) {
    developer.log(message, name: 'ERROR');
  }

  /// Log warning messages (for warnings)
  static void warning(String message) {
    developer.log(message, name: 'WARNING');
  }
}
