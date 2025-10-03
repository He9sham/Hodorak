import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/odoo_service/odoo_http_service.dart';

class UserProfileState {
  final Map<String, dynamic>? profileData;
  final bool isLoading;
  final String? error;

  const UserProfileState({
    this.profileData,
    this.isLoading = false,
    this.error,
  });

  UserProfileState copyWith({
    Map<String, dynamic>? profileData,
    bool? isLoading,
    String? error,
  }) {
    return UserProfileState(
      profileData: profileData ?? this.profileData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserProfileNotifier extends Notifier<UserProfileState> {
  final OdooHttpService _odooService;

  UserProfileNotifier(this._odooService);

  @override
  UserProfileState build() {
    // Don't call async methods in build() - this causes initialization issues
    // Profile loading should be triggered when needed
    return const UserProfileState();
  }

  /// Initialize user profile - call this when the profile screen loads
  Future<void> initializeUserProfile() async {
    await loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profileData = await _odooService.getUserProfile();
      state = state.copyWith(profileData: profileData, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void refreshProfile() {
    loadUserProfile();
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfileState>(() {
      final odooService = OdooHttpService();
      return UserProfileNotifier(odooService);
    });
