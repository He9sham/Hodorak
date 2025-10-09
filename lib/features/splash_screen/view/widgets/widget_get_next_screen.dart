import 'package:flutter/material.dart';
import 'package:hodorak/core/providers/supabase_auth_provider.dart';
import 'package:hodorak/features/home/views/admin_home_screen.dart';
import 'package:hodorak/features/home/views/user_home_screen.dart';
import 'package:hodorak/features/login/login.dart';
import 'package:hodorak/features/onboarding/onboarding_view.dart';

Widget getNextScreen(SupabaseAuthState authState, bool hasSeenOnboarding) {
  // If user is authenticated, show appropriate home screen
  if (authState.isAuthenticated) {
    return authState.isAdmin ? const AdminHomeScreen() : const UserHomeScreen();
  }
  if (!hasSeenOnboarding) {
    return const OnboardingView();
  }
  return const LoginScreen();
}
