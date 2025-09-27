import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network connectivity service to check internet connection
class NetworkService {
  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      // If no connectivity at all
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // If there's connectivity, try to reach the internet
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      // If lookup fails, assume no internet
      return false;
    }
  }

  /// Get current connectivity status
  Future<ConnectivityResult> getConnectivityStatus() async {
    final results = await _connectivity.checkConnectivity();
    // Return the first result or none if empty
    return results.isNotEmpty ? results.first : ConnectivityResult.none;
  }

  /// Stream of connectivity changes
  Stream<ConnectivityResult> get connectivityStream {
    return _connectivity.onConnectivityChanged.map(
      (results) => results.isNotEmpty ? results.first : ConnectivityResult.none,
    );
  }

  /// Check if device is connected to WiFi
  Future<bool> isConnectedToWiFi() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }

  /// Check if device is connected to mobile data
  Future<bool> isConnectedToMobile() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile);
  }

  /// Get user-friendly connectivity status message
  Future<String> getConnectivityMessage() async {
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      return 'No internet connection. Please check your network settings.';
    }

    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return 'No internet connection';
    }

    if (results.contains(ConnectivityResult.wifi)) {
      return 'Connected to WiFi';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'Connected to mobile data';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return 'Connected to Ethernet';
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      return 'Connected via Bluetooth';
    } else if (results.contains(ConnectivityResult.vpn)) {
      return 'Connected via VPN';
    } else {
      return 'Connected to network';
    }
  }
}

/// Provider for NetworkService
final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

/// Provider to check internet connectivity
final hasInternetProvider = FutureProvider<bool>((ref) async {
  final networkService = ref.read(networkServiceProvider);
  return await networkService.hasInternetConnection();
});

/// Provider for connectivity status stream
final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  final networkService = ref.read(networkServiceProvider);
  return networkService.connectivityStream;
});
