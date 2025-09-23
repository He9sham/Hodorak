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

class AuthStateManager extends StateNotifier<AuthState> {
  final OdooHttpService _odooService;

  AuthStateManager(this._odooService) : super(const AuthState()) {
    _checkAuthState();
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
      state = state.copyWith(
        isAuthenticated: false,
        isAdmin: false,
        isLoading: false,
        error: e.toString(),
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
      state = state.copyWith(
        isAuthenticated: false,
        isAdmin: false,
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _odooService.clearSession();
    state = const AuthState();
  }
}

final odooHttpServiceProvider = Provider<OdooHttpService>(
  (ref) => OdooHttpService(),
);

final authStateManagerProvider =
    StateNotifierProvider<AuthStateManager, AuthState>((ref) {
      final service = ref.read(odooHttpServiceProvider);
      return AuthStateManager(service);
    });
