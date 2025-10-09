import 'package:flutter/material.dart';

/// Model class for settings data
/// Contains all the settings preferences and their default values
class SettingModel {
  /// Theme mode preference
  /// 0 = system, 1 = light, 2 = dark
  final int themeModeIndex;

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
    required this.themeModeIndex,
    required this.notificationsEnabled,
    required this.appVersion,
    required this.appName,
    required this.developerName,
  });

  /// Create a copy of the model with updated values
  SettingModel copyWith({
    int? themeModeIndex,
    bool? notificationsEnabled,
    String? appVersion,
    String? appName,
    String? developerName,
  }) {
    return SettingModel(
      themeModeIndex: themeModeIndex ?? this.themeModeIndex,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      appVersion: appVersion ?? this.appVersion,
      appName: appName ?? this.appName,
      developerName: developerName ?? this.developerName,
    );
  }

  /// Convert model to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'themeModeIndex': themeModeIndex,
      'notificationsEnabled': notificationsEnabled,
      'appVersion': appVersion,
      'appName': appName,
      'developerName': developerName,
    };
  }

  /// Create model from JSON
  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      themeModeIndex: json['themeModeIndex'] ?? 0, // Default to system
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      appVersion: json['appVersion'] ?? '1.0.0',
      appName: json['appName'] ?? 'Hodorak',
      developerName: json['developerName'] ?? 'Hodorak Team',
    );
  }

  /// Default settings model
  static const SettingModel defaultSettings = SettingModel(
    themeModeIndex: 0, // Default to system theme
    notificationsEnabled: true,
    appVersion: '1.0.0',
    appName: 'Hodorak',
    developerName: 'Hodorak Team',
  );

  /// Get ThemeMode enum from index
  ThemeMode get themeMode {
    switch (themeModeIndex) {
      case 0:
        return ThemeMode.system;
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Get theme mode name for display
  String get themeModeName {
    switch (themeModeIndex) {
      case 0:
        return 'System';
      case 1:
        return 'Light';
      case 2:
        return 'Dark';
      default:
        return 'System';
    }
  }

  @override
  String toString() {
    return 'SettingModel(themeModeIndex: $themeModeIndex, notificationsEnabled: $notificationsEnabled, appVersion: $appVersion, appName: $appName, developerName: $developerName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingModel &&
        other.themeModeIndex == themeModeIndex &&
        other.notificationsEnabled == notificationsEnabled &&
        other.appVersion == appVersion &&
        other.appName == appName &&
        other.developerName == developerName;
  }

  @override
  int get hashCode {
    return Object.hash(
      themeModeIndex,
      notificationsEnabled,
      appVersion,
      appName,
      developerName,
    );
  }
}
