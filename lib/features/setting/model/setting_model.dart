/// Model class for settings data
/// Contains all the settings preferences and their default values
class SettingModel {
  /// Notification preference
  /// true = notifications enabled, false = notifications disabled
  final bool notificationsEnabled;

  /// App version
  final String appVersion;

  /// App name
  final String appName;

  /// Developer name
  final String developerName;

  const SettingModel({
    required this.notificationsEnabled,
    required this.appVersion,
    required this.appName,
    required this.developerName,
  });

  /// Create a copy of the model with updated values
  SettingModel copyWith({
    bool? notificationsEnabled,
    String? appVersion,
    String? appName,
    String? developerName,
  }) {
    return SettingModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      appVersion: appVersion ?? this.appVersion,
      appName: appName ?? this.appName,
      developerName: developerName ?? this.developerName,
    );
  }

  /// Convert model to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'appVersion': appVersion,
      'appName': appName,
      'developerName': developerName,
    };
  }

  /// Create model from JSON
  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      appVersion: json['appVersion'] ?? '1.0.0',
      appName: json['appName'] ?? 'Hodorak',
      developerName: json['developerName'] ?? 'Hesham Hamdan',
    );
  }

  /// Default settings model
  static const SettingModel defaultSettings = SettingModel(
    notificationsEnabled: true,
    appVersion: '1.0.0',
    appName: 'Hodorak',
    developerName: 'Hesham Hamdan',
  );

  @override
  String toString() {
    return 'SettingModel(notificationsEnabled: $notificationsEnabled, appVersion: $appVersion, appName: $appName, developerName: $developerName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingModel &&
        other.notificationsEnabled == notificationsEnabled &&
        other.appVersion == appVersion &&
        other.appName == appName &&
        other.developerName == developerName;
  }

  @override
  int get hashCode {
    return Object.hash(
      notificationsEnabled,
      appVersion,
      appName,
      developerName,
    );
  }
}
