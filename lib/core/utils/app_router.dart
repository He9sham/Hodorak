import 'package:flutter/material.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/login_screen/views/login_screen.dart';
import 'package:hodorak/features/login_screen/views/sign_up_screen.dart';
import 'package:hodorak/features/splash_screen/view/splash_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    //this arguments to be passed in any screen like this ( arguments as ClassName )
    final arguments = settings.arguments;

    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      // case Routes.onBoardingScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => const OnboardingView(),
      //   );
      case Routes.signupScreen:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      default:
        return null;
    }
  }
}
