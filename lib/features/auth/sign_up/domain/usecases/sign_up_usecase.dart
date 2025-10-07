import 'package:hodorak/core/providers/supabase_auth_provider.dart';
import 'package:hodorak/features/auth/sign_up/domain/entities/sign_up_entity.dart';
import 'package:hodorak/features/auth/sign_up/domain/entities/sign_up_validation_entity.dart';
import 'package:hodorak/features/auth/sign_up/domain/usecases/validate_sign_up_usecase.dart';

class SignUpUseCase {
  final SupabaseAuthNotifier _authNotifier;
  final ValidateSignUpUseCase _validateUseCase;

  SignUpUseCase(this._authNotifier, this._validateUseCase);

  Future<SignUpResult> execute(SignUpEntity signUpData) async {
    // First validate the data
    final validation = _validateUseCase.validate(signUpData);
    if (validation.hasErrors) {
      return SignUpResult.validationError(validation);
    }

    try {
      // Call the auth provider
      await _authNotifier.signUp(
        name: signUpData.name.trim(),
        email: signUpData.email.trim(),
        password: signUpData.password.trim(),
        jobTitle: signUpData.jobTitle.trim(),
        department: signUpData.department.trim(),
        phone: signUpData.phone.trim(),
        nationalId: signUpData.nationalId.trim(),
        gender: signUpData.gender.trim(),
        companyId: signUpData.companyId,
        isAdmin: signUpData.isAdmin,
      );

      // Return success - the auth provider will handle the state
      return SignUpResult.success();
    } catch (e) {
      return SignUpResult.error(e.toString());
    }
  }
}

class SignUpResult {
  final bool isSuccess;
  final String? error;
  final SignUpValidationEntity? validationErrors;

  SignUpResult._({required this.isSuccess, this.error, this.validationErrors});

  factory SignUpResult.success() {
    return SignUpResult._(isSuccess: true);
  }

  factory SignUpResult.error(String error) {
    return SignUpResult._(isSuccess: false, error: error);
  }

  factory SignUpResult.validationError(
    SignUpValidationEntity validationErrors,
  ) {
    return SignUpResult._(isSuccess: false, validationErrors: validationErrors);
  }
}
