import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/providers/supabase_auth_provider.dart';
import 'package:hodorak/features/auth/sign_up/domain/entities/sign_up_entity.dart';
import 'package:hodorak/features/auth/sign_up/domain/entities/sign_up_validation_entity.dart';
import 'package:hodorak/features/auth/sign_up/domain/usecases/sign_up_usecase.dart';
import 'package:hodorak/features/auth/sign_up/domain/usecases/validate_sign_up_usecase.dart';

class SignUpViewModel extends ChangeNotifier {
  final SignUpUseCase _signUpUseCase;
  SignUpState _state = SignUpState.initial();

  SignUpViewModel(this._signUpUseCase);

  SignUpState get state => _state;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Getters for controllers
  TextEditingController get nameController => _nameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get jobTitleController => _jobTitleController;
  TextEditingController get departmentController => _departmentController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get nationalIdController => _nationalIdController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;

  // Update methods
  void updateName(String value) {
    _state = _state.copyWith(name: value);
    _clearFieldError('name');
    notifyListeners();
  }

  void updateEmail(String value) {
    _state = _state.copyWith(email: value);
    _clearFieldError('email');
    notifyListeners();
  }

  void updateJobTitle(String value) {
    _state = _state.copyWith(jobTitle: value);
    _clearFieldError('jobTitle');
    notifyListeners();
  }

  void updateDepartment(String value) {
    _state = _state.copyWith(department: value);
    _clearFieldError('department');
    notifyListeners();
  }

  void updatePhone(String value) {
    _state = _state.copyWith(phone: value);
    _clearFieldError('phone');
    notifyListeners();
  }

  void updateNationalId(String value) {
    _state = _state.copyWith(nationalId: value);
    _clearFieldError('nationalId');
    notifyListeners();
  }

  void updatePassword(String value) {
    _state = _state.copyWith(password: value);
    _clearFieldError('password');
    _clearFieldError('confirmPassword');
    notifyListeners();
  }

  void updateConfirmPassword(String value) {
    _state = _state.copyWith(confirmPassword: value);
    _clearFieldError('confirmPassword');
    _clearFieldError('password');
    notifyListeners();
  }

  void updateGender(String? value) {
    _state = _state.copyWith(gender: value ?? '');
    _clearFieldError('gender');
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _state = _state.copyWith(obscurePassword: !_state.obscurePassword);
    notifyListeners();
  }

  void _clearFieldError(String field) {
    final currentValidation = _state.validationErrors;
    SignUpValidationEntity newValidation;

    switch (field) {
      case 'name':
        newValidation =
            currentValidation?.copyWith(nameError: null) ??
            const SignUpValidationEntity();
        break;
      case 'email':
        newValidation =
            currentValidation?.copyWith(emailError: null) ??
            const SignUpValidationEntity();
        break;
      case 'jobTitle':
        newValidation =
            currentValidation?.copyWith(jobTitleError: null) ??
            const SignUpValidationEntity();
        break;
      case 'department':
        newValidation =
            currentValidation?.copyWith(departmentError: null) ??
            const SignUpValidationEntity();
        break;
      case 'phone':
        newValidation =
            currentValidation?.copyWith(phoneError: null) ??
            const SignUpValidationEntity();
        break;
      case 'nationalId':
        newValidation =
            currentValidation?.copyWith(nationalIdError: null) ??
            const SignUpValidationEntity();
        break;
      case 'gender':
        newValidation =
            currentValidation?.copyWith(genderError: null) ??
            const SignUpValidationEntity();
        break;
      case 'password':
        newValidation =
            currentValidation?.copyWith(passwordError: null) ??
            const SignUpValidationEntity();
        break;
      case 'confirmPassword':
        newValidation =
            currentValidation?.copyWith(confirmPasswordError: null) ??
            const SignUpValidationEntity();
        break;
      default:
        newValidation = currentValidation ?? const SignUpValidationEntity();
    }

    _state = _state.copyWith(validationErrors: newValidation);
  }

  Future<void> signUp() async {
    _state = _state.copyWith(
      isLoading: true,
      error: null,
      validationErrors: null,
    );
    notifyListeners();

    final signUpData = SignUpEntity(
      name: _nameController.text,
      email: _emailController.text,
      jobTitle: _jobTitleController.text,
      department: _departmentController.text,
      phone: _phoneController.text,
      nationalId: _nationalIdController.text,
      gender: _state.gender,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    final result = await _signUpUseCase.execute(signUpData);

    if (result.isSuccess) {
      _state = _state.copyWith(
        isLoading: false,
        isSuccess: true,
        error: null,
        validationErrors: null,
      );
    } else if (result.validationErrors != null) {
      _state = _state.copyWith(
        isLoading: false,
        validationErrors: result.validationErrors,
      );
    } else {
      _state = _state.copyWith(
        isLoading: false,
        error: result.error,
        validationErrors: null,
      );
    }
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }

  void clearValidationErrors() {
    _state = _state.copyWith(validationErrors: null);
    notifyListeners();
  }

  void clearSuccessState() {
    _state = _state.copyWith(isSuccess: false);
    notifyListeners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _jobTitleController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class SignUpState {
  final String name;
  final String email;
  final String jobTitle;
  final String department;
  final String phone;
  final String nationalId;
  final String gender;
  final String password;
  final String confirmPassword;
  final bool obscurePassword;
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final SignUpValidationEntity? validationErrors;

  const SignUpState({
    this.name = '',
    this.email = '',
    this.jobTitle = '',
    this.department = '',
    this.phone = '',
    this.nationalId = '',
    this.gender = '',
    this.password = '',
    this.confirmPassword = '',
    this.obscurePassword = true,
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.validationErrors,
  });

  factory SignUpState.initial() {
    return const SignUpState();
  }

  SignUpState copyWith({
    String? name,
    String? email,
    String? jobTitle,
    String? department,
    String? phone,
    String? nationalId,
    String? gender,
    String? password,
    String? confirmPassword,
    bool? obscurePassword,
    bool? isLoading,
    bool? isSuccess,
    String? error,
    SignUpValidationEntity? validationErrors,
  }) {
    return SignUpState(
      name: name ?? this.name,
      email: email ?? this.email,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      gender: gender ?? this.gender,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}

// Provider
final signUpViewModelProvider = Provider<SignUpViewModel>((ref) {
  return SignUpViewModel(
    SignUpUseCase(
      ref.read(supabaseAuthProvider.notifier),
      ValidateSignUpUseCase(),
    ),
  );
});
