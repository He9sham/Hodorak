import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hodorak/core/models/workplace_location.dart';
import 'package:hodorak/core/providers/location_provider.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:hodorak/features/admin_location/constants/admin_location_constants.dart';
import 'package:hodorak/features/admin_location/utils/admin_location_validator.dart';

// Admin location state
class AdminLocationState {
  final LatLng? selectedLocation;
  final LatLng? currentLocation;
  final String locationName;
  final double allowedRadius;
  final bool isLoading;
  final bool isGettingLocation;
  final String? error;
  final bool isLocationSaved;

  const AdminLocationState({
    this.selectedLocation,
    this.currentLocation,
    this.locationName = '',
    this.allowedRadius = 100.0,
    this.isLoading = false,
    this.isGettingLocation = false,
    this.error,
    this.isLocationSaved = false,
  });

  AdminLocationState copyWith({
    LatLng? selectedLocation,
    LatLng? currentLocation,
    String? locationName,
    double? allowedRadius,
    bool? isLoading,
    bool? isGettingLocation,
    String? error,
    bool? isLocationSaved,
  }) {
    return AdminLocationState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      currentLocation: currentLocation ?? this.currentLocation,
      locationName: locationName ?? this.locationName,
      allowedRadius: allowedRadius ?? this.allowedRadius,
      isLoading: isLoading ?? this.isLoading,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
      error: error ?? this.error,
      isLocationSaved: isLocationSaved ?? this.isLocationSaved,
    );
  }
}

// Admin location controller
class AdminLocationController extends Notifier<AdminLocationState> {
  @override
  AdminLocationState build() {
    _loadExistingLocation();
    _getCurrentLocation();
    return const AdminLocationState();
  }

  /// Load existing workplace location
  Future<void> _loadExistingLocation() async {
    try {
      final workplaceState = ref.read(workplaceLocationProvider);
      if (workplaceState.location != null) {
        state = state.copyWith(
          selectedLocation: LatLng(
            workplaceState.location!.latitude,
            workplaceState.location!.longitude,
          ),
          locationName: workplaceState.location!.name,
          allowedRadius: workplaceState.location!.allowedRadius,
          isLocationSaved: true,
        );
      }
    } catch (e) {
      Logger.error('Error loading existing location: $e');
      state = state.copyWith(error: AdminLocationConstants.errorLoadLocation);
    }
  }

  /// Get current user location
  Future<void> _getCurrentLocation() async {
    state = state.copyWith(isGettingLocation: true, error: null);

    try {
      final locationService = ref.read(locationServiceProvider);
      final userLocation = await locationService.getCurrentLocation();

      if (userLocation != null) {
        state = state.copyWith(
          currentLocation: LatLng(
            userLocation.latitude,
            userLocation.longitude,
          ),
          isGettingLocation: false,
        );
      } else {
        state = state.copyWith(
          isGettingLocation: false,
          error: AdminLocationConstants.errorGetCurrentLocation,
        );
      }
    } catch (e) {
      Logger.error('Error getting current location: $e');
      state = state.copyWith(
        isGettingLocation: false,
        error: 'Error getting current location: ${e.toString()}',
      );
    }
  }

  /// Update selected location
  void updateSelectedLocation(LatLng location) {
    state = state.copyWith(selectedLocation: location);
  }

  /// Update location name
  void updateLocationName(String name) {
    final sanitizedName = AdminLocationValidator.sanitizeLocationName(name);
    state = state.copyWith(locationName: sanitizedName);
  }

  /// Update allowed radius
  void updateAllowedRadius(double radius) {
    state = state.copyWith(allowedRadius: radius);
  }

  /// Use current location as selected location
  void useCurrentLocation() {
    if (state.currentLocation != null) {
      state = state.copyWith(selectedLocation: state.currentLocation);
    }
  }

  /// Refresh current location
  Future<void> refreshCurrentLocation() async {
    await _getCurrentLocation();
  }

  /// Save workplace location
  Future<bool> saveLocation() async {
    // Validate all inputs
    final validationError = AdminLocationValidator.getFirstValidationError(
      selectedLocation: state.selectedLocation,
      locationName: state.locationName,
      allowedRadius: state.allowedRadius,
    );

    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final workplaceLocation = WorkplaceLocation(
        latitude: state.selectedLocation!.latitude,
        longitude: state.selectedLocation!.longitude,
        name: AdminLocationValidator.sanitizeLocationName(state.locationName),
        allowedRadius: state.allowedRadius,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ref
          .read(workplaceLocationProvider.notifier)
          .saveWorkplaceLocation(workplaceLocation);

      if (success) {
        state = state.copyWith(
          isLoading: false,
          isLocationSaved: true,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: AdminLocationConstants.errorSaveLocation,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error saving location: ${e.toString()}',
      );
      return false;
    }
  }

  /// Clear workplace location
  Future<bool> clearLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await ref
          .read(workplaceLocationProvider.notifier)
          .clearWorkplaceLocation();

      if (success) {
        state = state.copyWith(
          selectedLocation: null,
          locationName: '',
          allowedRadius: AdminLocationConstants.defaultRadius,
          isLoading: false,
          isLocationSaved: false,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: AdminLocationConstants.errorClearLocation,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error clearing location: ${e.toString()}',
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = const AdminLocationState();
    _loadExistingLocation();
    _getCurrentLocation();
  }
}

// Provider
final adminLocationControllerProvider =
    NotifierProvider<AdminLocationController, AdminLocationState>(() {
      return AdminLocationController();
    });
