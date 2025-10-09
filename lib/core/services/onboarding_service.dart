import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding state
class OnboardingService {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  /// Check if user has seen onboarding before
  Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_hasSeenOnboardingKey) ?? false;
    } catch (e) {
      // If there's an error, assume they haven't seen it
      return false;
    }
  }

  /// Mark onboarding as completed
  Future<void> markOnboardingAsSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasSeenOnboardingKey, true);
    } catch (e) {
      // Handle error silently
      rethrow;
    }
  }

  /// Reset onboarding state (useful for testing)
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_hasSeenOnboardingKey);
    } catch (e) {
      // Handle error silently
      rethrow;
    }
  }
}
