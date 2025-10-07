import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/supabase_user.dart';
import '../services/service_locator.dart';

class SupabaseAuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final SupabaseUser? user;
  final bool isAdmin;

  const SupabaseAuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
    this.isAdmin = false,
  });

  SupabaseAuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    SupabaseUser? user,
    bool? isAdmin,
  }) {
    return SupabaseAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class SupabaseAuthNotifier extends Notifier<SupabaseAuthState> {
  @override
  SupabaseAuthState build() {
    return const SupabaseAuthState();
  }

  /// Initialize auth state - call this when the app starts
  Future<void> initializeAuthState() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final isAuthenticated = await supabaseAuthService.isAuthenticated();

      if (isAuthenticated) {
        final userProfile = await supabaseAuthService.getUserProfile();
        final isAdmin = await supabaseAuthService.isAdmin();

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: userProfile,
          isAdmin: isAdmin,
        );
      } else {
        state = state.copyWith(isAuthenticated: false, isLoading: false);
      }
    } catch (e) {
      String errorMessage = e.toString();

      // Handle network connectivity errors specifically
      if (e.toString().contains('Network error') ||
          e.toString().contains('No internet connection') ||
          e.toString().contains('HTTP error')) {
        errorMessage =
            'No internet connection. Please check your network settings.';
      }

      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  String getInitialRoute() {
    if (state.isLoading) {
      return '/splash';
    }

    if (state.isAuthenticated) {
      return state.isAdmin ? '/admin-home' : '/user-home';
    }

    return '/login';
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await supabaseAuthService.login(
        email: email,
        password: password,
      );

      final userProfile = result['profile'] as SupabaseUser;
      final isAdmin = await supabaseAuthService.isAdmin();

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: userProfile,
        isAdmin: isAdmin,
        error: null,
      );
    } catch (e) {
      String errorMessage = e.toString();

      // Handle network connectivity errors specifically
      if (e.toString().contains('Network error') ||
          e.toString().contains('No internet connection') ||
          e.toString().contains('HTTP error')) {
        errorMessage =
            'No internet connection. Please check your network settings and try again.';
      } else if (e.toString().contains('Invalid email or password')) {
        errorMessage = 'Invalid email or password. Please try again.';
      } else if (e.toString().contains('Email not confirmed') ||
          e.toString().contains('email_not_confirmed')) {
        errorMessage =
            'Please confirm your email. Check your inbox for the confirmation link.';
      }

      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: errorMessage,
      );
      rethrow;
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String jobTitle,
    required String department,
    required String phone,
    required String nationalId,
    required String gender,
    required String companyId,
    bool isAdmin = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await supabaseAuthService.signUp(
        name: name,
        email: email,
        password: password,
        jobTitle: jobTitle,
        department: department,
        phone: phone,
        nationalId: nationalId,
        gender: gender,
        companyId: companyId,
        isAdmin: isAdmin,
      );

      // After successful signup, fetch the user profile
      final userProfile = await supabaseAuthService.getUserProfile(
        result['uid'],
      );

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: userProfile,
        isAdmin: userProfile?.isAdmin ?? false,
        error: null,
      );
    } catch (e) {
      String errorMessage = e.toString();

      if (e.toString().contains('User already registered')) {
        errorMessage = 'An account with this email already exists.';
      } else if (e.toString().contains('Email not confirmed') ||
          e.toString().contains('email_not_confirmed')) {
        errorMessage =
            'Please confirm your email. Check your inbox for the confirmation link.';
      }

      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: errorMessage,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await supabaseAuthService.logout();
      state = const SupabaseAuthState();
    } catch (e) {
      state = state.copyWith(error: 'Failed to logout: ${e.toString()}');
    }
  }

  Future<void> resetUserPassword({
    required String userEmail,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await supabaseAuthService.resetUserPassword(
        userEmail: userEmail,
        newPassword: newPassword,
      );

      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await supabaseAuthService.updateUserProfile(
        userId: state.user!.id,
        updates: updates,
      );

      // Refresh user profile
      final updatedProfile = await supabaseAuthService.getUserProfile();

      state = state.copyWith(
        isLoading: false,
        user: updatedProfile,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<List<SupabaseUser>> getAllUsers() async {
    try {
      return await supabaseAuthService.getAllUsers();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

final supabaseAuthProvider =
    NotifierProvider<SupabaseAuthNotifier, SupabaseAuthState>(
      SupabaseAuthNotifier.new,
    );
