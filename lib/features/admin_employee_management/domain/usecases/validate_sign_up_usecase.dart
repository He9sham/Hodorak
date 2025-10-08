import 'package:hodorak/features/admin_employee_management/domain/entities/sign_up_entity.dart';
import 'package:hodorak/features/admin_employee_management/domain/entities/sign_up_validation_entity.dart';

class ValidateSignUpUseCase {
  SignUpValidationEntity validate(SignUpEntity signUpData) {
    final validation = SignUpValidationEntity();

    // Validate name
    if (signUpData.name.trim().isEmpty) {
      return validation.copyWith(nameError: 'Please enter full name');
    }
    if (signUpData.name.trim().length < 2) {
      return validation.copyWith(
        nameError: 'Name must be at least 2 characters',
      );
    }

    // Validate email
    if (signUpData.email.trim().isEmpty) {
      return validation.copyWith(emailError: 'Please enter your email');
    }
    if (!signUpData.email.trim().contains('@')) {
      return validation.copyWith(emailError: 'Please enter a valid email');
    }

    // Validate job title
    if (signUpData.jobTitle.trim().isEmpty) {
      return validation.copyWith(jobTitleError: 'Please enter job title');
    }

    // Validate department
    if (signUpData.department.trim().isEmpty) {
      return validation.copyWith(departmentError: 'Please enter department');
    }

    // Validate phone
    if (signUpData.phone.trim().isEmpty) {
      return validation.copyWith(phoneError: 'Please enter phone number');
    }
    if (signUpData.phone.trim().length < 10) {
      return validation.copyWith(
        phoneError: 'Phone number must be at least 10 digits',
      );
    }

    // Validate national ID
    if (signUpData.nationalId.trim().isEmpty) {
      return validation.copyWith(nationalIdError: 'Please enter national ID');
    }
    if (signUpData.nationalId.trim().length < 8) {
      return validation.copyWith(
        nationalIdError: 'National ID must be at least 8 digits',
      );
    }

    // Validate gender
    if (signUpData.gender.trim().isEmpty) {
      return validation.copyWith(genderError: 'Please select gender');
    }

    // Validate password
    if (signUpData.password.trim().isEmpty) {
      return validation.copyWith(passwordError: 'Please enter your password');
    }
    if (signUpData.password.trim().length < 3) {
      return validation.copyWith(
        passwordError: 'Password must be at least 3 characters',
      );
    }

    // Validate confirm password
    if (signUpData.confirmPassword.trim().isEmpty) {
      return validation.copyWith(
        confirmPasswordError: 'Please enter your password',
      );
    }
    if (signUpData.confirmPassword.trim().length < 3) {
      return validation.copyWith(
        confirmPasswordError: 'Password must be at least 3 characters',
      );
    }

    // Validate password match
    if (signUpData.password.trim() != signUpData.confirmPassword.trim()) {
      return validation.copyWith(
        confirmPasswordError: 'Passwords do not match',
        passwordError: 'Passwords do not match',
      );
    }

    return validation.clearErrors();
  }
}
