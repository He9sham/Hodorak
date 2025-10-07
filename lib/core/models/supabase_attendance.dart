class SupabaseAttendance {
  final String id;
  final String userId;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupabaseAttendance({
    required this.id,
    required this.userId,
    required this.checkIn,
    this.checkOut,
    this.location,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupabaseAttendance.fromJson(Map<String, dynamic> json) {
    return SupabaseAttendance(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      checkIn: DateTime.parse(json['check_in'] as String),
      checkOut: json['check_out'] != null
          ? DateTime.parse(json['check_out'] as String)
          : null,
      location: json['location'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isCheckedIn => checkOut == null;
  bool get isCheckedOut => checkOut != null;

  Duration? get workingDuration {
    if (checkOut != null) {
      return checkOut!.difference(checkIn);
    }
    return null;
  }

  SupabaseAttendance copyWith({
    String? id,
    String? userId,
    DateTime? checkIn,
    DateTime? checkOut,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupabaseAttendance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
