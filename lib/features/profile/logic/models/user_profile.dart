class UserProfile {
  final String name;
  final String jobTitle;
  final String department;
  final String? profileImage;

  UserProfile({
    required this.name,
    required this.jobTitle,
    required this.department,
    this.profileImage,
  });
}
