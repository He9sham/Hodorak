import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/core.dart';
import 'features/setting/setting.dart';

/// Main entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all required services
  await AppInitializationService.initialize();

  runApp(const ProviderScope(child: HodorakApp()));
}

/// Main application widget
class HodorakApp extends ConsumerWidget {
  const HodorakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the settings provider to get theme changes
    final settings = ref.watch(settingProvider);

    // Create app with proper configuration
    return AppConfig.createApp(
      themeMode: settings.themeMode,
      onGenerateRoute: AppConfig.appRouter.generateRoute,
    );
  }
}
