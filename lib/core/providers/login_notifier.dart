import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/odoo_service/odoo_http_service.dart';

class UserSession {
  final int? uid;
  final String? name;
  final bool isAdmin;
  final bool isLoading;
  final String? error;

  const UserSession({
    this.uid,
    this.name,
    this.isAdmin = false,
    this.isLoading = false,
    this.error,
  });

  UserSession copyWith({
    int? uid,
    String? name,
    bool? isAdmin,
    bool? isLoading,
    String? error,
  }) {
    return UserSession(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LoginNotifier extends StateNotifier<UserSession> {
  final OdooHttpService _service;

  LoginNotifier(this._service) : super(const UserSession());

  Future<String> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _service.login(login: email, password: password);
      final isAdmin = await _service.isAdmin();
      final uid = result['uid'] as int;
      state = state.copyWith(
        uid: uid,
        name: email,
        isAdmin: isAdmin,
        isLoading: false,
      );
      return isAdmin ? '/admin-dashboard' : '/user-dashboard';
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void logout() {
    _service.clearSession();
    state = const UserSession();
  }
}

final odooHttpServiceProvider = Provider<OdooHttpService>(
  (ref) => OdooHttpService(),
);

final loginNotifierProvider = StateNotifierProvider<LoginNotifier, UserSession>(
  (ref) {
    final service = ref.read(odooHttpServiceProvider);
    return LoginNotifier(service);
  },
);
