import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/login_result_entity.dart';

class LoginState {
  final bool isLoading;
  final bool isAuthenticated;
  final bool isAdmin;
  final String? userId;
  final String? error;
  final LoginStatus loginStatus;

  const LoginState({
    required this.isLoading,
    required this.isAuthenticated,
    required this.isAdmin,
    this.userId,
    this.error,
    required this.loginStatus,
  });

  const LoginState.initial()
    : isLoading = false,
      isAuthenticated = false,
      isAdmin = false,
      userId = null,
      error = null,
      loginStatus = LoginStatus.success;

  LoginState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    bool? isAdmin,
    String? userId,
    String? error,
    LoginStatus? loginStatus,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isAdmin: isAdmin ?? this.isAdmin,
      userId: userId ?? this.userId,
      error: error ?? this.error,
      loginStatus: loginStatus ?? this.loginStatus,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() {
    return const LoginState.initial();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // For now, we'll handle login through the existing auth provider
      // This will be replaced with the proper use case injection later
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isAdmin: false, // This will be determined by the auth provider
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        loginStatus: LoginStatus.error,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const LoginState.initial();
  }
}
