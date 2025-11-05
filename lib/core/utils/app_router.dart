import 'package:flutter/material.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/admin_calendar/admin_calendar_screen.dart';
import 'package:hodorak/features/admin_leave_requests/view/admin_leave_requests_screen.dart';
import 'package:hodorak/features/admin_location/views/admin_location_screen.dart';
import 'package:hodorak/features/analytics_screen/screens/analytics_screen.dart';
import 'package:hodorak/features/attendance_settings/views/attendance_settings_screen.dart';
import 'package:hodorak/features/calender_screen/view/calendar_screen.dart';
import 'package:hodorak/features/company_screen/company_creation_screen.dart';
import 'package:hodorak/features/home/views/admin_home_screen.dart';
import 'package:hodorak/features/home/views/user_home_screen.dart';
import 'package:hodorak/features/insights_screen/views/insights_page.dart';
import 'package:hodorak/features/login/login.dart';
import 'package:hodorak/features/notifications_screen/view/screens/admin_notification_screen.dart';
import 'package:hodorak/features/notifications_screen/view/screens/notification_screen.dart';
import 'package:hodorak/features/onboarding/onboarding_view.dart';
import 'package:hodorak/features/profile/view/profile_screen.dart';
import 'package:hodorak/features/setting/view/setting_screen.dart';
import 'package:hodorak/features/splash_screen/view/splash_screen.dart';
import 'package:hodorak/features/user_Management/views/admin_user_management_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    //this arguments to be passed in any screen like this ( arguments as ClassName )

    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.onBoardingScreen:
        return MaterialPageRoute(builder: (_) => const OnboardingView());
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.companyCreationScreen:
        return MaterialPageRoute(builder: (_) => const CompanyCreationScreen());
      case Routes.userHomeScreen:
        return MaterialPageRoute(builder: (_) => const UserHomeScreen());
      case Routes.adminHomeScreen:
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      case Routes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case Routes.calendarScreen:
        return MaterialPageRoute(builder: (_) => const CalendarScreen());
      case Routes.settingScreen:
        return MaterialPageRoute(builder: (_) => const SettingScreen());
      case Routes.notificationScreen:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case Routes.adminNotificationScreen:
        return MaterialPageRoute(
          builder: (_) => const AdminNotificationScreen(),
        );
      case Routes.adminLeaveRequestsScreen:
        return MaterialPageRoute(
          builder: (_) => const AdminLeaveRequestsScreen(),
        );
      case Routes.adminLocationScreen:
        return MaterialPageRoute(builder: (_) => const AdminLocationScreen());
      case Routes.adminUserManagementScreen:
        return MaterialPageRoute(
          builder: (_) => const AdminUserManagementScreen(),
        );
      case Routes.adminCalendarScreen:
        return MaterialPageRoute(builder: (_) => const AdminCalendarScreen());
      case Routes.insightsScreen:
        return MaterialPageRoute(builder: (_) => const InsightsPage());
      case Routes.analyticsScreen:
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());
      case Routes.attendanceSettings:
        return MaterialPageRoute(
          builder: (_) => const AttendanceSettingsScreen(),
        );
      default:
        return null;
    }
  }
}
