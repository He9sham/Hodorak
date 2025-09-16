import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/theming/colors_manger.dart';
import 'package:hodorak/features/splash_screen/view/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: const Hodorak()));
}

class Hodorak extends StatelessWidget {
  const Hodorak({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hodorak Attendance',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: ColorsManager.kprimarycolorauth,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
