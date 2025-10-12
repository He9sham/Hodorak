import 'package:flutter/material.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/admin_calendar/admin_calendar_screen.dart';
import 'package:hodorak/features/admin_employee_management/presentation/widgets/employee_list_widget.dart';
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
        horizontalSpace(12),
        Expanded(
          child: buildActionCard(
            context,
            icon: Icons.location_on,
            title: 'Workplace Location',
            subtitle: 'Set workplace location',
            onTap: () {
              context.pushNamed(Routes.adminLocationScreen);
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
            icon: Icons.people_outline,
            title: 'Company Employees',
            subtitle: 'View & manage employees',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EmployeeListWidget(),
                ),
              );
            },
          ),
        ),
        horizontalSpace(12),
        Expanded(
          child: buildActionCard(
            context,
            icon: Icons.request_page_sharp,
            title: 'Leave Requests',
            subtitle: 'Review leave requests',
            onTap: () {
              context.pushNamed(Routes.adminLeaveRequestsScreen);
            },
          ),
        ),
      ],
    );
  }
}

class BuildItemCartRowFour extends StatelessWidget {
  const BuildItemCartRowFour({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: buildActionCard(
            context,
            icon: Icons.notifications_active,
            title: 'Notifications',
            subtitle: 'View employee activities',
            onTap: () {
              context.pushNamed(Routes.adminNotificationScreen);
            },
          ),
        ),
        horizontalSpace(12),
        const Expanded(child: SizedBox()), // Empty space for symmetry
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
            icon: Icons.people,
            title: 'User Management',
            subtitle: 'Manage users & passwords',
            onTap: () {
              context.pushNamed(Routes.adminUserManagementScreen);
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
              // Navigate to admin calendar screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdminCalendarScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
