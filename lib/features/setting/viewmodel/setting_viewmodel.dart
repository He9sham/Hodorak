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
  ThemeMode get themeMode => state.themeMode;

  /// Getter for theme mode index
  int get themeModeIndex => state.themeModeIndex;

  /// Getter for notification preference
  bool get notificationsEnabled => state.notificationsEnabled;

  /// Initialize settings by loading from SharedPreferences
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode preference (migrate from old boolean if needed)
      int themeModeIndex = prefs.getInt('themeModeIndex') ?? 0;

      // Migration: If old boolean exists, convert it
      if (prefs.containsKey('isDarkMode')) {
        final oldIsDarkMode = prefs.getBool('isDarkMode') ?? false;
        themeModeIndex = oldIsDarkMode ? 2 : 1; // 2 = dark, 1 = light
        // Remove old key and save new one
        await prefs.remove('isDarkMode');
        await prefs.setInt('themeModeIndex', themeModeIndex);
      }

      // Load notification preference
      final notificationsEnabled =
          prefs.getBool('notificationsEnabled') ?? true;

      state = state.copyWith(
        themeModeIndex: themeModeIndex,
        notificationsEnabled: notificationsEnabled,
      );

      _error = null;
    } catch (e) {
      _error = 'Failed to load settings: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Set theme mode
  /// Saves the preference to SharedPreferences
  Future<void> setThemeMode(int themeModeIndex) async {
    try {
      // Update local state
      state = state.copyWith(themeModeIndex: themeModeIndex);

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeModeIndex', themeModeIndex);

      _error = null;
    } catch (e) {
      _error = 'Failed to save theme preference: $e';
    }
  }

  /// Cycle through theme modes: System -> Light -> Dark -> System
  Future<void> cycleThemeMode() async {
    final newIndex = (state.themeModeIndex + 1) % 3;
    await setThemeMode(newIndex);
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
      await prefs.setInt('themeModeIndex', 0); // System theme
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
}

/// Provider for the SettingNotifier
final settingProvider = NotifierProvider<SettingNotifier, SettingModel>(
  SettingNotifier.new,
);
