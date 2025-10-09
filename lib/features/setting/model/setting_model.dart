/// Model class for settings data
/// Contains all the settings preferences and their default values
class SettingModel {
  /// Theme mode preference
  /// true = dark mode, false = light mode
  final bool isDarkMode;

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
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.appVersion,
    required this.appName,
    required this.developerName,
  });

  /// Create a copy of the model with updated values
  SettingModel copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? appVersion,
    String? appName,
    String? developerName,
  }) {
    return SettingModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      appVersion: appVersion ?? this.appVersion,
      appName: appName ?? this.appName,
      developerName: developerName ?? this.developerName,
    );
  }

  /// Convert model to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'appVersion': appVersion,
      'appName': appName,
      'developerName': developerName,
    };
  }

  /// Create model from JSON
  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      isDarkMode: json['isDarkMode'] ?? false,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      appVersion: json['appVersion'] ?? '1.0.0',
      appName: json['appName'] ?? 'Hodorak',
      developerName: json['developerName'] ?? 'Hodorak Team',
    );
  }

  /// Default settings model
  static const SettingModel defaultSettings = SettingModel(
    isDarkMode: false,
    notificationsEnabled: true,
    appVersion: '1.0.0',
    appName: 'Hodorak',
    developerName: 'Hodorak Team',
  );

  @override
  String toString() {
    return 'SettingModel(isDarkMode: $isDarkMode, notificationsEnabled: $notificationsEnabled, appVersion: $appVersion, appName: $appName, developerName: $developerName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingModel &&
        other.isDarkMode == isDarkMode &&
        other.notificationsEnabled == notificationsEnabled &&
        other.appVersion == appVersion &&
        other.appName == appName &&
        other.developerName == developerName;
  }

  @override
  int get hashCode {
    return Object.hash(
      isDarkMode,
      notificationsEnabled,
      appVersion,
      appName,
      developerName,
    );
  }
}
