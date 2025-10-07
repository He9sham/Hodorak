import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUser {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? nationalId;
  final String? department;
  final String? jobTitle;
  final String? gender;
  final bool isAdmin;
  final String? companyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupabaseUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.nationalId,
    this.department,
    this.jobTitle,
    this.gender,
    required this.isAdmin,
    this.companyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupabaseUser.fromJson(Map<String, dynamic> json) {
    return SupabaseUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      nationalId: json['national_id'] as String?,
      department: json['department'] as String?,
      jobTitle: json['job_title'] as String?,
      gender: json['gender'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      companyId: json['company_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'national_id': nationalId,
      'department': department,
      'job_title': jobTitle,
      'gender': gender,
      'is_admin': isAdmin,
      'company_id': companyId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SupabaseUser.fromAuthUser(User user, Map<String, dynamic> metadata) {
    return SupabaseUser(
      id: user.id,
      email: user.email ?? '',
      name: metadata['name'] ?? '',
      phone: metadata['phone'],
      nationalId: metadata['national_id'],
      department: metadata['department'],
      jobTitle: metadata['job_title'],
      gender: metadata['gender'],
      isAdmin: metadata['is_admin'] ?? false,
      companyId: metadata['company_id'],
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.now(),
    );
  }

  SupabaseUser copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? nationalId,
    String? department,
    String? jobTitle,
    String? gender,
    bool? isAdmin,
    String? companyId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupabaseUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      department: department ?? this.department,
      jobTitle: jobTitle ?? this.jobTitle,
      gender: gender ?? this.gender,
      isAdmin: isAdmin ?? this.isAdmin,
      companyId: companyId ?? this.companyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
