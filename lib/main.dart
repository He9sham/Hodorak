import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/services/service_locator.dart';
import 'package:hodorak/core/theming/colors_manger.dart';
import 'package:hodorak/core/utils/app_router.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupServiceLocator();
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
        onGenerateRoute: AppRouter().generateRoute,
        initialRoute: Routes.splashScreen,
      ),
    );
  }
}
