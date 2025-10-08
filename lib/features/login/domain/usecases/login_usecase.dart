import '../entities/login_entity.dart';
import '../entities/login_result_entity.dart';
import '../repositories/login_repository.dart';
import 'validate_login_usecase.dart';

class LoginUseCase {
  final LoginRepository _repository;
  final ValidateLoginUseCase _validateUseCase;

  LoginUseCase(this._repository, this._validateUseCase);

  Future<LoginResultEntity> execute(LoginEntity loginEntity) async {
    // First validate the data
    final validation = _validateUseCase.validate(loginEntity);
    if (validation.hasErrors) {
      final firstError = validation.errors.values.first;
      return LoginResultEntity.validationError(firstError);
    }

    try {
      return await _repository.login(loginEntity);
    } catch (e) {
      return _handleLoginError(e);
    }
  }

  LoginResultEntity _handleLoginError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('no internet connection') ||
        errorString.contains('network error') ||
        errorString.contains('http error')) {
      return LoginResultEntity.networkError();
    } else if (errorString.contains('invalid email or password')) {
      return LoginResultEntity.invalidCredentials();
    } else if (errorString.contains('email not confirmed') ||
        errorString.contains('email_not_confirmed') ||
        errorString.contains('confirm your email')) {
      return LoginResultEntity.emailNotConfirmed();
    } else {
      return LoginResultEntity.error(error.toString());
    }
  }
}
