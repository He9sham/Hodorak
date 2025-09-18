import 'package:flutter/material.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/auth/views/login_screen.dart';
import 'package:hodorak/features/auth/views/sign_up_screen.dart';
import 'package:hodorak/features/main_navigation/home_screen.dart';
import 'package:hodorak/features/main_navigation/admin_dashboard_screen.dart';
import 'package:hodorak/features/main_navigation/user_dashboard_screen.dart';
import 'package:hodorak/features/splash_screen/view/splash_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    //this arguments to be passed in any screen like this ( arguments as ClassName )

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
      case Routes.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case Routes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case Routes.userDashboard:
        return MaterialPageRoute(builder: (_) => const UserDashboardScreen());
      default:
        return null;
    }
  }
}
