import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_constants.dart';
import '../theming/app_themes.dart';
import '../utils/app_router.dart';
import '../utils/routes.dart';

/// Application configuration and setup
class AppConfig {
  /// Default design size for screen util
  static const Size defaultDesignSize = Size(375, 812);

  /// App title
  static const String appTitle = AppConstants.appTitle;

  /// Default route
  static const String defaultRoute = Routes.splashScreen;

  /// Create MaterialApp with proper configuration
  static Widget createApp({
    required ThemeMode themeMode,
    required Route<dynamic>? Function(RouteSettings) onGenerateRoute,
    bool debugShowCheckedModeBanner = false,
  }) {
    return ScreenUtilInit(
      designSize: defaultDesignSize,
      child: MaterialApp(
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        title: appTitle,
        themeMode: themeMode,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        onGenerateRoute: onGenerateRoute,
        initialRoute: defaultRoute,
      ),
    );
  }

  /// Get app router instance
  static AppRouter get appRouter => AppRouter();
}
