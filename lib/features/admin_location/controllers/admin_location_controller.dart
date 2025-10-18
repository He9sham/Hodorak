import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hodorak/core/providers/company_location_provider.dart'
    as company_location;
import 'package:hodorak/core/providers/location_provider.dart';
import 'package:hodorak/core/providers/supabase_auth_provider.dart';
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

  /// Load existing workplace location from Supabase
  Future<void> _loadExistingLocation() async {
    try {
      final authState = ref.read(supabaseAuthProvider);
      if (authState.user?.companyId != null) {
        final companyLocationState = ref.read(
          company_location.companyLocationProvider,
        );
        if (companyLocationState.location != null) {
          state = state.copyWith(
            selectedLocation: LatLng(
              companyLocationState.location!.latitude,
              companyLocationState.location!.longitude,
            ),
            locationName:
                'Company Location', // Default name for Supabase location
            allowedRadius: 100.0, // Default radius
            isLocationSaved: true,
          );
        }
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

  /// Save workplace location to Supabase
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
      final authState = ref.read(supabaseAuthProvider);
      if (authState.user?.companyId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No company ID found for current user',
        );
        return false;
      }

      final success = await ref
          .read(company_location.companyLocationProvider.notifier)
          .setCompanyLocation(
            latitude: state.selectedLocation!.latitude,
            longitude: state.selectedLocation!.longitude,
          );

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

  /// Clear workplace location from Supabase
  Future<bool> clearLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authState = ref.read(supabaseAuthProvider);
      if (authState.user?.companyId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No company ID found for current user',
        );
        return false;
      }

      final locationService = ref.read(locationServiceProvider);
      final success = await locationService.deleteCompanyLocation(
        authState.user!.companyId!,
      );

      if (success) {
        state = state.copyWith(
          selectedLocation: null,
          locationName: '',
          allowedRadius: AdminLocationConstants.defaultRadius,
          isLoading: false,
          isLocationSaved: false,
          error: null,
        );
        // Refresh the company location provider
        await ref
            .read(company_location.companyLocationProvider.notifier)
            .refresh();
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
