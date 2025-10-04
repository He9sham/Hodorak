import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/user_location.dart';
import 'package:hodorak/core/models/workplace_location.dart';
import 'package:hodorak/core/services/location_service.dart';

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Workplace location state
class WorkplaceLocationState {
  final WorkplaceLocation? location;
  final bool isLoading;
  final String? error;

  const WorkplaceLocationState({
    this.location,
    this.isLoading = false,
    this.error,
  });

  WorkplaceLocationState copyWith({
    WorkplaceLocation? location,
    bool? isLoading,
    String? error,
  }) {
    return WorkplaceLocationState(
      location: location ?? this.location,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// User location state
class UserLocationState {
  final UserLocation? location;
  final bool isLoading;
  final String? error;

  const UserLocationState({this.location, this.isLoading = false, this.error});

  UserLocationState copyWith({
    UserLocation? location,
    bool? isLoading,
    String? error,
  }) {
    return UserLocationState(
      location: location ?? this.location,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Location validation state
class LocationValidationState {
  final bool isValidating;
  final bool isAtWorkplace;
  final double? distanceToWorkplace;
  final String? errorMessage;
  final bool hasWorkplaceLocation;

  const LocationValidationState({
    this.isValidating = false,
    this.isAtWorkplace = false,
    this.distanceToWorkplace,
    this.errorMessage,
    this.hasWorkplaceLocation = false,
  });

  LocationValidationState copyWith({
    bool? isValidating,
    bool? isAtWorkplace,
    double? distanceToWorkplace,
    String? errorMessage,
    bool? hasWorkplaceLocation,
  }) {
    return LocationValidationState(
      isValidating: isValidating ?? this.isValidating,
      isAtWorkplace: isAtWorkplace ?? this.isAtWorkplace,
      distanceToWorkplace: distanceToWorkplace ?? this.distanceToWorkplace,
      errorMessage: errorMessage ?? this.errorMessage,
      hasWorkplaceLocation: hasWorkplaceLocation ?? this.hasWorkplaceLocation,
    );
  }
}

// Workplace location notifier
class WorkplaceLocationNotifier extends Notifier<WorkplaceLocationState> {
  @override
  WorkplaceLocationState build() {
    _loadWorkplaceLocation();
    return const WorkplaceLocationState();
  }

  Future<void> _loadWorkplaceLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getWorkplaceLocation();
      state = state.copyWith(location: location, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<bool> saveWorkplaceLocation(WorkplaceLocation location) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final locationService = ref.read(locationServiceProvider);
      final success = await locationService.saveWorkplaceLocation(location);
      if (success) {
        state = state.copyWith(location: location, isLoading: false);
        // Refresh the validation provider to update the hasWorkplaceLocation status
        ref.read(locationValidationProvider.notifier).checkInitialState();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to save location',
        );
      }
      return success;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      return false;
    }
  }

  Future<bool> clearWorkplaceLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final locationService = ref.read(locationServiceProvider);
      final success = await locationService.clearWorkplaceLocation();
      if (success) {
        state = state.copyWith(location: null, isLoading: false);
        // Refresh the validation provider to update the hasWorkplaceLocation status
        ref.read(locationValidationProvider.notifier).checkInitialState();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to clear location',
        );
      }
      return success;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      return false;
    }
  }

  void refresh() {
    _loadWorkplaceLocation();
  }
}

// User location notifier
class UserLocationNotifier extends Notifier<UserLocationState> {
  @override
  UserLocationState build() {
    return const UserLocationState();
  }

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation();
      state = state.copyWith(location: location, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  void clearLocation() {
    state = const UserLocationState();
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
      final locationService = ref.read(locationServiceProvider);
      final hasWorkplace = await locationService.isWorkplaceLocationSet();
      state = state.copyWith(hasWorkplaceLocation: hasWorkplace);
    } catch (error) {
      // Ignore error in initial check
    }
  }

  Future<void> validateLocation() async {
    try {
      state = state.copyWith(isValidating: true, errorMessage: null);

      final locationService = ref.read(locationServiceProvider);

      // Check if workplace location is set
      final hasWorkplace = await locationService.isWorkplaceLocationSet();
      if (!hasWorkplace) {
        state = state.copyWith(
          isValidating: false,
          isAtWorkplace: false,
          hasWorkplaceLocation: false,
          errorMessage: 'No workplace location has been set by admin',
        );
        return;
      }

      // Check if user is at workplace
      final isAtWorkplace = await locationService.isUserAtWorkplace();
      final distance = await locationService.getDistanceToWorkplace();

      state = state.copyWith(
        isValidating: false,
        isAtWorkplace: isAtWorkplace,
        distanceToWorkplace: distance,
        hasWorkplaceLocation: true,
        errorMessage: isAtWorkplace
            ? null
            : 'You must be at the workplace location to check in/out',
      );
    } catch (error) {
      state = state.copyWith(
        isValidating: false,
        isAtWorkplace: false,
        errorMessage: 'Error validating location: ${error.toString()}',
      );
    }
  }

  void clearValidation() {
    state = const LocationValidationState();
  }
}

// Providers
final workplaceLocationProvider =
    NotifierProvider<WorkplaceLocationNotifier, WorkplaceLocationState>(() {
      return WorkplaceLocationNotifier();
    });

final userLocationProvider =
    NotifierProvider<UserLocationNotifier, UserLocationState>(() {
      return UserLocationNotifier();
    });

final locationValidationProvider =
    NotifierProvider<LocationValidationNotifier, LocationValidationState>(() {
      return LocationValidationNotifier();
    });
