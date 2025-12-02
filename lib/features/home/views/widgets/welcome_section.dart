import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/notification_provider.dart';
import 'package:hodorak/core/providers/supabase_auth_provider.dart';
import 'package:hodorak/core/providers/supabase_daily_summary_provider.dart';
import 'package:hodorak/features/admin_leave_requests/providers/admin_leave_providers.dart';
import 'package:hodorak/features/home/views/widgets/build_state_widgets.dart';

class WelcomeSection extends ConsumerWidget {
  const WelcomeSection({super.key, required this.authState});
  final SupabaseAuthState authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the providers for real-time data
    final dailySummary = ref.watch(supabaseCurrentDailySummaryProvider);
    final leaveRequests = ref.watch(leaveRequestsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    // Extract counts
    String pendingRequestsCount = '0';
    String notificationsCount = '0';
    String absencesCount = '0';

    // Get pending leave requests (status == 'pending')
    leaveRequests.whenData((requests) {
      pendingRequestsCount = requests
          .where((r) => r.status == 'pending')
          .length
          .toString();
    });

    // Get notifications count from provider
    notificationsCount = unreadCount.toString();

    // Get absences count from daily summary
    if (dailySummary.summary != null) {
      absencesCount = dailySummary.summary!.absentEmployees.toString();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade700.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${authState.user?.name ?? 'Manager'}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24.sp,
                  letterSpacing: 0.5,
                ),
              ),
              verticalSpace(4),
              Text(
                'You have 3 pending items requiring your attention',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
        verticalSpace(20),

        // Quick Stats Dashboard
        Text(
          'Quick Stats',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: Colors.grey.shade800,
          ),
        ),
        verticalSpace(12),
        buildStatsCards(
          context,
          pendingRequestsCount: pendingRequestsCount,
          notificationsCount: notificationsCount,
          absencesCount: absencesCount,
        ),
      ],
    );
  }
}
