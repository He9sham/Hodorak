import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hodorak/features/auth/views/login_screen.dart';
import 'package:hodorak/features/splash_screen/view/widgets/splash_view.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: Colors.white,
      splash: SplashView(),
      nextScreen: const LoginScreen(),
      splashIconSize: 1000,
      duration: 4000,
      splashTransition: SplashTransition.values[1],
      pageTransitionType: PageTransitionType.leftToRight,
      animationDuration: Duration(seconds: 1),
    );
  }
}
