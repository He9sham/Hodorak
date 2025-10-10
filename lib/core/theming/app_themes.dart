import 'package:flutter/material.dart';

import 'colors_manger.dart';

/// Application theme configuration
/// Contains light theme configuration
class AppThemes {
  /// Light theme configuration
  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorsManager.kprimarycolorauth,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    // Text theme - explicit text colors for light mode
    textTheme: _lightTextTheme,
    // AppBar theme - light background with dark text
    appBarTheme: _lightAppBarTheme,
    // Card theme - light background with dark text
    cardTheme: _lightCardTheme,
    // Scaffold background
    scaffoldBackgroundColor: Colors.grey[50],
    // Button themes
    filledButtonTheme: _lightFilledButtonTheme,
    elevatedButtonTheme: _lightElevatedButtonTheme,
    textButtonTheme: _lightTextButtonTheme,
    // Drawer theme - light background
    drawerTheme: _lightDrawerTheme,
    // List tile theme - light background with dark text
    listTileTheme: _lightListTileTheme,
    // Icon theme - primary color
    iconTheme: _lightIconTheme,
    // Bottom navigation bar theme - light background with dark text
    bottomNavigationBarTheme: _lightBottomNavigationBarTheme,
    // Divider theme - darker divider for light mode
    dividerTheme: _lightDividerTheme,
    // Switch theme - custom colors for light mode
    switchTheme: _lightSwitchTheme,
    // Dropdown button theme - dark text
    dropdownMenuTheme: _lightDropdownMenuTheme,
  );

  // Light Theme Components
  static TextTheme get _lightTextTheme => TextTheme(
    // Headlines
    headlineLarge: TextStyle(color: Colors.black87),
    headlineMedium: TextStyle(color: Colors.black87),
    headlineSmall: TextStyle(color: Colors.black87),
    // Titles
    titleLarge: TextStyle(color: Colors.black87),
    titleMedium: TextStyle(color: Colors.black87),
    titleSmall: TextStyle(color: Colors.black87),
    // Body text
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
    bodySmall: TextStyle(color: Colors.black54),
    // Labels
    labelLarge: TextStyle(color: Colors.black87),
    labelMedium: TextStyle(color: Colors.black87),
    labelSmall: TextStyle(color: Colors.black54),
    // Display text
    displayLarge: TextStyle(color: Colors.black87),
    displayMedium: TextStyle(color: Colors.black87),
    displaySmall: TextStyle(color: Colors.black87),
  );

  static AppBarTheme get _lightAppBarTheme => AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.black87,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
  );

  static CardThemeData get _lightCardTheme => CardThemeData(
    color: Colors.white,
    elevation: 2,
    shadowColor: Colors.grey.withValues(alpha: 0.3),
  );

  static FilledButtonThemeData get _lightFilledButtonTheme =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ColorsManager.kprimarycolorauth,
          foregroundColor: Colors.white,
        ),
      );

  static ElevatedButtonThemeData get _lightElevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsManager.kprimarycolorauth,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      );

  static TextButtonThemeData get _lightTextButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.black87),
  );

  static DrawerThemeData get _lightDrawerTheme =>
      DrawerThemeData(backgroundColor: Colors.white);

  static ListTileThemeData get _lightListTileTheme => ListTileThemeData(
    tileColor: Colors.white,
    iconColor: ColorsManager.kprimarycolorauth,
    titleTextStyle: TextStyle(color: Colors.black87),
    subtitleTextStyle: TextStyle(color: Colors.black54),
  );

  static IconThemeData get _lightIconTheme =>
      IconThemeData(color: ColorsManager.kprimarycolorauth);

  static BottomNavigationBarThemeData get _lightBottomNavigationBarTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ColorsManager.kprimarycolorauth,
        unselectedItemColor: Colors.grey,
      );

  static DividerThemeData get _lightDividerTheme =>
      DividerThemeData(color: Colors.grey[300], thickness: 1);

  static SwitchThemeData get _lightSwitchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorsManager.kprimarycolorauth;
      }
      return Colors.grey[400]!;
    }),
    trackColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorsManager.kprimarycolorauth.withValues(alpha: 0.5);
      }
      return Colors.grey[300]!;
    }),
  );

  static DropdownMenuThemeData get _lightDropdownMenuTheme =>
      DropdownMenuThemeData(
        textStyle: TextStyle(color: Colors.black87),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
        ),
      );
}
