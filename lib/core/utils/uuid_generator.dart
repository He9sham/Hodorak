import 'dart:math';

/// Utility class for generating unique identifiers
class UuidGenerator {
  static const String _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  static final Random _random = Random();

  /// Generates a UUID v4 (random) string
  /// Format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
  /// where x is any hexadecimal digit and y is one of 8, 9, A, or B
  static String generateUuid() {
    final buffer = StringBuffer();

    // Generate 8 hex digits
    for (int i = 0; i < 8; i++) {
      buffer.write(_random.nextInt(16).toRadixString(16));
    }
    buffer.write('-');

    // Generate 4 hex digits
    for (int i = 0; i < 4; i++) {
      buffer.write(_random.nextInt(16).toRadixString(16));
    }
    buffer.write('-');

    // Generate 4 hex digits with version 4 (0100)
    buffer.write('4');
    for (int i = 0; i < 3; i++) {
      buffer.write(_random.nextInt(16).toRadixString(16));
    }
    buffer.write('-');

    // Generate 4 hex digits with variant bits (10xx)
    final variant = 8 + _random.nextInt(4); // 8, 9, A, or B
    buffer.write(variant.toRadixString(16));
    for (int i = 0; i < 3; i++) {
      buffer.write(_random.nextInt(16).toRadixString(16));
    }
    buffer.write('-');

    // Generate 12 hex digits
    for (int i = 0; i < 12; i++) {
      buffer.write(_random.nextInt(16).toRadixString(16));
    }

    return buffer.toString();
  }

  /// Generates a shorter random string (useful for company codes)
  /// Format: 8-character alphanumeric string
  static String generateShortId({int length = 8}) {
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(_chars[_random.nextInt(_chars.length)]);
    }
    return buffer.toString();
  }

  /// Generates a company ID with a specific format
  /// Format: COMP-XXXXXXXX (where X is alphanumeric)
  static String generateCompanyId() {
    return 'COMP-${generateShortId(length: 8)}';
  }
}
