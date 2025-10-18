import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/company_location.dart';
import '../providers/supabase_auth_provider.dart';
import '../services/location_service.dart';
import '../utils/logger.dart';

// Company location state
class CompanyLocationState {
  final CompanyLocation? location;
  final bool isLoading;
  final String? error;
  final bool hasLocation;

  const CompanyLocationState({
    this.location,
    this.isLoading = false,
    this.error,
    this.hasLocation = false,
  });

  CompanyLocationState copyWith({
    CompanyLocation? location,
    bool? isLoading,
    String? error,
    bool? hasLocation,
  }) {
    return CompanyLocationState(
      location: location ?? this.location,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasLocation: hasLocation ?? this.hasLocation,
    );
  }
}

// Company location notifier
class CompanyLocationNotifier extends Notifier<CompanyLocationState> {
  @override
  CompanyLocationState build() {
    _loadCompanyLocation();
    return const CompanyLocationState();
  }

  Future<void> _loadCompanyLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authState = ref.read(supabaseAuthProvider);
      if (authState.user?.companyId != null) {
        final locationService = ref.read(locationServiceProvider);
        final location = await locationService.getCompanyLocation(
          authState.user!.companyId!,
        );
        state = state.copyWith(
          location: location,
          isLoading: false,
          hasLocation: location != null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'No company ID found for current user',
        );
      }
    } catch (error) {
      Logger.error('Error loading company location: $error');
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<bool> setCompanyLocation({
    required double latitude,
    required double longitude,
  }) async {
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
      final success = await locationService.setAdminLocation(
        companyId: authState.user!.companyId!,
        latitude: latitude,
        longitude: longitude,
      );

      if (success) {
        // Reload the location after successful save
        await _loadCompanyLocation();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to save company location',
        );
        return false;
      }
    } catch (error) {
      Logger.error('Error setting company location: $error');
      state = state.copyWith(isLoading: false, error: error.toString());
      return false;
    }
  }

  Future<bool> canCheckIn() async {
    try {
      final authState = ref.read(supabaseAuthProvider);
      if (authState.user?.companyId == null) {
        return false;
      }

      final locationService = ref.read(locationServiceProvider);
      return await locationService.canCheckIn(authState.user!.companyId!);
    } catch (error) {
      Logger.error('Error checking if user can check in: $error');
      return false;
    }
  }

  Future<double?> getDistanceToCompanyLocation() async {
    try {
      final authState = ref.read(supabaseAuthProvider);
      if (authState.user?.companyId == null) {
        return null;
      }

      final locationService = ref.read(locationServiceProvider);
      return await locationService.getDistanceToCompanyLocation(
        authState.user!.companyId!,
      );
    } catch (error) {
      Logger.error('Error getting distance to company location: $error');
      return null;
    }
  }

  Future<void> refresh() async {
    await _loadCompanyLocation();
  }
}

// Providers
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final companyLocationProvider =
    NotifierProvider<CompanyLocationNotifier, CompanyLocationState>(() {
      return CompanyLocationNotifier();
    });

// Location validation state
class LocationValidationState {
  final bool hasWorkplaceLocation;
  final bool isAtWorkplace;
  final bool isLoading;
  final String? errorMessage;
  final double? distanceToWorkplace;

  const LocationValidationState({
    this.hasWorkplaceLocation = false,
    this.isAtWorkplace = false,
    this.isLoading = false,
    this.errorMessage,
    this.distanceToWorkplace,
  });

  LocationValidationState copyWith({
    bool? hasWorkplaceLocation,
    bool? isAtWorkplace,
    bool? isLoading,
    String? errorMessage,
    double? distanceToWorkplace,
  }) {
    return LocationValidationState(
      hasWorkplaceLocation: hasWorkplaceLocation ?? this.hasWorkplaceLocation,
      isAtWorkplace: isAtWorkplace ?? this.isAtWorkplace,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      distanceToWorkplace: distanceToWorkplace ?? this.distanceToWorkplace,
    );
  }
}

// Location validation notifier
class LocationValidationNotifier extends Notifier<LocationValidationState> {
  @override
  LocationValidationState build() {
    checkInitialState();
    return const LocationValidationState();
  }

  Future<void> checkInitialState() async {
    try {
      final authState = ref.read(supabaseAuthProvider);
      if (authState.user?.companyId == null) {
        state = state.copyWith(
          hasWorkplaceLocation: false,
          errorMessage: 'No company ID found for current user',
        );
        return;
      }

      final locationService = ref.read(locationServiceProvider);
      final hasLocation = await locationService.hasCompanyLocation(
        authState.user!.companyId!,
      );

      state = state.copyWith(
        hasWorkplaceLocation: hasLocation,
        errorMessage: hasLocation
            ? null
            : 'No workplace location has been set by admin.',
      );
    } catch (error) {
      Logger.error('Error checking initial location state: $error');
      state = state.copyWith(
        hasWorkplaceLocation: false,
        errorMessage: 'Error checking location state: ${error.toString()}',
      );
    }
  }

  Future<void> validateLocation() async {
    if (!state.hasWorkplaceLocation) {
      state = state.copyWith(
        isAtWorkplace: false,
        errorMessage: 'No workplace location has been set by admin.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final authState = ref.read(supabaseAuthProvider);
      if (authState.user?.companyId == null) {
        state = state.copyWith(
          isLoading: false,
          isAtWorkplace: false,
          errorMessage: 'No company ID found for current user',
        );
        return;
      }

      final locationService = ref.read(locationServiceProvider);
      final canCheckIn = await locationService.canCheckIn(
        authState.user!.companyId!,
      );
      final distance = await locationService.getDistanceToCompanyLocation(
        authState.user!.companyId!,
      );

      if (canCheckIn) {
        state = state.copyWith(
          isLoading: false,
          isAtWorkplace: true,
          errorMessage: null,
          distanceToWorkplace: distance,
        );
      } else {
        final distanceText = distance != null
            ? ' (${distance.toInt()}m away)'
            : '';
        state = state.copyWith(
          isLoading: false,
          isAtWorkplace: false,
          errorMessage:
              'You must be within 100 meters of the workplace location to check in.$distanceText',
          distanceToWorkplace: distance,
        );
      }
    } catch (error) {
      Logger.error('Error validating location: $error');
      state = state.copyWith(
        isLoading: false,
        isAtWorkplace: false,
        errorMessage: 'Error validating location: ${error.toString()}',
      );
    }
  }
}

final locationValidationProvider =
    NotifierProvider<LocationValidationNotifier, LocationValidationState>(() {
      return LocationValidationNotifier();
    });
