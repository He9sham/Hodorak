import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/notification_provider.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/admin_employee_management/presentation/widgets/employee_list_widget.dart';
import 'package:hodorak/features/admin_leave_requests/providers/admin_leave_providers.dart';
import 'package:hodorak/features/home/views/widgets/build_action_card.dart';

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
            colorIndex: 0,
          ),
        ),
        horizontalSpace(12),
        Expanded(
          child: buildActionCard(
            context,
            icon: Icons.calendar_today,
            title: 'Calendar',
            subtitle: 'View your schedule',
            onTap: () {
              context.pushNamed(Routes.adminCalendarScreen);
            },
            colorIndex: 1,
          ),
        ),
      ],
    );
  }
}

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
            colorIndex: 2,
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
            colorIndex: 3,
          ),
        ),
      ],
    );
  }
}

class BuildItemCartRowThree extends ConsumerWidget {
  const BuildItemCartRowThree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch leave requests provider to show badge when there are pending approvals
    final leaveRequests = ref.watch(leaveRequestsProvider);

    // Calculate if there are pending requests
    bool hasPendingApprovals = false;
    leaveRequests.whenData((requests) {
      hasPendingApprovals = requests.any((r) => r.status == 'pending');
    });

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
            colorIndex: 4,
          ),
        ),
        horizontalSpace(12),
        Expanded(
          child: buildActionCard(
            context,
            icon: Icons.assignment_turned_in,
            title: 'Pending Approvals',
            subtitle: 'Review pending actions',
            onTap: () {
              context.pushNamed(Routes.adminLeaveRequestsScreen);
            },
            colorIndex: 6,
            showBadge: hasPendingApprovals,
          ),
        ),
      ],
    );
  }
}

class BuildItemCartRowFour extends ConsumerWidget {
  const BuildItemCartRowFour({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Row(
      children: [
        Expanded(
          child: buildActionCard(
            context,
            icon: Icons.notifications_active,
            title: 'Notifications',
            subtitle: 'View employee activities',
            showBadge: unreadCount > 0,
            onTap: () {
              context.pushNamed(Routes.adminNotificationScreen);
            },
            colorIndex: 5,
          ),
        ),
        horizontalSpace(12),
        Expanded(
          child: buildActionCard(
            context,
            icon: Icons.timer_outlined,
            title: 'Attendance Settings',
            subtitle: 'Set attendance time thresholds',
            onTap: () {
              context.pushNamed(Routes.attendanceSettings);
            },
            colorIndex: 7,
          ),
        ),
      ],
    );
  }
}
