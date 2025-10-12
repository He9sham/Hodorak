import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/firebase_options.dart';

import 'core/core.dart';

/// Main entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first (required for FCM)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Then initialize other services (including FirebaseMessagingService)
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
