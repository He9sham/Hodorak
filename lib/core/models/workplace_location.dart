class WorkplaceLocation {
  final double latitude;
  final double longitude;
  final String name;
  final double allowedRadius; // in meters
  final DateTime createdAt;
  final DateTime? updatedAt;

  const WorkplaceLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
    this.allowedRadius = 100.0, // Default 100 meters
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'allowedRadius': allowedRadius,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory WorkplaceLocation.fromJson(Map<String, dynamic> json) {
    return WorkplaceLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: json['name'] as String,
      allowedRadius: (json['allowedRadius'] as num?)?.toDouble() ?? 100.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  WorkplaceLocation copyWith({
    double? latitude,
    double? longitude,
    String? name,
    double? allowedRadius,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkplaceLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
      allowedRadius: allowedRadius ?? this.allowedRadius,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkplaceLocation(latitude: $latitude, longitude: $longitude, name: $name, allowedRadius: $allowedRadius)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkplaceLocation &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.name == name &&
        other.allowedRadius == allowedRadius;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^
        longitude.hashCode ^
        name.hashCode ^
        allowedRadius.hashCode;
  }
}
