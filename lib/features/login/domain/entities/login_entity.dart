class LoginEntity {
  final String email;
  final String password;

  const LoginEntity({required this.email, required this.password});

  LoginEntity copyWith({String? email, String? password}) {
    return LoginEntity(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginEntity &&
        other.email == email &&
        other.password == password;
  }

  @override
  int get hashCode => email.hashCode ^ password.hashCode;

  @override
  String toString() => 'LoginEntity(email: $email, password: ***)';
}
