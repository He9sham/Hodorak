import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/core.dart';

/// Main entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializationService.initialize();

  runApp(const ProviderScope(child: HodorakApp()));
}

/// Main application widget
class HodorakApp extends StatelessWidget {
  const HodorakApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create app with proper configuration
    return AppConfig.createApp(
      onGenerateRoute: AppConfig.appRouter.generateRoute,
    );
  }
}
