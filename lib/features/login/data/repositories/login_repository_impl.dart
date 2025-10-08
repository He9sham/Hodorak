import 'package:hodorak/core/providers/supabase_auth_provider.dart';

import '../../domain/entities/login_entity.dart';
import '../../domain/entities/login_result_entity.dart';
import '../../domain/repositories/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final SupabaseAuthNotifier _authNotifier;

  LoginRepositoryImpl(this._authNotifier);

  @override
  Future<LoginResultEntity> login(LoginEntity loginEntity) async {
    try {
      await _authNotifier.login(
        loginEntity.email.trim(),
        loginEntity.password.trim(),
      );

      // Since we can't access state directly, we'll assume success if no exception is thrown
      // The actual role checking will be handled by the auth provider's state management
      return LoginResultEntity.success(
        isAdmin: false, // This will be updated by the auth provider
        userId: null,
      );
    } catch (e) {
      rethrow; // Let the use case handle the error
    }
  }

  @override
  Future<void> logout() async {
    await _authNotifier.logout();
  }

  @override
  Future<bool> isAuthenticated() async {
    // This should be checked through the auth provider's state
    return false;
  }

  @override
  Future<bool> isAdmin() async {
    // This should be checked through the auth provider's state
    return false;
  }
}
