import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/odoo_service/odoo_http_service.dart';
import 'package:hodorak/core/providers/auth_state_manager.dart';

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

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final OdooHttpService _odooService;

  UserProfileNotifier(this._odooService) : super(const UserProfileState()) {
    loadUserProfile();
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
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
      final odooService = ref.read(odooHttpServiceProvider);
      return UserProfileNotifier(odooService);
    });
