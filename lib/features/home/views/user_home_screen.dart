import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/supabase_auth_provider.dart';
import 'package:hodorak/core/providers/supabase_monthly_summary_provider.dart';
import 'package:hodorak/features/home/views/widgets/attendance_buttons.dart';
import 'package:hodorak/features/home/views/widgets/build_drawer.dart';
import 'package:hodorak/features/home/views/widgets/geo_location.dart';
import 'package:hodorak/features/home/views/widgets/leave_status_display.dart';
import 'package:hodorak/features/home/views/widgets/quick_summary.dart';

class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(supabaseAuthProvider);
    final monthlySummaryState = ref.watch(
      supabaseCurrentMonthlySummaryProvider,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Hodorak',
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff8C9F5F),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Icon(Icons.notifications_active_outlined, size: 30.sp),
          horizontalSpace(8),
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Image.asset("assets/unsplash_CHqrLlwebdM.png", height: 33),
          ),
          horizontalSpace(10),
        ],
      ),
      drawer: buildDrawer(context, authState, ref),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              verticalSpace(17),
              AttendanceButtons(
                onLeaveRequestSubmitted: () {
                  // The LeaveStatusDisplay will automatically refresh via StreamBuilder
                },
              ),
              verticalSpace(16),
              authState.user?.id != null
                  ? LeaveStatusDisplay(userId: authState.user!.id)
                  : Container(
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        'Unable to load leave status. Please refresh the page.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
              verticalSpace(16),
              GeoLocation(),
              verticalSpace(16),
              QuickSummary(
                monthlySummary: monthlySummaryState.summary,
                currentUserId: authState.user?.id.hashCode,
              ),
              verticalSpace(16),
            ],
          ),
        ),
      ),
    );
  }
}
