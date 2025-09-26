import 'package:flutter/material.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/home/views/widgets/build_action_card.dart';

class BuildItemCartRowTwo extends StatelessWidget {
  const BuildItemCartRowTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: buildActionCard(
            context,
            icon: Icons.person,
            title: 'Profile',
            subtitle: 'Manage your profile',
            onTap: () {
              // Navigate to profile screen
              context.pushNamed(Routes.profile);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildActionCard(
            context,
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App preferences',
            onTap: () {
              // Navigate to settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings feature coming soon!')),
              );
            },
          ),
        ),
      ],
    );
  }
}

class BuildItemCartRowThree extends StatelessWidget {
  const BuildItemCartRowThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: buildActionCard(
            context,
            icon: Icons.person_add,
            title: 'Add Employee',
            subtitle: 'Add new employee',
            onTap: () {
              context.pushReplacementNamed(Routes.signupScreen);
            },
          ),
        ),
        horizontalSpace(12),
        Expanded(
          child: buildActionCard(
            context,
            icon: Icons.request_page_sharp,
            title: 'Requests',
            subtitle: 'Requests employees',
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class BuildItemCartRowOne extends StatelessWidget {
  const BuildItemCartRowOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: buildActionCard(
            context,
            icon: Icons.access_time,
            title: 'Attendance',
            subtitle: 'Mark your attendance',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Attendance feature coming soon!'),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildActionCard(
            context,
            icon: Icons.calendar_today,
            title: 'Calendar',
            subtitle: 'View your schedule',
            onTap: () {
              // Navigate to calendar screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calendar feature coming soon!')),
              );
            },
          ),
        ),
      ],
    );
  }
}
