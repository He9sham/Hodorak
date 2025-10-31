class AttendanceSettings {
  final String id;
  final String companyId;
  final int thresholdMinutes; // Store as minutes from midnight
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceSettings({
    required this.id,
    required this.companyId,
    required this.thresholdMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'threshold_minutes': thresholdMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AttendanceSettings.fromJson(Map<String, dynamic> json) {
    return AttendanceSettings(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      thresholdMinutes: json['threshold_minutes'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}