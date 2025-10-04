import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hodorak/features/admin_location/constants/admin_location_constants.dart';

class AdminLocationValidator {
  /// Validate location name
  static String? validateLocationName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return AdminLocationConstants.errorEnterLocationName;
    }

    final trimmedName = name.trim();

    if (trimmedName.length < AdminLocationConstants.minLocationNameLength) {
      return AdminLocationConstants.errorLocationNameTooShort;
    }

    if (trimmedName.length > AdminLocationConstants.maxLocationNameLength) {
      return AdminLocationConstants.errorLocationNameTooLong;
    }

    // Check for valid characters (letters, numbers, spaces, hyphens, apostrophes)
    final validNamePattern = RegExp(r"^[a-zA-Z0-9\s\-']+$");
    if (!validNamePattern.hasMatch(trimmedName)) {
      return 'Location name can only contain letters, numbers, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validate selected location
  static String? validateSelectedLocation(LatLng? location) {
    if (location == null) {
      return AdminLocationConstants.errorSelectLocation;
    }

    // Validate latitude range (-90 to 90)
    if (location.latitude < -90 || location.latitude > 90) {
      return 'Invalid latitude. Must be between -90 and 90 degrees.';
    }

    // Validate longitude range (-180 to 180)
    if (location.longitude < -180 || location.longitude > 180) {
      return 'Invalid longitude. Must be between -180 and 180 degrees.';
    }

    return null;
  }

  /// Validate allowed radius
  static String? validateAllowedRadius(double radius) {
    if (radius < AdminLocationConstants.minRadius) {
      return 'Radius must be at least ${AdminLocationConstants.minRadius.toInt()} meters';
    }

    if (radius > AdminLocationConstants.maxRadius) {
      return 'Radius must be at most ${AdminLocationConstants.maxRadius.toInt()} meters';
    }

    return null;
  }

  /// Validate complete location data
  static Map<String, String?> validateLocationData({
    required LatLng? selectedLocation,
    required String locationName,
    required double allowedRadius,
  }) {
    return {
      'location': validateSelectedLocation(selectedLocation),
      'name': validateLocationName(locationName),
      'radius': validateAllowedRadius(allowedRadius),
    };
  }

  /// Check if location data is valid
  static bool isLocationDataValid({
    required LatLng? selectedLocation,
    required String locationName,
    required double allowedRadius,
  }) {
    final validation = validateLocationData(
      selectedLocation: selectedLocation,
      locationName: locationName,
      allowedRadius: allowedRadius,
    );

    return validation.values.every((error) => error == null);
  }

  /// Get the first validation error
  static String? getFirstValidationError({
    required LatLng? selectedLocation,
    required String locationName,
    required double allowedRadius,
  }) {
    final validation = validateLocationData(
      selectedLocation: selectedLocation,
      locationName: locationName,
      allowedRadius: allowedRadius,
    );

    for (final error in validation.values) {
      if (error != null) return error;
    }

    return null;
  }

  /// Sanitize location name
  static String sanitizeLocationName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Check if coordinates are valid
  static bool areCoordinatesValid(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  /// Calculate distance between two points (in meters)
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Earth's radius in meters

    final double lat1Rad = point1.latitude * (3.14159265359 / 180);
    final double lat2Rad = point2.latitude * (3.14159265359 / 180);
    final double deltaLatRad =
        (point2.latitude - point1.latitude) * (3.14159265359 / 180);
    final double deltaLonRad =
        (point2.longitude - point1.longitude) * (3.14159265359 / 180);

    final double a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLonRad / 2) *
            math.sin(deltaLonRad / 2);
    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  /// Check if a point is within radius of another point
  static bool isWithinRadius(
    LatLng center,
    LatLng point,
    double radiusInMeters,
  ) {
    final distance = calculateDistance(center, point);
    return distance <= radiusInMeters;
  }
}
