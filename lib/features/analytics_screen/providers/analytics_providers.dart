import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/attendance_stats.dart';
import '../services/analytics_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(Supabase.instance.client);
});

final weeklyStatsProvider = FutureProvider<WeeklyStats>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getWeeklyStats();
});

final dailyStatsProvider = FutureProvider.family<AttendanceStats, DateTime>((
  ref,
  date,
) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getDailyStats(date);
});
