import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/providers/supabase_auth_provider.dart';
import 'package:hodorak/core/services/service_locator.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:hodorak/features/splash_screen/view/widgets/splash_view.dart';
import 'package:hodorak/features/splash_screen/view/widgets/widget_get_next_screen.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isInitialized = false;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    // Delay the provider modification until after the widget tree is built
    Future(() => _initialize());
  }

  Future<void> _initialize() async {
    try {
      // Check if user has seen onboarding
      _hasSeenOnboarding = await onboardingService.hasSeenOnboarding();

      // Initialize auth state
      await ref.read(supabaseAuthProvider.notifier).initializeAuthState();
    } catch (e) {
      // Handle initialization error gracefully
      Logger.error('Initialization error: $e');
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
    final authState = ref.watch(supabaseAuthProvider);
    return AnimatedSplashScreen(
      backgroundColor: Colors.white,
      splash: SplashView(),
      nextScreen: getNextScreen(authState, _hasSeenOnboarding),
      splashIconSize: 1000,
      duration: 2000, // Reduced duration to make transition faster
      splashTransition: SplashTransition.values[1],
      pageTransitionType: PageTransitionType.leftToRight,
      animationDuration: Duration(seconds: 1),
    );
  }
}
