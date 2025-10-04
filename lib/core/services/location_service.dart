import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:hodorak/core/models/user_location.dart';
import 'package:hodorak/core/models/workplace_location.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _workplaceLocationKey = 'workplace_location';

  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permissions
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permissions
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current user location
  Future<UserLocation?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      Logger.error('Error getting current location: $e');
      return null;
    }
  }

  /// Save workplace location to SharedPreferences
  Future<bool> saveWorkplaceLocation(WorkplaceLocation location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = location.toJson();
      final jsonString = jsonEncode(locationJson);
      final success = await prefs.setString(_workplaceLocationKey, jsonString);
      Logger.info('Workplace location saved: $success');
      return success;
    } catch (e) {
      Logger.error('Error saving workplace location: $e');
      return false;
    }
  }

  /// Get workplace location from SharedPreferences
  Future<WorkplaceLocation?> getWorkplaceLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationString = prefs.getString(_workplaceLocationKey);

      if (locationString == null) {
        Logger.info('No workplace location found in SharedPreferences');
        return null;
      }

      // Parse the JSON string using proper JSON decoding
      final locationData = jsonDecode(locationString) as Map<String, dynamic>;
      final location = WorkplaceLocation.fromJson(locationData);
      Logger.info(
        'Workplace location loaded: ${location.name} at ${location.latitude}, ${location.longitude}',
      );
      return location;
    } catch (e) {
      Logger.error('Error getting workplace location: $e');
      return null;
    }
  }

  /// Calculate distance between two points in meters
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Check if user is within allowed radius of workplace
  Future<bool> isUserAtWorkplace() async {
    try {
      // Debug SharedPreferences
      await debugSharedPreferences();

      // Get workplace location
      final workplaceLocation = await getWorkplaceLocation();
      if (workplaceLocation == null) {
        Logger.info('No workplace location found');
        return false; // No workplace location set
      }

      Logger.info(
        'Workplace location found: ${workplaceLocation.name} at ${workplaceLocation.latitude}, ${workplaceLocation.longitude} with radius ${workplaceLocation.allowedRadius}m',
      );

      // Get current user location
      final userLocation = await getCurrentLocation();
      if (userLocation == null) {
        Logger.info('Could not get user location');
        return false; // Could not get user location
      }

      Logger.info(
        'User location: ${userLocation.latitude}, ${userLocation.longitude}',
      );

      // Calculate distance
      final distance = calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        workplaceLocation.latitude,
        workplaceLocation.longitude,
      );

      Logger.info(
        'Distance to workplace: ${distance.toInt()}m (allowed: ${workplaceLocation.allowedRadius.toInt()}m)',
      );

      // Check if within allowed radius
      final isWithinRadius = distance <= workplaceLocation.allowedRadius;
      Logger.info('User is within workplace radius: $isWithinRadius');
      return isWithinRadius;
    } catch (e) {
      Logger.error('Error checking if user is at workplace: $e');
      return false;
    }
  }

  /// Get distance to workplace in meters
  Future<double?> getDistanceToWorkplace() async {
    try {
      // Get workplace location
      final workplaceLocation = await getWorkplaceLocation();
      if (workplaceLocation == null) {
        return null; // No workplace location set
      }

      // Get current user location
      final userLocation = await getCurrentLocation();
      if (userLocation == null) {
        return null; // Could not get user location
      }

      // Calculate distance
      return calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        workplaceLocation.latitude,
        workplaceLocation.longitude,
      );
    } catch (e) {
      Logger.error('Error getting distance to workplace: $e');
      return null;
    }
  }

  /// Check if workplace location is set
  Future<bool> isWorkplaceLocationSet() async {
    final location = await getWorkplaceLocation();
    Logger.info('Workplace location is set: ${location != null}');
    return location != null;
  }

  /// Clear workplace location
  Future<bool> clearWorkplaceLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_workplaceLocationKey);
    } catch (e) {
      Logger.error('Error clearing workplace location: $e');
      return false;
    }
  }

  /// Debug method to check SharedPreferences content
  Future<void> debugSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      Logger.info('SharedPreferences keys: $keys');

      final locationString = prefs.getString(_workplaceLocationKey);
      Logger.info('Workplace location string: $locationString');

      if (locationString != null) {
        try {
          final locationData =
              jsonDecode(locationString) as Map<String, dynamic>;
          Logger.info('Parsed location data: $locationData');
        } catch (e) {
          Logger.error('Failed to parse location data: $e');
        }
      }
    } catch (e) {
      Logger.error('Error debugging SharedPreferences: $e');
    }
  }

  /// Get location permission status message
  String getLocationPermissionMessage(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return 'Location permission is denied. Please enable it in settings.';
      case LocationPermission.deniedForever:
        return 'Location permission is permanently denied. Please enable it in app settings.';
      case LocationPermission.whileInUse:
        return 'Location permission granted for use while app is in use.';
      case LocationPermission.always:
        return 'Location permission granted for always use.';
      case LocationPermission.unableToDetermine:
        return 'Unable to determine location permission status.';
    }
  }
}
