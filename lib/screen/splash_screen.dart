import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hodorak/screen/login_screen.dart';
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

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: -120,
          top: -105,
          child: Container(
            height: 360,
            width: 360,
            decoration: BoxDecoration(
              color: Color(0xffF5BA3A),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 350,
          left: 100,
          child: Image.asset('assets/Hodorak.png', height: 150),
        ),
        Positioned(
          bottom: -120,
          right: -100,
          child: Container(
            height: 360,
            width: 360,
            decoration: BoxDecoration(
              color: Color(0xff8C9F5F),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
