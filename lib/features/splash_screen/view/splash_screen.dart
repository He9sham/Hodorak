import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/providers/auth_state_manager.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:hodorak/features/home/views/admin_home_screen.dart';
import 'package:hodorak/features/home/views/user_home_screen.dart';
import 'package:hodorak/features/login/login.dart';
import 'package:hodorak/features/splash_screen/view/widgets/splash_view.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Delay the provider modification until after the widget tree is built
    Future(() => _initializeAuth());
  }

  Future<void> _initializeAuth() async {
    try {
      await ref.read(authStateManagerProvider.notifier).initializeAuthState();
    } catch (e) {
      // Handle initialization error gracefully
      Logger.error('Auth initialization error: $e');
    }
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final authState = ref.watch(authStateManagerProvider);

    return AnimatedSplashScreen(
      backgroundColor: Colors.white,
      splash: SplashView(),
      nextScreen: _getNextScreen(authState),
      splashIconSize: 1000,
      duration: 2000, // Reduced duration to make transition faster
      splashTransition: SplashTransition.values[1],
      pageTransitionType: PageTransitionType.leftToRight,
      animationDuration: Duration(seconds: 1),
    );
  }

  Widget _getNextScreen(AuthState authState) {
    if (authState.isAuthenticated) {
      return authState.isAdmin
          ? const AdminHomeScreen()
          : const UserHomeScreen();
    }

    return const LoginScreen();
  }
}
