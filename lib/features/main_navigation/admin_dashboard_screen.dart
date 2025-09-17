import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/providers/login_notifier.dart';
import 'package:hodorak/core/utils/routes.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(loginNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UID: ${session.uid ?? '-'}'),
            const SizedBox(height: 8),
            const Text('Role: Admin'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.signupScreen),
              icon: const Icon(Icons.person_add),
              label: const Text('Create Employee'),
            ),
            const SizedBox(height: 12),
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
