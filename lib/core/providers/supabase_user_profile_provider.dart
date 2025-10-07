import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/supabase_user.dart';
import 'package:hodorak/core/services/supabase_auth_service.dart';

class SupabaseUserProfileState {
  final SupabaseUser? profileData;
  final bool isLoading;
  final String? error;

  const SupabaseUserProfileState({
    this.profileData,
    this.isLoading = false,
    this.error,
  });

  SupabaseUserProfileState copyWith({
    SupabaseUser? profileData,
    bool? isLoading,
    String? error,
  }) {
    return SupabaseUserProfileState(
      profileData: profileData ?? this.profileData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SupabaseUserProfileNotifier extends Notifier<SupabaseUserProfileState> {
  final SupabaseAuthService _authService;

  SupabaseUserProfileNotifier(this._authService);

  @override
  SupabaseUserProfileState build() {
    // Don't call async methods in build() - this causes initialization issues
    // Profile loading should be triggered when needed
    return const SupabaseUserProfileState();
  }

  /// Initialize user profile - call this when the profile screen loads
  Future<void> initializeUserProfile() async {
    await loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profileData = await _authService.getUserProfile();
      state = state.copyWith(profileData: profileData, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void refreshProfile() {
    loadUserProfile();
  }
}

final supabaseUserProfileProvider =
    NotifierProvider<SupabaseUserProfileNotifier, SupabaseUserProfileState>(() {
      return SupabaseUserProfileNotifier(SupabaseAuthService());
    });
