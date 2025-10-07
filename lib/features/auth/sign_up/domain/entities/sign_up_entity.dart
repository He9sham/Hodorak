class SignUpEntity {
  final String name;
  final String email;
  final String jobTitle;
  final String department;
  final String phone;
  final String nationalId;
  final String gender;
  final String password;
  final String confirmPassword;
  final String companyId;
  final bool isAdmin;

  const SignUpEntity({
    required this.name,
    required this.email,
    required this.jobTitle,
    required this.department,
    required this.phone,
    required this.nationalId,
    required this.gender,
    required this.password,
    required this.confirmPassword,
    this.companyId = '',
    this.isAdmin = false,
  });

  SignUpEntity copyWith({
    String? name,
    String? email,
    String? jobTitle,
    String? department,
    String? phone,
    String? nationalId,
    String? gender,
    String? password,
    String? confirmPassword,
    String? companyId,
    bool? isAdmin,
  }) {
    return SignUpEntity(
      name: name ?? this.name,
      email: email ?? this.email,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      gender: gender ?? this.gender,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      companyId: companyId ?? this.companyId,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'jobTitle': jobTitle,
      'department': department,
      'phone': phone,
      'nationalId': nationalId,
      'gender': gender,
      'password': password,
      'confirmPassword': confirmPassword,
      'companyId': companyId,
      'isAdmin': isAdmin,
    };
  }

  @override
  String toString() {
    return 'SignUpEntity(name: $name, email: $email, jobTitle: $jobTitle, department: $department, phone: $phone, nationalId: $nationalId, gender: $gender, companyId: $companyId, isAdmin: $isAdmin)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SignUpEntity &&
        other.name == name &&
        other.email == email &&
        other.jobTitle == jobTitle &&
        other.department == department &&
        other.phone == phone &&
        other.nationalId == nationalId &&
        other.gender == gender &&
        other.password == password &&
        other.confirmPassword == confirmPassword &&
        other.companyId == companyId &&
        other.isAdmin == isAdmin;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        jobTitle.hashCode ^
        department.hashCode ^
        phone.hashCode ^
        nationalId.hashCode ^
        gender.hashCode ^
        password.hashCode ^
        confirmPassword.hashCode ^
        companyId.hashCode ^
        isAdmin.hashCode;
  }
}
