import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Service for handling biometric authentication including fingerprint and Face ID
/// Supports:
/// - Fingerprint authentication (Android & iOS)
/// - Face ID authentication (iOS)
/// - Iris authentication (Android)
/// - Other biometric authentication methods
class BiometricAuthService {
  static final BiometricAuthService _instance =
      BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types on the device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate using biometrics (fingerprint or Face ID)
  /// [action] specifies what action the user is performing (e.g., 'check in', 'check out')
  Future<bool> authenticate({String action = 'check in'}) async {
    try {
      // Check if biometric authentication is available
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw Exception(
          'Biometric authentication is not available on this device',
        );
      }

      // Get available biometric types
      final List<BiometricType> availableBiometrics =
          await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        throw Exception('No biometric authentication methods are enrolled');
      }

      // Create user-friendly reason message based on available biometrics
      String reasonMessage = _getAuthenticationReasonMessage(
        availableBiometrics,
        action,
      );

      // Perform authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reasonMessage,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'NotAvailable':
          throw Exception('Biometric authentication is not available');
        case 'NotEnrolled':
          throw Exception('No biometric authentication methods are enrolled');
        case 'LockedOut':
          throw Exception('Biometric authentication is temporarily locked');
        case 'PermanentlyLockedOut':
          throw Exception('Biometric authentication is permanently locked');
        case 'UserCancel':
        case 'Canceled':
          throw Exception('Authentication was canceled by user');
        default:
          throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  /// Get user-friendly biometric type name
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  /// Check if device has specific biometric type
  Future<bool> hasBiometricType(BiometricType type) async {
    final availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.contains(type);
  }

  /// Check if fingerprint authentication is available
  Future<bool> isFingerprintAvailable() async {
    return await hasBiometricType(BiometricType.fingerprint);
  }

  /// Check if Face ID authentication is available
  Future<bool> isFaceIdAvailable() async {
    return await hasBiometricType(BiometricType.face);
  }

  /// Get a user-friendly list of available biometric authentication methods
  Future<String> getAvailableBiometricTypesDescription() async {
    final availableBiometrics = await getAvailableBiometrics();
    if (availableBiometrics.isEmpty) {
      return 'No biometric authentication methods available';
    }

    final typeNames = availableBiometrics
        .map((type) => getBiometricTypeName(type))
        .toList();
    if (typeNames.length == 1) {
      return 'Available: ${typeNames.first}';
    } else {
      return 'Available: ${typeNames.take(typeNames.length - 1).join(', ')} and ${typeNames.last}';
    }
  }

  /// Get user-friendly authentication reason message based on available biometrics
  String _getAuthenticationReasonMessage(
    List<BiometricType> availableBiometrics,
    String action,
  ) {
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Please use Face ID to $action';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Please use your fingerprint to $action';
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return 'Please use your iris to $action';
    } else {
      return 'Please authenticate to $action';
    }
  }
}
