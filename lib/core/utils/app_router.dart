import 'package:flutter/material.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/admin_leave_requests/view/admin_leave_requests_screen.dart';
import 'package:hodorak/features/admin_location/views/admin_location_screen.dart';
import 'package:hodorak/features/auth/views/admin_password_reset_screen.dart';
import 'package:hodorak/features/auth/views/login_screen.dart';
import 'package:hodorak/features/auth/views/sign_up_screen.dart';
import 'package:hodorak/features/calender_screen/view/calendar_screen.dart';
import 'package:hodorak/features/home/views/admin_home_screen.dart';
import 'package:hodorak/features/home/views/user_home_screen.dart';
import 'package:hodorak/features/profile/view/profile_screen.dart';
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
      case Routes.userHomeScreen:
        return MaterialPageRoute(builder: (_) => const UserHomeScreen());
      case Routes.adminHomeScreen:
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      case Routes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case Routes.calendarScreen:
        return MaterialPageRoute(builder: (_) => const CalendarScreen());
      case Routes.adminPasswordResetScreen:
        return MaterialPageRoute(
          builder: (_) => const AdminPasswordResetScreen(),
        );
      case Routes.adminLeaveRequestsScreen:
        return MaterialPageRoute(
          builder: (_) => const AdminLeaveRequestsScreen(),
        );
      case Routes.adminLocationScreen:
        return MaterialPageRoute(builder: (_) => const AdminLocationScreen());
      default:
        return null;
    }
  }
}
