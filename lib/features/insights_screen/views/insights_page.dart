import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/features/insights_screen/viewmodels/insights_view_model.dart';
import 'package:hodorak/features/insights_screen/widgets/custom_insight_cart.dart';
import 'package:hodorak/features/insights_screen/widgets/custom_stat_cart.dart';

// UI Components
class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsViewModelProvider);

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
              ref.invalidate(insightsViewModelProvider);
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
          final viewModel = ref.read(insightsViewModelProvider.notifier);
          final presentDays = viewModel.getPresentDays(insights);
          final absentDays = viewModel.getAbsentDays(insights);
          final totalHours = viewModel.getTotalHours(insights);
          final adherenceRate = viewModel.getAdherenceRate(insights);

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
                            child: CustomStatCard(
                              title: 'Hours This Month',
                              value: '${totalHours.toStringAsFixed(1)}h',
                              icon: Icons.access_time,
                              color: const Color(0xFFFFD54F),
                            ),
                          ),
                          horizontalSpace(16),
                          Expanded(
                            child: CustomStatCard(
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
                            child: CustomStatCard(
                              title: 'Days Absent',
                              value: absentDays.toString(),
                              icon: Icons.cancel_outlined,
                              color: const Color(0xFFE57373),
                            ),
                          ),
                          horizontalSpace(16),
                          Expanded(
                            child: CustomStatCard(
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
                        child: CustomInsightCard(insight: insights[index]),
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
