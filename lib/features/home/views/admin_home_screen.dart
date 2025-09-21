import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/login_notifier.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/home/views/widgets/build_item_cart.dart';
import 'package:hodorak/features/home/views/widgets/recent_activity.dart';
import 'package:hodorak/features/home/views/widgets/welcome_section.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(loginNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hodorak'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(loginNotifierProvider.notifier).logout();
              context.pushReplacementNamed(Routes.loginScreen);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            WelcomeSection(session: session),
            verticalSpace(24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            verticalSpace(16),

            // Action Cards Row One
            BuildItemCartRowOne(),
            verticalSpace(12),

            // Action Cards Row two
            BuildItemCartRowTwo(),
            verticalSpace(12),

            // Action Cards Row three
            BuildItemCartRowThree(),
            verticalSpace(24),

            // Recent Activity (placeholder)
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            verticalSpace(16),

            // recent activity
            RecentActivity(title: 'No recent activity'),
          ],
        ),
      ),
    );
  }
}
