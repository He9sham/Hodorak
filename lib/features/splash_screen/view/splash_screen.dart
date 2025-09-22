import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/providers/auth_state_manager.dart';
import 'package:hodorak/features/auth/views/login_screen.dart';
import 'package:hodorak/features/home/views/admin_home_screen.dart';
import 'package:hodorak/features/home/views/user_home_screen.dart';
import 'package:hodorak/features/splash_screen/view/widgets/splash_view.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final authState = ref.watch(authStateManagerProvider);

    return AnimatedSplashScreen(
      backgroundColor: Colors.white,
      splash: SplashView(),
      nextScreen: LoginScreen(),
      // nextScreen: _getNextScreen(authState),
      splashIconSize: 1000,
      duration: 4000,
      splashTransition: SplashTransition.values[1],
      pageTransitionType: PageTransitionType.leftToRight,
      animationDuration: Duration(seconds: 1),
    );
  }

  // Widget _getNextScreen(AuthState authState) {
  //   if (authState.isAuthenticated) {
  //     return authState.isAdmin
  //         ? const AdminHomeScreen()
  //         : const UserHomeScreen();
  //   }

  //   return const LoginScreen();
  // }
}
