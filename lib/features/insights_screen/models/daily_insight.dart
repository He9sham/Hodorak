import 'package:hodorak/core/utils/logger.dart';

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
    Logger.info('Processing insight data: $json');
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
      Logger.error('Error parsing insight: $e');
      rethrow;
    }
  }
}
