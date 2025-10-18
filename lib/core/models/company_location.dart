class CompanyLocation {
  final String id;
  final String companyId;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  const CompanyLocation({
    required this.id,
    required this.companyId,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CompanyLocation.fromJson(Map<String, dynamic> json) {
    return CompanyLocation(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  CompanyLocation copyWith({
    String? id,
    String? companyId,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return CompanyLocation(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CompanyLocation(id: $id, companyId: $companyId, latitude: $latitude, longitude: $longitude, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompanyLocation &&
        other.id == id &&
        other.companyId == companyId &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyId.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        createdAt.hashCode;
  }
}

