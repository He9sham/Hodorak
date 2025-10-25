import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Models
class DailyInsight {
  final String id;
  final String userId;
  final DateTime date;
  final double totalHours;
  final String status;
  final String notes;

  DailyInsight({
    required this.id,
    required this.userId,
    required this.date,
    required this.totalHours,
    required this.status,
    required this.notes,
  });

  factory DailyInsight.fromJson(Map<String, dynamic> json) {
    Logger.info('Processing insight data: $json'); // Debug print
    try {
      return DailyInsight(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        date: DateTime.parse(json['date']),
        totalHours: (json['total_hours'] ?? 0.0).toDouble(),
        status: json['status']?.toString() ?? 'absent',
        notes: json['notes']?.toString() ?? '',
      );
    } catch (e) {
      Logger.error('Error parsing insight: $e'); // Debug print
      rethrow;
    }
  }
}

// Provider
final insightsProvider =
    AsyncNotifierProvider<InsightsNotifier, List<DailyInsight>>(() {
      return InsightsNotifier();
    });

class InsightsNotifier extends AsyncNotifier<List<DailyInsight>> {
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

      // Query directly from the daily_insights table
      final response = await _supabase
          .from('daily_insights')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: false);

      Logger.info('Fetched insights data: $response'); // Debug print

      final insights = (response as List)
          .map((data) => DailyInsight.fromJson(data))
          .toList();
      Logger.info('Parsed ${insights.length} insights'); // Debug print
      return insights;
    } catch (e) {
      Logger.error('Error fetching insights: $e'); // Debug print
      rethrow;
    }
  }
}

// UI Components
class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Daily Insights'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(insightsProvider);
            },
          ),
        ],
      ),
      body: insightsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            error.toString(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (insights) {
          // Calculate statistics
          int presentDays = insights.where((i) => i.status == 'present').length;
          int absentDays = insights.where((i) => i.status == 'absent').length;
          double totalHours = insights.fold(
            0.0,
            (sum, i) => sum + i.totalHours,
          );
          double adherenceRate = insights.isEmpty
              ? 0
              : (presentDays / insights.length) * 100;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Hours This Month',
                              value: '${totalHours.toStringAsFixed(1)}h',
                              icon: Icons.access_time,
                              color: const Color(0xFFFFD54F),
                            ),
                          ),
                          horizontalSpace(16),
                          Expanded(
                            child: _StatCard(
                              title: 'Days Present',
                              value: presentDays.toString(),
                              icon: Icons.check_circle_outline,
                              color: const Color(0xFF81C784),
                            ),
                          ),
                        ],
                      ),
                      verticalSpace(16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Days Absent',
                              value: absentDays.toString(),
                              icon: Icons.cancel_outlined,
                              color: const Color(0xFFE57373),
                            ),
                          ),
                          horizontalSpace(16),
                          Expanded(
                            child: _StatCard(
                              title: 'Adherence',
                              value: '${adherenceRate.toStringAsFixed(0)}%',
                              icon: Icons.trending_up,
                              color: const Color(0xFFFFB74D),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (insights.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.insights_outlined,
                          size: 64.sp,
                          color: Colors.grey,
                        ),
                        verticalSpace(16),
                        Text(
                          'No Insights Yet',
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InsightCard(insight: insights[index]),
                      ),
                      childCount: insights.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          verticalSpace(12),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          verticalSpace(4),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  final DailyInsight insight;

  const InsightCard({super.key, required this.insight});

  Color get statusColor {
    switch (insight.status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(insight.date),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    insight.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (insight.notes.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                insight.notes,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ),
        ],
      ),
    );
  }
}
