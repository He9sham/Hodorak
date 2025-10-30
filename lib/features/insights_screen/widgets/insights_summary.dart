import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/insights_screen/viewmodels/insights_view_model.dart';
import 'package:intl/intl.dart';

class InsightsSummary extends ConsumerWidget {
  const InsightsSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsViewModelProvider);

    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(237, 225, 225, 228),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full insights page
                    Navigator.pushNamed(context, Routes.insightsScreen);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          insightsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error loading insights',
                  style: TextStyle(color: Colors.red[400]),
                ),
              ),
            ),
            data: (insights) {
              if (insights.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No recent activity',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              // Show only the last 3 insights
              final recentInsights = insights.take(3).toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: recentInsights.map((insight) {
                  Color statusColor;
                  switch (insight.status.toLowerCase()) {
                    case 'present':
                      statusColor = Colors.green;
                      break;
                    case 'late':
                      statusColor = Colors.orange;
                      break;
                    case 'absent':
                      statusColor = Colors.red;
                      break;
                    default:
                      statusColor = Colors.grey;
                  }

                  return InkWell(
                    onTap: () {
                      // Navigate to full insights page
                      Navigator.pushNamed(context, Routes.insightsScreen);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          horizontalSpace(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('MMM dd').format(insight.date),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (insight.notes.isNotEmpty)
                                  Text(
                                    insight.notes,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13.sp,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${insight.totalHours.toStringAsFixed(1)}h',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
