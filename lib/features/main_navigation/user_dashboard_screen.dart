import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/providers/login_notifier.dart';
import 'package:hodorak/core/utils/routes.dart';

class UserDashboardScreen extends ConsumerWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(loginNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('User Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UID: ${session.uid ?? '-'}'),
            Text('Role: ${session.isAdmin ? 'Admin' : 'User'}'),
            Text("Email: ${session.name ?? ''}"),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                ref.read(loginNotifierProvider.notifier).logout();
                context.pushReplacementNamed(Routes.loginScreen);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
