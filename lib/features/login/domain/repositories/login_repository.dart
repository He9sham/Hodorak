import '../entities/login_entity.dart';
import '../entities/login_result_entity.dart';

abstract class LoginRepository {
  Future<LoginResultEntity> login(LoginEntity loginEntity);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<bool> isAdmin();
}
