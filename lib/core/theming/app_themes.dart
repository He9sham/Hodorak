import 'package:flutter/material.dart';

import 'colors_manger.dart';

/// Application themes configuration
/// Contains light and dark theme configurations
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

  /// Dark theme configuration
  static ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorsManager.kprimarycolorauth,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    // Text theme - explicit text colors for dark mode
    textTheme: _darkTextTheme,
    // AppBar theme - dark background with white text
    appBarTheme: _darkAppBarTheme,
    // Card theme - dark background with white text
    cardTheme: _darkCardTheme,
    // Scaffold background - dark
    scaffoldBackgroundColor: Colors.grey[900],
    // Button themes
    filledButtonTheme: _darkFilledButtonTheme,
    elevatedButtonTheme: _darkElevatedButtonTheme,
    textButtonTheme: _darkTextButtonTheme,
    // Drawer theme - dark background
    drawerTheme: _darkDrawerTheme,
    // List tile theme - dark background with white text
    listTileTheme: _darkListTileTheme,
    // Icon theme - keep primary color
    iconTheme: _darkIconTheme,
    // Bottom navigation bar theme - dark background with white text
    bottomNavigationBarTheme: _darkBottomNavigationBarTheme,
    // Divider theme - lighter divider for dark mode
    dividerTheme: _darkDividerTheme,
    // Switch theme - custom colors for dark mode
    switchTheme: _darkSwitchTheme,
    // Dropdown button theme - white text
    dropdownMenuTheme: _darkDropdownMenuTheme,
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
    shadowColor: Colors.grey.withOpacity(0.3),
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
    thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return ColorsManager.kprimarycolorauth;
      }
      return Colors.grey[400]!;
    }),
    trackColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return ColorsManager.kprimarycolorauth.withOpacity(0.5);
      }
      return Colors.grey[300]!;
    }),
  );

  static DropdownMenuThemeData get _lightDropdownMenuTheme =>
      DropdownMenuThemeData(
        textStyle: TextStyle(color: Colors.black87),
        menuStyle: MenuStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
        ),
      );

  // Dark Theme Components
  static TextTheme get _darkTextTheme => TextTheme(
    // Headlines
    headlineLarge: TextStyle(color: Colors.white),
    headlineMedium: TextStyle(color: Colors.white),
    headlineSmall: TextStyle(color: Colors.white),
    // Titles
    titleLarge: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
    titleSmall: TextStyle(color: Colors.white),
    // Body text
    bodyLarge: TextStyle(color: Colors.grey[300]),
    bodyMedium: TextStyle(color: Colors.grey[300]),
    bodySmall: TextStyle(color: Colors.grey[400]),
    // Labels
    labelLarge: TextStyle(color: Colors.white),
    labelMedium: TextStyle(color: Colors.grey[300]),
    labelSmall: TextStyle(color: Colors.grey[400]),
    // Display text
    displayLarge: TextStyle(color: Colors.white),
    displayMedium: TextStyle(color: Colors.white),
    displaySmall: TextStyle(color: Colors.white),
  );

  static AppBarTheme get _darkAppBarTheme => AppBarTheme(
    backgroundColor: Colors.grey[900],
    foregroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
  );

  static CardThemeData get _darkCardTheme => CardThemeData(
    color: Colors.grey[850],
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.3),
  );

  static FilledButtonThemeData get _darkFilledButtonTheme =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ColorsManager.kprimarycolorauth,
          foregroundColor: Colors.white,
        ),
      );

  static ElevatedButtonThemeData get _darkElevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsManager.kprimarycolorauth,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      );

  static TextButtonThemeData get _darkTextButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.white),
  );

  static DrawerThemeData get _darkDrawerTheme =>
      DrawerThemeData(backgroundColor: Colors.grey[850]);

  static ListTileThemeData get _darkListTileTheme => ListTileThemeData(
    tileColor: Colors.grey[850],
    iconColor: ColorsManager.kprimarycolorauth,
    titleTextStyle: TextStyle(color: Colors.white),
    subtitleTextStyle: TextStyle(color: Colors.grey[300]),
  );

  static IconThemeData get _darkIconTheme =>
      IconThemeData(color: ColorsManager.kprimarycolorauth);

  static BottomNavigationBarThemeData get _darkBottomNavigationBarTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: Colors.grey[900],
        selectedItemColor: ColorsManager.kprimarycolorauth,
        unselectedItemColor: Colors.grey[400],
      );

  static DividerThemeData get _darkDividerTheme =>
      DividerThemeData(color: Colors.grey[700], thickness: 1);

  static SwitchThemeData get _darkSwitchTheme => SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return ColorsManager.kprimarycolorauth;
      }
      return Colors.grey[600]!;
    }),
    trackColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return ColorsManager.kprimarycolorauth.withOpacity(0.5);
      }
      return Colors.grey[700]!;
    }),
  );

  static DropdownMenuThemeData get _darkDropdownMenuTheme =>
      DropdownMenuThemeData(
        textStyle: TextStyle(color: Colors.white),
        menuStyle: MenuStyle(
          backgroundColor: MaterialStateProperty.all(Colors.grey[850]),
        ),
      );
}
