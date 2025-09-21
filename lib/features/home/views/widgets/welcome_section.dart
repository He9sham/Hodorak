import 'package:flutter/material.dart';

import 'package:hodorak/core/providers/login_notifier.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key, required this.session});
  final UserSession session;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            session.name ?? 'User',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.blue.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            'Role: ${session.isAdmin ? 'Administrator' : 'Employee'}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.blue.shade700),
          ),
        ],
      ),
    );
  }
}
