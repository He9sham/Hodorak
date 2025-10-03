import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/odoo_service/odoo_http_service.dart';
import 'package:hodorak/core/utils/routes.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isAdmin;
  final bool isLoading;
  final String? error;
  final int? uid;
  final String? name;

  const AuthState({
    this.isAuthenticated = false,
    this.isAdmin = false,
    this.isLoading = false,
    this.error,
    this.uid,
    this.name,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isAdmin,
    bool? isLoading,
    String? error,
    int? uid,
    String? name,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isAdmin: isAdmin ?? this.isAdmin,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      uid: uid ?? this.uid,
      name: name ?? this.name,
    );
  }
}

class AuthStateManager extends Notifier<AuthState> {
  final OdooHttpService _odooService;

  AuthStateManager(this._odooService);

  @override
  AuthState build() {
    // Don't call async methods in build() - this causes initialization issues
    // The auth check should be triggered from the UI when needed
    return const AuthState();
  }

  /// Initialize auth state - call this when the app starts
  Future<void> initializeAuthState() async {
    await _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check if user has saved session
      final isAuthenticated = await _odooService.isAuthenticated();

      if (isAuthenticated) {
        // Verify the session is still valid by checking admin status
        final isAdmin = await _odooService.isAdmin();
        final uid = _odooService.uid;

        state = state.copyWith(
          isAuthenticated: true,
          isAdmin: isAdmin,
          isLoading: false,
          uid: uid,
          name: 'User', // You might want to fetch the actual name from Odoo
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isAdmin: false,
          isLoading: false,
        );
      }
    } catch (e) {
      // If there's an error checking auth state, clear it
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
        isAdmin: false,
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  String getInitialRoute() {
    if (state.isLoading) {
      return Routes.splashScreen;
    }

    if (state.isAuthenticated) {
      return state.isAdmin ? Routes.adminHomeScreen : Routes.userHomeScreen;
    }

    return Routes.loginScreen;
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _odooService.login(login: email, password: password);
      final isAdmin = await _odooService.isAdmin();
      final uid = result['uid'] as int;

      state = state.copyWith(
        isAuthenticated: true,
        isAdmin: isAdmin,
        isLoading: false,
        uid: uid,
        name: email,
      );
    } catch (e) {
      String errorMessage = e.toString();

      // Handle network connectivity errors specifically
      if (e.toString().contains('Network error') ||
          e.toString().contains('No internet connection') ||
          e.toString().contains('HTTP error')) {
        errorMessage =
            'No internet connection. Please check your network settings.';
      } else if (e.toString().contains('Invalid credentials') ||
          e.toString().contains('password or email has wrong')) {
        errorMessage = 'Invalid email or password. Please try again.';
      }

      state = state.copyWith(
        isAuthenticated: false,
        isAdmin: false,
        isLoading: false,
        error: errorMessage,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _odooService.clearSession();
    state = const AuthState();
  }

  Future<void> adminResetUserPassword(
    String userEmail,
    String newPassword,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _odooService.adminResetUserPassword(
        userEmail: userEmail,
        newPassword: newPassword,
      );
      if (success) {
        state = state.copyWith(isLoading: false, error: null);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to reset user password. Please try again.',
        );
      }
    } catch (e) {
      String errorMessage = e.toString();

      // Handle specific error types
      if (e.toString().contains('Network error') ||
          e.toString().contains('No internet connection') ||
          e.toString().contains('HTTP error')) {
        errorMessage =
            'No internet connection. Please check your network settings.';
      } else if (e.toString().contains('No user found with this email') ||
          e.toString().contains('Invalid email')) {
        errorMessage = 'No account found with this email address.';
      } else if (e.toString().contains('Only administrators can reset')) {
        errorMessage = 'Only administrators can reset user passwords.';
      } else if (e.toString().contains('Not authorized') ||
          e.toString().contains('Access Denied')) {
        errorMessage = 'You do not have permission to reset passwords.';
      } else if (e.toString().contains('Failed to reset user password')) {
        errorMessage = 'Failed to reset user password. Please try again.';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      rethrow;
    }
  }
}

final odooHttpServiceProvider = Provider<OdooHttpService>(
  (ref) => OdooHttpService(),
);

final authStateManagerProvider = NotifierProvider<AuthStateManager, AuthState>(
  () {
    final service = OdooHttpService();
    return AuthStateManager(service);
  },
);
