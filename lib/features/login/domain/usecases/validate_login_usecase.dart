import '../entities/login_entity.dart';
import '../entities/login_validation_entity.dart';

class ValidateLoginUseCase {
  LoginValidationEntity validate(LoginEntity loginEntity) {
    final errors = <String, String>{};

    // Email validation
    if (loginEntity.email.trim().isEmpty) {
      errors['email'] = 'Please enter your email';
    } else if (!_isValidEmail(loginEntity.email.trim())) {
      errors['email'] = 'Please enter a valid email';
    }

    // Password validation
    if (loginEntity.password.isEmpty) {
      errors['password'] = 'Please enter your password';
    } else if (loginEntity.password.length < 3) {
      errors['password'] = 'Password must be at least 3 characters';
    }

    return LoginValidationEntity.withErrors(errors);
  }

  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }
}
