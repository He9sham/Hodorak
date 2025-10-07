class CompanyCreationModel {
  final String companyName;
  final String? description;
  final String? phone;
  final String? email;
  final String adminName;
  final String adminEmail;
  final String adminPassword;

  const CompanyCreationModel({
    required this.companyName,
    this.description,
    this.phone,
    this.email,
    required this.adminName,
    required this.adminEmail,
    required this.adminPassword,
  });

  CompanyCreationModel copyWith({
    String? companyName,
    String? description,
    String? phone,
    String? email,
    String? adminName,
    String? adminEmail,
    String? adminPassword,
  }) {
    return CompanyCreationModel(
      companyName: companyName ?? this.companyName,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      adminName: adminName ?? this.adminName,
      adminEmail: adminEmail ?? this.adminEmail,
      adminPassword: adminPassword ?? this.adminPassword,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'description': description,
      'phone': phone,
      'email': email,
      'adminName': adminName,
      'adminEmail': adminEmail,
      'adminPassword': adminPassword,
    };
  }

  factory CompanyCreationModel.fromJson(Map<String, dynamic> json) {
    return CompanyCreationModel(
      companyName: json['companyName'] ?? '',
      description: json['description'],
      phone: json['phone'],
      email: json['email'],
      adminName: json['adminName'] ?? '',
      adminEmail: json['adminEmail'] ?? '',
      adminPassword: json['adminPassword'] ?? '',
    );
  }

  @override
  String toString() {
    return 'CompanyCreationModel(companyName: $companyName, description: $description, phone: $phone, email: $email, adminName: $adminName, adminEmail: $adminEmail, adminPassword: [HIDDEN])';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompanyCreationModel &&
        other.companyName == companyName &&
        other.description == description &&
        other.phone == phone &&
        other.email == email &&
        other.adminName == adminName &&
        other.adminEmail == adminEmail &&
        other.adminPassword == adminPassword;
  }

  @override
  int get hashCode {
    return companyName.hashCode ^
        description.hashCode ^
        phone.hashCode ^
        email.hashCode ^
        adminName.hashCode ^
        adminEmail.hashCode ^
        adminPassword.hashCode;
  }
}
