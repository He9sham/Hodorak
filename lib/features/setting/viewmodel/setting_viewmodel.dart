import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/setting_model.dart';

/// Notifier for Settings screen using Riverpod
/// Manages the state of settings and handles persistence
class SettingNotifier extends Notifier<SettingModel> {
  bool _isLoading = false;
  String? _error;

  @override
  SettingModel build() {
    return SettingModel.defaultSettings;
  }

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Getter for error state
  String? get error => _error;

  /// Getter for theme mode
  bool get isDarkMode => state.isDarkMode;

  /// Getter for notification preference
  bool get notificationsEnabled => state.notificationsEnabled;

  /// Initialize settings by loading from SharedPreferences
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode preference
      final isDarkMode = prefs.getBool('isDarkMode') ?? false;

      // Load notification preference
      final notificationsEnabled =
          prefs.getBool('notificationsEnabled') ?? true;

      state = state.copyWith(
        isDarkMode: isDarkMode,
        notificationsEnabled: notificationsEnabled,
      );

      _error = null;
    } catch (e) {
      _error = 'Failed to load settings: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle theme mode between light and dark
  /// Saves the preference to SharedPreferences
  Future<void> toggleThemeMode() async {
    try {
      final newThemeMode = !state.isDarkMode;

      // Update local state
      state = state.copyWith(isDarkMode: newThemeMode);

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', newThemeMode);

      _error = null;
    } catch (e) {
      _error = 'Failed to save theme preference: $e';
    }
  }

  /// Toggle notification preference
  /// Saves the preference to SharedPreferences
  Future<void> toggleNotifications() async {
    try {
      final newNotificationSetting = !state.notificationsEnabled;

      // Update local state
      state = state.copyWith(notificationsEnabled: newNotificationSetting);

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationsEnabled', newNotificationSetting);

      _error = null;
    } catch (e) {
      _error = 'Failed to save notification preference: $e';
    }
  }

  /// Reset all settings to default values
  Future<void> resetToDefaults() async {
    try {
      state = SettingModel.defaultSettings;

      // Save default values to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', false);
      await prefs.setBool('notificationsEnabled', true);

      _error = null;
    } catch (e) {
      _error = 'Failed to reset settings: $e';
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
  }

  /// Private method to update loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  /// Get theme mode for Flutter's ThemeMode enum
  ThemeMode get themeMode {
    return state.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}

/// Provider for the SettingNotifier
final settingProvider = NotifierProvider<SettingNotifier, SettingModel>(
  SettingNotifier.new,
);
