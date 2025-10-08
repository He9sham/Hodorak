class LoginValidationEntity {
  final Map<String, String> errors;

  const LoginValidationEntity({required this.errors});

  bool get hasErrors => errors.isNotEmpty;
  bool get isValid => !hasErrors;

  String? get emailError => errors['email'];
  String? get passwordError => errors['password'];

  factory LoginValidationEntity.empty() {
    return const LoginValidationEntity(errors: {});
  }

  factory LoginValidationEntity.withErrors(Map<String, String> errors) {
    return LoginValidationEntity(errors: errors);
  }

  LoginValidationEntity addError(String field, String message) {
    final newErrors = Map<String, String>.from(errors);
    newErrors[field] = message;
    return LoginValidationEntity(errors: newErrors);
  }

  LoginValidationEntity removeError(String field) {
    final newErrors = Map<String, String>.from(errors);
    newErrors.remove(field);
    return LoginValidationEntity(errors: newErrors);
  }

  @override
  String toString() {
    return 'LoginValidationEntity(errors: $errors)';
  }
}
