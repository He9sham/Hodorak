import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/auth_state_manager.dart';
import 'package:hodorak/core/providers/daily_summary_provider.dart';
import 'package:hodorak/features/home/views/widgets/attendance_buttons.dart';
import 'package:hodorak/features/home/views/widgets/build_drawer.dart';
import 'package:hodorak/features/home/views/widgets/geo_location.dart';
import 'package:hodorak/features/home/views/widgets/quick_summary.dart';

class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateManagerProvider);
    final dailySummaryState = ref.watch(currentDailySummaryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Hodorak',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff8C9F5F),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Icon(Icons.notifications_active_outlined, size: 30),
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
              AttendanceButtons(),
              verticalSpace(16),
              GeoLocation(),
              verticalSpace(16),
              QuickSummary(
                attendanceSummary: dailySummaryState.summary,
                currentUserId: authState.uid,
              ),
              verticalSpace(16),
            ],
          ),
        ),
      ),
    );
  }
}
