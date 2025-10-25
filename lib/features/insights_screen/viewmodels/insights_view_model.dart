import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:hodorak/features/insights_screen/models/daily_insight.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final insightsViewModelProvider =
    AsyncNotifierProvider<InsightsViewModel, List<DailyInsight>>(() {
      return InsightsViewModel();
    });

class InsightsViewModel extends AsyncNotifier<List<DailyInsight>> {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<DailyInsight>> build() async {
    return fetchInsights();
  }

  Future<List<DailyInsight>> fetchInsights() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('daily_insights')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: false);

      Logger.info('Fetched insights data: $response');

      final insights = (response as List)
          .map((data) => DailyInsight.fromJson(data))
          .toList();
      Logger.info('Parsed ${insights.length} insights');
      return insights;
    } catch (e) {
      Logger.error('Error fetching insights: $e');
      rethrow;
    }
  }

  // Helper methods for UI calculations
  int getPresentDays(List<DailyInsight> insights) {
    return insights.where((i) => i.status == 'present').length;
  }

  int getAbsentDays(List<DailyInsight> insights) {
    return insights.where((i) => i.status == 'absent').length;
  }

  double getTotalHours(List<DailyInsight> insights) {
    return insights.fold(0.0, (sum, i) => sum + i.totalHours);
  }

  double getAdherenceRate(List<DailyInsight> insights) {
    if (insights.isEmpty) return 0;
    int presentDays = getPresentDays(insights);
    return (presentDays / insights.length) * 100;
  }
}
