class PasswordResetRequest {
  final String userEmail;
  final String newPassword;

  const PasswordResetRequest({
    required this.userEmail,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'userEmail': userEmail, 'newPassword': newPassword};
  }
}
