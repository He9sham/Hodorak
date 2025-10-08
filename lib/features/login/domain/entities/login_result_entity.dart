enum LoginStatus {
  success,
  error,
  validationError,
  networkError,
  emailNotConfirmed,
  invalidCredentials,
}

class LoginResultEntity {
  final LoginStatus status;
  final String? errorMessage;
  final bool isAdmin;
  final String? userId;

  const LoginResultEntity({
    required this.status,
    this.errorMessage,
    this.isAdmin = false,
    this.userId,
  });

  bool get isSuccess => status == LoginStatus.success;
  bool get isError => status == LoginStatus.error;
  bool get isValidationError => status == LoginStatus.validationError;
  bool get isNetworkError => status == LoginStatus.networkError;
  bool get isEmailNotConfirmed => status == LoginStatus.emailNotConfirmed;
  bool get isInvalidCredentials => status == LoginStatus.invalidCredentials;

  factory LoginResultEntity.success({required bool isAdmin, String? userId}) {
    return LoginResultEntity(
      status: LoginStatus.success,
      isAdmin: isAdmin,
      userId: userId,
    );
  }

  factory LoginResultEntity.error(String message) {
    return LoginResultEntity(status: LoginStatus.error, errorMessage: message);
  }

  factory LoginResultEntity.validationError(String message) {
    return LoginResultEntity(
      status: LoginStatus.validationError,
      errorMessage: message,
    );
  }

  factory LoginResultEntity.networkError() {
    return const LoginResultEntity(
      status: LoginStatus.networkError,
      errorMessage:
          'No internet connection. Please check your network settings and try again.',
    );
  }

  factory LoginResultEntity.emailNotConfirmed() {
    return const LoginResultEntity(
      status: LoginStatus.emailNotConfirmed,
      errorMessage:
          'Please confirm your email. Check your inbox for the confirmation link.',
    );
  }

  factory LoginResultEntity.invalidCredentials() {
    return const LoginResultEntity(
      status: LoginStatus.invalidCredentials,
      errorMessage: 'Invalid email or password. Please try again.',
    );
  }

  @override
  String toString() {
    return 'LoginResultEntity(status: $status, errorMessage: $errorMessage, isAdmin: $isAdmin, userId: $userId)';
  }
}
