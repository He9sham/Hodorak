import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/odoo_service/odoo_http_service.dart';
import 'package:hodorak/core/services/service_locator.dart';
import 'package:hodorak/core/utils/routes.dart';

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

class LoginNotifier extends Notifier<UserSession> {
  final OdooHttpService _service;

  LoginNotifier(this._service);

  @override
  UserSession build() {
    return const UserSession();
  }

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
      // Return different routes based on user role
      return isAdmin ? Routes.adminHomeScreen : Routes.userHomeScreen;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow; // Rethrow so UI try-catch can handle it
    }
  }

  void logout() {
    _service.clearSession();
    state = const UserSession();
  }
}

final odooHttpServiceProvider = Provider<OdooHttpService>((ref) => odooService);

final loginNotifierProvider = NotifierProvider<LoginNotifier, UserSession>(() {
  return LoginNotifier(odooService);
});
