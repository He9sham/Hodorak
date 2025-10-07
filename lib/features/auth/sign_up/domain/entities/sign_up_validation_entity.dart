class SignUpValidationEntity {
  final String? nameError;
  final String? emailError;
  final String? jobTitleError;
  final String? departmentError;
  final String? phoneError;
  final String? nationalIdError;
  final String? genderError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? generalError;

  const SignUpValidationEntity({
    this.nameError,
    this.emailError,
    this.jobTitleError,
    this.departmentError,
    this.phoneError,
    this.nationalIdError,
    this.genderError,
    this.passwordError,
    this.confirmPasswordError,
    this.generalError,
  });

  bool get hasErrors {
    return nameError != null ||
        emailError != null ||
        jobTitleError != null ||
        departmentError != null ||
        phoneError != null ||
        nationalIdError != null ||
        genderError != null ||
        passwordError != null ||
        confirmPasswordError != null ||
        generalError != null;
  }

  SignUpValidationEntity copyWith({
    String? nameError,
    String? emailError,
    String? jobTitleError,
    String? departmentError,
    String? phoneError,
    String? nationalIdError,
    String? genderError,
    String? passwordError,
    String? confirmPasswordError,
    String? generalError,
  }) {
    return SignUpValidationEntity(
      nameError: nameError ?? this.nameError,
      emailError: emailError ?? this.emailError,
      jobTitleError: jobTitleError ?? this.jobTitleError,
      departmentError: departmentError ?? this.departmentError,
      phoneError: phoneError ?? this.phoneError,
      nationalIdError: nationalIdError ?? this.nationalIdError,
      genderError: genderError ?? this.genderError,
      passwordError: passwordError ?? this.passwordError,
      confirmPasswordError: confirmPasswordError ?? this.confirmPasswordError,
      generalError: generalError ?? this.generalError,
    );
  }

  SignUpValidationEntity clearErrors() {
    return const SignUpValidationEntity();
  }
}
